//
//  FDMyPostTableViewCell.h
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/5/31.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDMyPostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView*restaurantImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@end
