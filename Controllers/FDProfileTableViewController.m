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
#import "FDRestaurantListTableViewController.h"
#import "FDMyPostListTableViewController.h"


@interface FDProfileTableViewController ()

@property (strong, nonatomic) NSArray * friendsArray; // array of FB friends
@property (strong, nonatomic) NSMutableArray * friendsPostArray; // array of friends and post number
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) NSArray * restaurantListArray; //array of restaurants
@property (strong, nonatomic) NSArray * myPostArray;// array of my posts
@property (strong, nonatomic) UIActivityIndicatorView * indicator;

@end

@implementation FDProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    background.frame =CGRectMake(0, 0, 600,self.view.frame.size.height);
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]
    ;
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = background.bounds;
    [background addSubview:visualEffectView];
    [self.view insertSubview:background atIndex:0];

    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center = self.view.center;
    [self.indicator startAnimating];
    [self.view addSubview:self.indicator];
    
    NSString *name = [PFUser currentUser][@"name"];
    if (name) {
        self.userNameLabel.text = name;
        //self.userNameLabel.textColor = [UIColor blueColor];
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
                                       self.userHeadImage.contentMode = UIViewContentModeScaleAspectFill;
                                       self.userHeadImage.layer.cornerRadius = 5.0f;
                                       self.userHeadImage.clipsToBounds = YES;
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }

    [self getFBfriends];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self getlikes];
    [self getMyPost];
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

//find FB friends
-(void) getFBfriends{
    
    NSUserDefaults * defaultFriendsOnly = [NSUserDefaults standardUserDefaults];
    NSMutableArray * friendsIdArray = [NSMutableArray arrayWithCapacity:0];
    friendsIdArray = [defaultFriendsOnly objectForKey:@"onlyFriendsIdArray"];
    
    PFQuery *friendQuery = [PFUser query];
    [friendQuery whereKey:@"objectId" containedIn:friendsIdArray];
    self.friendsArray = [friendQuery findObjects];
    self.userFriendsLabel.text = [NSString stringWithFormat:@"Friends: %lu", (unsigned long)self.friendsArray.count];

    self.friendsPostArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0 ; i<self.friendsArray.count; i++) {
        PFUser * user = self.friendsArray[i];
        PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
        [postQuery whereKey:@"userID" equalTo:user.objectId];
        NSArray * postListArray = [postQuery findObjects];
        //NSLog(@"%lu", (unsigned long)postListArray.count);
        
        NSNumber * number = [NSNumber numberWithUnsignedLong:postListArray.count];
        NSString * name = [NSString stringWithFormat:@"%@",self.friendsArray[i][@"name"]];
        NSString *pictureURL = [NSString stringWithFormat:@"%@", self.friendsArray[i][@"pictureURL"]];
        NSDictionary * dict = @{@"postNum" : number,
                                @"name" : name,
                                @"pictureURL" : pictureURL,
                                @"postListArray" : postListArray};
        [self.friendsPostArray addObject:dict];
        
        if (i == self.friendsPostArray.count -1) {
            [self sortAndReloadData];
        }
        
    }
    
}

- (void) sortAndReloadData{
     //sorting
    [self.friendsPostArray sortUsingComparator:^(id obj1, id obj2) {
        NSNumber *num1 = [(NSDictionary *)obj1 objectForKey:@"postNum"];
        NSNumber *num2 = [(NSDictionary *)obj2 objectForKey:@"postNum"];
        return [num2 compare:num1];
    }];
    [self.tableView reloadData];
    [self.indicator stopAnimating];
    [self.indicator hidesWhenStopped];
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
                                       cell.headImageView.contentMode = UIViewContentModeScaleAspectFill;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //FDFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    self.restaurantListArray = self.friendsPostArray[indexPath.row][@"postListArray"];
    [self performSegueWithIdentifier:@"Go to Restaurant List" sender:indexPath];
    
}

- (void)getlikes {
    PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSNumber * sum = [objects valueForKeyPath:@"@sum.likeNumber"];
            self.likesLabel.text = [NSString stringWithFormat:@"Likes: %@", sum];
            
        } else {
            
            NSLog(@"get likes Error: %@ ", error);
        }
    }];
}

- (void)getMyPost{
    PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
    [postQuery whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    self.myPostArray = [postQuery findObjects];
    self.userPostsLabel.text = [NSString stringWithFormat:@"Posts: %lu",self.myPostArray.count];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[FDRestaurantListTableViewController class]]) {
        FDRestaurantListTableViewController *vc = (FDRestaurantListTableViewController *) segue.destinationViewController;
        vc.restaurantListArray =self.restaurantListArray;
        
    }else if([segue.destinationViewController isKindOfClass:[FDMyPostListTableViewController class]]){
        FDMyPostListTableViewController *vc = (FDMyPostListTableViewController *) segue.destinationViewController;
        vc.myPostListArray =self.myPostArray;
    }
    
   
}

@end
