//
//  FDProfileTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/13.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDProfileTableViewController.h"
#import "FDFriendsTableViewCell.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FDProfileTableViewController ()

@property (strong, nonatomic) NSArray * friendsArray; // array of FB friends
@property (strong, nonatomic) NSMutableArray * friendsPostArray; // array of friends and post number
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFriendsLabel;
@property (strong, nonatomic) UIActivityIndicatorView * indicator;

@end

@implementation FDProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = self.view.center;
    [self.indicator startAnimating];
    [self.view addSubview:self.indicator];
    
    NSString *name = [PFUser currentUser][@"name"];
    if (name) {
        self.userNameLabel.text = name;
        self.userNameLabel.textColor = [UIColor blueColor];
        self.userNameLabel.font = [UIFont systemFontOfSize:24];
    }
    
    NSString *userProfilePhotoURLString = [PFUser currentUser][@"pictureURL"];
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.userHeadImage.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }

    
    [self getFBfriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.friendsArray.count;
}

// find FB friends
-(void) getFBfriends{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookID" containedIn:friendIds];
            self.friendsArray = [friendQuery findObjects];
            self.userFriendsLabel.text = [NSString stringWithFormat:@"Friends: %lu", self.friendsArray.count];
            PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
            [postQuery whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
            NSArray * myPostArray = [postQuery findObjects];
            self.userPostsLabel.text = [NSString stringWithFormat:@"Posts: %lu",myPostArray.count];
            
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray * friendsIdArray = [NSMutableArray arrayWithCapacity:0];
            friendsIdArray = [defaults objectForKey:@"friendsIdArray"];
            
            self.friendsPostArray = [[NSMutableArray alloc]initWithCapacity:0];
            
            for (int i = 0 ; i<self.friendsArray.count; i++) {
                PFUser * user = self.friendsArray[i];
                PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
                [postQuery whereKey:@"userID" equalTo:user.objectId];
                NSArray * postNumberArray = [postQuery findObjects];
                NSLog(@"%lu", (unsigned long)postNumberArray.count);
                
                NSNumber * number = [NSNumber numberWithUnsignedLong:postNumberArray.count];
                NSString * name = [NSString stringWithFormat:@"%@",self.friendsArray[i][@"name"]];
                NSString *pictureURL = [NSString stringWithFormat:@"%@", self.friendsArray[i][@"pictureURL"]];
                NSDictionary * dict = @{@"postNum" : number,
                                        @"name" : name,
                                        @"pictureURL" : pictureURL};
                [self.friendsPostArray addObject:dict];
                
                if (i == self.friendsPostArray.count -1) {
                    [self.tableView reloadData];
                    [self.indicator stopAnimating];
                    [self.indicator hidesWhenStopped];
                }
                
            }
            
            
        }
    }];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.friendNameLabel.text = self.friendsPostArray[indexPath.row][@"name"];
    cell.postNumLabel.text = [NSString stringWithFormat:@"Posts: %@", self.friendsPostArray[indexPath.row][@"postNum"]];
    
     NSString *userProfilePhotoURLString = self.friendsPostArray[indexPath.row][@"pictureURL"];
    
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       cell.headImageView.image = [UIImage imageWithData:data];
                                       cell.headImageView.backgroundColor = [UIColor lightGrayColor];
                                       cell.headImageView.layer.cornerRadius = 25.0;
                                       cell.headImageView.layer.masksToBounds = YES;
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
        
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
