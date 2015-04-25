//
//  FDParseTestingTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/12.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDParseTestingTableViewController.h"
#import "FDParseTestingTableViewCell.h"
#import "FDCommentTestTableViewController.h"
#import <Parse/Parse.h>

@interface FDParseTestingTableViewController ()
@property (strong, nonatomic) NSArray * postArray; // array of posts



@end

@implementation FDParseTestingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postArray = objects;
            NSLog(@"objects: %@", objects);
            PFObject * restanrant = self.postArray[1][@"parent"];
            
            [restanrant fetchIfNeededInBackgroundWithBlock:^(PFObject *postRestaurant, NSError *error) {
                NSString *title = postRestaurant[@"name"];
                NSLog(@"title: %@", title);
                
            }];
//            
//            PFQuery *innerQuery = [PFQuery queryWithClassName:@"Recipe"];
//            [innerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
//            PFQuery *outerQuery = [PFQuery queryWithClassName:@"Ingredient"];
//            [outerQuery whereKey:@"recipe" matchesQuery:innerQuery];
//            [outerQuery findObjectsInBackgroundWithBlock:^(NSArray *ingredients, NSError *error) {
//                NSLog(@"found %i ingredients", ingredients.count);
//                
//            }];
            
            
            [self.tableView reloadData];
        }else{
            NSLog(@"load post error: %@", error);
        }
    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.postArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDParseTestingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    
    cell.reasonLabel.text = self.postArray[indexPath.row][@"reason"];
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.0;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[FDCommentTestTableViewController class]]) {
        FDCommentTestTableViewController *vc = (FDCommentTestTableViewController *) segue.destinationViewController;
        vc.postArray =self.postArray;
    }

    
    
}


@end
