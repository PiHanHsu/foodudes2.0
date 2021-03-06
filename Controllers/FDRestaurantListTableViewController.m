//
//  FDRestaurantListTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/5/30.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDRestaurantListTableViewController.h"
#import "FDRestaurantListTableViewCell.h"
#import <Parse/Parse.h>

@interface FDRestaurantListTableViewController ()

@property (strong, nonatomic) NSMutableArray * listArray; //array of restaurant list

@end

@implementation FDRestaurantListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    //NSLog(@"array: %@", self.restaurantListArray);
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData{
    self.listArray = [@[] mutableCopy];
    for (PFObject * post in self.restaurantListArray){
        PFFile * file = post[@"photo"];
        if(file)  {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    NSData * imageData = data;
                    NSDictionary * dict = [[NSDictionary alloc]init];
                    dict = @{ @"name" : post[@"rName"],
                              @"address" : post[@"rAddress"],
                              @"imageData" : imageData};
                    [self.listArray addObject:dict];
                    [self.tableView reloadData];
                }
                else
                    NSLog(@"%@", error);
            }];
        }else{
            NSData * imageData = [[NSData alloc]init];
            NSDictionary * dict = [[NSDictionary alloc]init];
            dict = @{ @"name" : post[@"rName"],
                      @"address" : post[@"rAddress"],
                      @"imageData" : imageData
                      };
            [self.listArray addObject:dict];
            [self.tableView reloadData];
        }
    }
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDRestaurantListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"restaurantCell" forIndexPath:indexPath];
    if (self.listArray){
        cell.restaurantNameLabel.text = self.listArray[indexPath.row][@"name"];
        cell.restaurantAddressLabel.text = self.listArray[indexPath.row][@"address"];
        cell.restaurantImageView.image = [UIImage imageWithData:self.listArray[indexPath.row][@"imageData"]];
//        cell.restaurantImageView.contentMode = UIViewContentModeScaleAspectFit;
//        cell.restaurantImageView.clipsToBounds = YES;
        
    }
   

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
