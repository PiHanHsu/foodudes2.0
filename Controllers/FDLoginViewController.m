//
//  FDLoginViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDLoginViewController.h"
#import "FDSearchViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FDLoginViewController ()
@property (strong, nonatomic) NSString * currentUserID;

@end

@implementation FDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Logo for login"]];
    
    logoImageView.frame = CGRectMake(0, 0, 280, 210);
    logoImageView.contentMode = UIViewContentModeScaleToFill;
    logoImageView.center = CGPointMake(self.view.center.x, self.view.center.y*0.6);
    
    
    UIButton *loginButton =[[UIButton alloc]init];
    loginButton.frame= CGRectMake(0, 0, 240, 45.75);
    loginButton.center = CGPointMake(self.view.center.x
                                     , self.view.center.y*1.3);
    [loginButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setImage:[UIImage imageNamed:@"Facebook_login"] forState:UIControlStateNormal];
    
    [self.view addSubview:logoImageView];
    [self.view addSubview:loginButton];
    
    //[self saveUserDataToParse];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(@"current user!!");
        [self getFBfriends];
        [self _ViewControllerAnimated:YES];
    }

}
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_friends", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self saveUserDataToParse];
                [self getFBfriends];
            } else {
                NSLog(@"User with facebook logged in!");
                [self saveUserDataToParse];
                [self getFBfriends];
            }
            
            
        }
    }];

}

- (void)_ViewControllerAnimated:(BOOL)animated {
    
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:1];
    [self presentViewController:tabBarVC animated:YES completion:nil];
}

-(void) saveUserDataToParse
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            //some people may be make birthday public
            //NSString *birthday = userData[@"birthday"];
            NSString *email =userData[@"email"];
            NSString *pictureURL =[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            NSString *gender =userData[@"gender"];
            
            [[PFUser currentUser] setObject:name forKey:@"name"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
            //[[PFUser currentUser] setObject:birthday forKey:@"birthday"];
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] setObject:pictureURL forKey:@"pictureURL"];
            [[PFUser currentUser] setObject:gender forKey:@"gender"];
            
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

// find FB friends
-(void) getFBfriends{
    
    PFUser * currentUser = [PFUser currentUser];
    self.currentUserID = [NSString stringWithFormat:@"%@", currentUser.objectId];
    NSLog(@"user objectID: %@", self.currentUserID);

    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            
            
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookID" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSArray *friendsArray = [friendQuery findObjects];
            
            NSMutableArray * friendsIdArray = [NSMutableArray arrayWithCapacity: friendsArray.count];
            
            NSMutableArray * onlyFriendsIdArray = [NSMutableArray arrayWithCapacity: friendsArray.count];
            for(int i=0 ; i< friendsArray.count ; i++){
                PFUser * user = friendsArray[i];
                [onlyFriendsIdArray addObject:user.objectId];
                
                if (i == friendsArray.count -1) {
                    
                    NSUserDefaults * defaultFriendsOnly = [NSUserDefaults standardUserDefaults];
                    [defaultFriendsOnly setObject:onlyFriendsIdArray forKey:@"onlyFriendsIdArray"];
                    [defaultFriendsOnly synchronize];
                }
            }
        
            // add currentUserID
           [friendsIdArray addObject:self.currentUserID];
            
            for(int i=0 ; i< friendsArray.count ; i++){
                PFUser * user = friendsArray[i];
                [friendsIdArray addObject:user.objectId];
                
                if (i == friendsArray.count -1) {
                    
                    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:friendsIdArray forKey:@"friendsIdArray"];
                    [defaults synchronize];
                    [self _ViewControllerAnimated:YES];
                }
            }
            
            
            
        }
    }];

}



@end
