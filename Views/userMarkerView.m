//
//  userMarkerView.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/12/4.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "userMarkerView.h"

@implementation userMarkerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (id)customView
{
    userMarkerView *customView = [[[NSBundle mainBundle] loadNibNamed:@"UserMarkerView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[userMarkerView class]])
        return customView;
    else
        return nil;
}

- (UIImage *) imageWithView:(UIView *)view
{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

-(UIImage *) markerImage{
    
    UIImage *img= [self imageWithView:self];
    return img;
    
}


@end
