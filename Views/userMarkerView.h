//
//  userMarkerView.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/12/4.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userMarkerView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

+ (id)customView;
- (UIImage *) imageWithView:(UIView *)view;
- (UIImage *) markerImage;

@end
