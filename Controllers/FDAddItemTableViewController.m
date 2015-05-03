//
//  FDAddItemTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/6.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDAddItemTableViewController.h"
#import "FDSetAddressTableViewController.h"
#import "GCGeocodingService.h"
#import "UIPlaceHolderTextView.h"
#import <Parse/Parse.h>

@interface FDAddItemTableViewController ()
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *restaurantNameTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) GCGeocodingService *gs;

@end

@implementation FDAddItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.addressTextView.placeholder = @"Address";
    self.reasonTextView.placeholder = @"Reasons...";
    
    
    if (self.restaurantInfoDict){
        self.restaurantNameTextField.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"name"]];
        
        self.phoneTextField.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"formatted_phone_number"]];
        self.addressTextView.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"formatted_address"]];
    }else if (self.restaurantName){
        self.restaurantNameTextField.text = self.restaurantName;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonPressed:(id)sender {
    
    if (self.restaurantInfoDict) {
        PFObject *restaurant = [PFObject objectWithClassName:@"Restaurant_new"];
        restaurant[@"name"] = self.restaurantNameTextField.text;
        restaurant[@"address"] = self.addressTextView.text;
        restaurant[@"phone"] = self.phoneTextField.text;
        restaurant[@"placeID"] = self.restaurantInfoDict[@"id"];
        restaurant[@"lat"] = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"geometry"][@"location"][@"lat"]];
        restaurant[@"lng"] = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"geometry"][@"location"][@"lng"]];
        
        PFObject *post =[PFObject objectWithClassName:@"Posts"];
        post[@"reason"] = self.reasonTextView.text;
        post[@"parent"] =restaurant; //set relation between post and restaurant
        //test code
        //post[@"parent"] = [PFObject objectWithoutDataWithClassName:@"Restaurant_new" objectId:@"b4kJRAYc9o"];
        post[@"userID"] = [PFUser currentUser].objectId;
        post[@"userName"] = [PFUser currentUser][@"name"];
        
        [post saveInBackground];
    }else{
        self.gs = [[GCGeocodingService alloc] init];
        [self.gs geocodeAddress:self.addressTextView.text];
        
        PFObject *restaurant = [PFObject objectWithClassName:@"Restaurant_new"];
        restaurant[@"name"] = self.restaurantNameTextField.text;
        restaurant[@"address"] = self.addressTextView.text;
        restaurant[@"phone"] = self.phoneTextField.text;
        //restaurant[@"placeID"] = self.restaurantInfoDict[@"id"];
        restaurant[@"lat"] = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lat"]];
        restaurant[@"lng"] = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lng"]];
        
        PFObject *post =[PFObject objectWithClassName:@"Posts"];
        post[@"reason"] = self.reasonTextView.text;
        post[@"parent"] =restaurant; //set relation between post and restaurant
        post[@"userID"] = [PFUser currentUser].objectId;
        post[@"userName"] = [PFUser currentUser][@"name"];
        
        [post saveInBackground];

    }
    
}

#pragma mark - Navigation


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.destinationViewController isKindOfClass:[FDSetAddressTableViewController class]]) {
//        FDSetAddressTableViewController *vc = (FDSetAddressTableViewController *) segue.destinationViewController;
//        vc.addressString =self.address;
//    }
//}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    switch (section) {
//        case 0:
//            return 1;
//            break;
//        case 1:
//            return 3;
//            break;
//        case 2:
//            return 1;
//            break;
//        default:
//            break;
//    }
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





@end
