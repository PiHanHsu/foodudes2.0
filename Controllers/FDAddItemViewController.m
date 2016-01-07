//
//  FDAddItemViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDAddItemViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "FDAddItemTableViewController.h"

#import <Parse/Parse.h>

#define API_KEY @"AIzaSyD9Phzy4CZWofeZD3RnEuFemlWTaM4n_po"

@interface FDAddItemViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    BOOL shouldBeginEditing;

}
@property (strong, nonatomic) NSMutableString * placeDetailURL;
@property (strong, nonatomic) NSString * restaurantName;
@property (strong, nonatomic) NSString * phoneNumber;
@property (strong, nonatomic) NSArray * addressArray;
@property (strong, nonatomic) NSString * reason;
@property (strong, nonatomic) NSString * placeID;
@property (strong, nonatomic) NSDictionary * restaurantInfoDict;


@end

@implementation FDAddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:API_KEY];
    shouldBeginEditing = YES;
    
    self.searchDisplayController.searchBar.placeholder =@"輸入餐廳名稱";
    [self.searchDisplayController setActive:YES animated:YES];
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    self.searchDisplayController.searchBar.text=@"";
    self.searchDisplayController.searchBar.placeholder=@"輸入餐廳名稱";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"searchResult: %@", searchResultPlaces);
    //NSLog(@"search count: %lu", searchResultPlaces.count);
    return [searchResultPlaces count];
    
    
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}





#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else if (placemark) {
            
            self.placeDetailURL = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&sensor=ture&key=%@", place.placeId, API_KEY];
            NSLog(@"%@", self.placeDetailURL);
            [self runURLRequest];
            
        }
    }];
}

- (void)runURLRequest {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.placeDetailURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [NSURLConnection sendAsynchronousRequest:mutableRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
        if (data) {
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                NSDictionary *resultsDict = [jsonDictionary objectForKey:@"result"];
                self.restaurantInfoDict =  [jsonDictionary objectForKey:@"result"];
                //NSLog(@"result: %@", resultsDict);
                //NSDictionary * geometryDict = [resultsDict objectForKey:@"geometry"];
                self.restaurantName = [resultsDict objectForKey:@"name"];
                self.addressArray = [resultsDict objectForKey:@"address_components"];
                
                //NSString *address = [resultsDict objectForKey:@"formatted_address"]
                ;
                self.phoneNumber = [resultsDict objectForKey:@"formatted_phone_number"];
                self.placeID =[resultsDict objectForKey:@"place_id"];
                
                FDAddItemTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FDAddItemTableViewController"];
                vc.restaurantInfoDict =self.restaurantInfoDict;
                [self.navigationController pushViewController:vc animated:YES];
                
                
                
            } else {
                NSLog(@"Error with: %@", error);
            }
        }
        
    }];
    
}



-(void)ViewDismiss:(id)sender{
    
  //  [self.addItemView removeFromSuperview];
    
}

#pragma mark SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    if (searchResultPlaces.count == 0)
    {
        NSString *str = self.searchDisplayController.searchBar.text;
        NSString *alertMessage = [NSString stringWithFormat:@"新增“%@”到foodudes", str];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"抱歉目前無此餐廳資訊"
                                      message:alertMessage
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                            self.restaurantName=self.searchDisplayController.searchBar.text;
                            [self _ViewControllerAnimated:YES];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if  (searchResultPlaces.count > 0){
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:@"直接點選上列餐廳"
                                     message:@"若想新增餐廳不再上列，請點選新增"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"新增"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSString *str = self.searchDisplayController.searchBar.text;
                                 NSString *alertMessage = [NSString stringWithFormat:@"新增“%@”到foodudes", str];
                                 UIAlertController * alert=   [UIAlertController
                                                               alertControllerWithTitle:alertMessage
                                                               message:nil
                                                               preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction* ok = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                                      {
                                                         self.restaurantName=self.searchDisplayController.searchBar.text;
                                                         [self _ViewControllerAnimated:YES];
                                                          
                                                      }];
                                 UIAlertAction* cancel = [UIAlertAction
                                                          actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                                          {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                              
                                                          }];
                                 
                                 [alert addAction:ok];
                                 [alert addAction:cancel];
                                 
                                 [self presentViewController:alert animated:YES completion:nil];
                                 
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"取消"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        
        [view addAction:ok];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
        
    }
    
}


#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    
    searchQuery.input = searchString;
    NSLog(@"searchString1: %@", searchString);
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch Places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    //NSLog(@"searchString2: %@", searchString);
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Navigation


- (void)_ViewControllerAnimated:(BOOL)animated {
    
    FDAddItemTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FDAddItemTableViewController"];
    vc.restaurantName = self.restaurantName;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)pushButton:(id)sender {
    
    PFPush *push = [[PFPush alloc] init];
    [push setMessage:@"1st push test!"];
    [push sendPushInBackground];
}



@end
