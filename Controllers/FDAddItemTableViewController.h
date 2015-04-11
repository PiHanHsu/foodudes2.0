//
//  FDAddItemTableViewController.h
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/6.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FDAddItemTableViewController : UITableViewController

@property (strong, nonatomic)NSString *address;
@property (strong, nonatomic)NSString *phone;
@property (strong, nonatomic)NSString *reason;

@end
