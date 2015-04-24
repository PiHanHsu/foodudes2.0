//
//  AppDelegate.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"yAGJoY4EsQ7b2jx4DvBw5wff2YChWRJAzeock7pv"
                  clientKey:@"op3v3HrmPFTVMqBzV7WFMeUsIcuMK5sSLTJV1jvR"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [GMSServices provideAPIKey:@"AIzaSyCt1tGuzSRiPBdqxWDEE-CnpaT-rDhQw_w"];
    [PFFacebookUtils initializeFacebook];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  }

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];

}

@end
