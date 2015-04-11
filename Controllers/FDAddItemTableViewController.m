//
//  FDAddItemTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/6.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDAddItemTableViewController.h"
#import "FDSetAddressTableViewController.h"

#import <Parse/Parse.h>

@interface FDAddItemTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *restaurantNameTextField;
@property NSString *restID;



@end

@implementation FDAddItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonPressed:(id)sender {

    PFObject *restaurant = [PFObject objectWithClassName:@"Restaurant_new"];
    restaurant[@"name"] = self.restaurantNameTextField.text;
    restaurant[@"address"] = self.address;
    restaurant[@"phone"] = self.phone;
    
    PFObject *post =[PFObject objectWithClassName:@"Posts"];
    post[@"reason"] = self.reason;
    post[@"parent"] =restaurant;  //set relation between post and restaurant
    post[@"userID"] = [PFUser currentUser].objectId;
    post[@"userName"] = [PFUser currentUser][@"name"];
        
    [post saveInBackground];
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[FDSetAddressTableViewController class]]) {
        FDSetAddressTableViewController *vc = (FDSetAddressTableViewController *) segue.destinationViewController;
        vc.addressString =self.address;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

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