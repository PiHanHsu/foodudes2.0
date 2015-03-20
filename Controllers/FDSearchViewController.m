//
//  FDSearchViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDSearchViewController.h"
#import "GCGeocodingService.h"
#import <GoogleMaps/GoogleMaps.h>


@interface FDSearchViewController ()<GMSMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) GCGeocodingService *gs;
@end


@implementation FDSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    NSLog(@"search view");
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.023868 longitude:121.528976 zoom:15 bearing:0 viewingAngle:0];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    self.mapView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-65);
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    
    self.searchBar.showsSearchResultsButton=YES;
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.placeholder=@"輸入地點,例如：台北北投、台北淡水...";
    self.searchBar.delegate=self;
    
    [self.view addSubview:self.searchBar];
    
    [self.view insertSubview:self.mapView atIndex:0];

    self.gs = [[GCGeocodingService alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    NSLog(@"%@", self.searchBar.text);
    [self.gs geocodeAddress:self.searchBar.text];
    [self addMarker];
    self.searchBar.text=@"";
    self.searchBar.placeholder=@"輸入地點,例如：台北北投、台北淡水...";
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[self.infoView removeFromSuperview];
    return YES;
    
}

- (void)addMarker{
    double lat = [[self.gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[self.gs.geocode objectForKey:@"lng"] doubleValue];
 
    NSLog(@"lat: %f, lmng: %f", lat, lng);
       GMSMarker *options = [[GMSMarker alloc] init];
       options.position = CLLocationCoordinate2DMake(lat, lng);
       options.title = [self.gs.geocode objectForKey:@"address"];
       options.appearAnimation= kGMSMarkerAnimationPop;
       options.map =self.mapView;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat                                                                longitude:lng                                                        zoom:15];
    [self.mapView setCamera:camera];
    
}

@end
