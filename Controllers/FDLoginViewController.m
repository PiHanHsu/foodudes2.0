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
    
    [self saveUserDataToParse];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check if user is cached and linked to Facebook, if so, bypass login
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            NSLog(@"current user!!");
            
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
                
                //[self initializeProgressHUD:@"Loading..."];
                //[currentUser saveUserDataToParse];
                
            } else {
                NSLog(@"User with facebook logged in!");
                [self saveUserDataToParse];
                
                //[self initializeProgressHUD:@"Loading..."];
            }
            [self getFBfriends];
            [self _ViewControllerAnimated:YES];
        }
    }];
    
    //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)_ViewControllerAnimated:(BOOL)animated {
    
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:0];
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
            NSString *birthday = userData[@"birthday"];
            NSString *email =userData[@"email"];
            NSString *pictureURL =[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            NSString *gender =userData[@"gender"];
            
            [[PFUser currentUser] setObject:name forKey:@"name"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
            [[PFUser currentUser] setObject:birthday forKey:@"birthday"];
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
            NSArray *friendUsers = [friendQuery findObjects];
            //NSLog(@"friends: %@", friendUsers);
            
        }
    }];

}

@end
