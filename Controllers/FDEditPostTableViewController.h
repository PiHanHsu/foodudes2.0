//
//  FDEditPostTableViewController.h
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/6/1.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FDEditPostTableViewController : UITableViewController
@property (strong, nonatomic) PFObject * post;
@end
