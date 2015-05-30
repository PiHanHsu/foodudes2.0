//
//  FDSearchViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/3/15.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDSearchViewController.h"
#import "GCGeocodingService.h"
#import "userMarkerView.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>


#import "FDMarker.h"
#import "infoWindowView.h"

@interface FDSearchViewController ()<GMSMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *postScrollView;

@property (strong, nonatomic) GCGeocodingService *gs;
@property (strong, nonatomic) NSArray * restaurantArray; //of restaurants
@property (strong, nonatomic) NSArray * postArray; // of all posts
@property (strong, nonatomic) NSArray * markerPostsArray; // the posts on the tap marker
@property (strong, nonatomic) PFObject * restaurantInfo;
@property (strong, nonatomic) NSString *restaurantID;
@property (strong, nonatomic) NSString *userID;
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

    [self loadFriendsPost];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.postScrollView.hidden = YES;
    
    [self loadFriendsPost];
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

# pragma mark Loading data


- (void) loadFriendsPost{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray * friendsIdArray = [NSMutableArray arrayWithCapacity:0];
            friendsIdArray = [defaults objectForKey:@"friendsIdArray"];
            
            PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
            [postQuery whereKey:@"userID" containedIn:friendsIdArray];
            self.postArray = [postQuery findObjects];
            
            [self displayMarker];
        }else{
            NSLog(@"load [friendspost failed: %@", error);
        }
    }];
}


#pragma mark displayMarker

-(void) displayMarker{
    
        NSMutableArray * restaurantArray = [ NSMutableArray arrayWithCapacity:0];
    
        for (int i=0 ; i < self.postArray.count ; i++) {
            
            PFObject *postObj = self.postArray[i];
            //use relation in Parse
            PFObject * restaurant = postObj[@"parent"];
            //NSLog(@"restauant: %@", restaurant);
            
            [restaurant fetchInBackgroundWithBlock:^(PFObject *postRestaurant, NSError *error) {
                if (!error) {
                    //NSLog(@"postRestaurant: %@", postRestaurant.objectId);
                    NSString * restautantID = [NSString stringWithFormat:@"%@",postRestaurant.objectId];
                    [restaurantArray addObject:restautantID];
                    PFQuery * queryUser = [PFUser query];
                    [queryUser whereKey:@"objectId" equalTo:postObj[@"userID"]];
                    [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (!error){
                            NSString *userProfilePhotoURLString = object[@"pictureURL"];
                            if (userProfilePhotoURLString) {
                                NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
                                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                                   queue:[NSOperationQueue mainQueue]
                                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                           if (connectionError == nil && data != nil) {
                                                               userMarkerView *view =  [[[NSBundle mainBundle] loadNibNamed:@"UserMarkerView" owner:self options:nil] objectAtIndex:0];
                                                               view.userImage.image =[UIImage imageWithData:data];
                                                               view.userImage.layer.cornerRadius = 18.0f;
                                                               view.userImage.layer.masksToBounds =YES;UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
                                                               [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                                                               UIImage *imageScreen =UIGraphicsGetImageFromCurrentImageContext();
                                                               UIGraphicsEndImageContext();
                                                               
                                                               FDMarker * restaurantMarker = [[FDMarker alloc]init];
                                                               restaurantMarker.info = postRestaurant;
                                                               restaurantMarker.icon = imageScreen;
                                                               
                                                               NSString *market_lat = [NSString stringWithFormat:@"%@", restaurantMarker.info[@"lat"]];
                                                               double lat = [market_lat doubleValue];
                                                               
                                                               NSString *market_lng = [NSString stringWithFormat:@"%@", restaurantMarker.info[@"lng"]];
                                                               double lng = [market_lng doubleValue];
                                                               
                                                               restaurantMarker.position = CLLocationCoordinate2DMake(lat, lng);
                                                               restaurantMarker.appearAnimation= kGMSMarkerAnimationPop;
                                                               restaurantMarker.map =self.mapView;
                                                           }else {
                                                               NSLog(@"Failed to load user image for marker.");
                                                           }
                                                       }];
                            }
                        }else{
                            NSLog(@"query user error: %@", error);
                        }
                        
                    }];
                    
        
                }
            }];
            
        }
    
}




#pragma mark mapView Delegate
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    
    //move marker position
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y = point.y - 175;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];
    
    FDMarker * tappedMarker = (FDMarker *)marker;
    self.restaurantInfo = tappedMarker.info;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query whereKey:@"parent" equalTo:tappedMarker.info];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.markerPostsArray = objects;
        //NSLog(@"posts: %@", objects);
        [self displayPost];
    }];
 
    mapView.selectedMarker = marker;
    
    return YES;
}

-(void) displayPost{
    self.postScrollView.hidden = NO;
    self.postScrollView.contentSize = CGSizeMake(275 *self.markerPostsArray.count +50, 290);
    
    self.postScrollView.backgroundColor = [UIColor whiteColor];
    
    
    
    for (int i= 0; i<self.markerPostsArray.count ; i++){
        int x = 30;
        infoWindowView *infoView =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
        infoView.frame = CGRectMake(x+(275 *i), 0, 260, 290);
        infoView.restaurantName.text = self.restaurantInfo[@"name"];
        infoView.address.text = self.restaurantInfo[@"address"];
        infoView.tel.text = self.restaurantInfo[@"phone"];
        infoView.postLabel.text = self.markerPostsArray[i][@"reason"];
        infoView.userNameLabel.text = self.markerPostsArray[i][@"userName"];
        
        PFFile * file = self.markerPostsArray[i][@"photo"];
        if(file)  {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error)
                    infoView.restaurantImageView.image = [UIImage imageWithData:data];
                else
                    NSLog(@"%@", error);
            }];
        }
        
        PFQuery * queryUser = [PFUser query];
        [queryUser whereKey:@"objectId" equalTo:self.markerPostsArray[i][@"userID"]];
        [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error){
                NSString *userProfilePhotoURLString = object[@"pictureURL"];
                if (userProfilePhotoURLString) {
                    NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                    [NSURLConnection sendAsynchronousRequest:urlRequest
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                               if (connectionError == nil && data != nil) {
                                                   infoView.userImageView.image =[UIImage imageWithData:data];
                                                   infoView.userImageView.layer.cornerRadius = 25.0f;
                                                   infoView.userImageView.layer.masksToBounds =YES;
                                                   
                                               }else {
                                                   NSLog(@"Failed to load user image for posts.");
                                               }
                                           }];
                }
            }else{
                NSLog(@"query user error: %@", error);
            }
            
        }];
        
        
        [self.postScrollView addSubview:infoView];
    }
    
}

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.postScrollView.hidden = YES;
    
    //remove all the subviews in postScrollView
    for(UIView *subview in [self.postScrollView subviews]) {
        [subview removeFromSuperview];
    }
    [self.searchBar resignFirstResponder];
    
}


@end
