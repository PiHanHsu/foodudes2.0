//
//  GCGeocodingService.h
//  GeocodingAPISample
//
//  Created by Mano Marks on 4/11/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCGeocodingService : NSObject

- (id)init;
- (void)geocodeAddress:(NSString *)address;

@property (nonatomic, strong) NSDictionary *geocode;

@end
