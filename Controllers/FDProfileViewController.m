//
//  FDProfileViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDProfileViewController.h"
#import <Parse/Parse.h>
#import "FDUser.h"

@interface FDProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end


@implementation FDProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Display userName and image
    NSString *name = [PFUser currentUser][@"name"];
    if (name) {
        self.nameLabel.text = name;
        self.nameLabel.textColor = [UIColor blueColor];
        self.nameLabel.font = [UIFont systemFontOfSize:30];
    }
    NSString *userProfilePhotoURLString = [PFUser currentUser][@"pictureURL"];
    // Download the user's facebook profile picture
    
    NSLog(@"URL: %@", userProfilePhotoURLString);
    
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.headImageView.image = [UIImage imageWithData:data];
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
        
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
