//
//  FDRestaurantListTableViewCell.h
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/5/30.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDRestaurantListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddressLabel;

@end
