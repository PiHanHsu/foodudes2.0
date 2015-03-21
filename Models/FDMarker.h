//
//  FDMarker.h
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/21.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
@interface FDMarker : GMSMarker
@property (strong, nonatomic)PFObject *info;

@end
