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
#import "FDLikeButton.h"
#import "FDCommentButton.h"

@interface FDSearchViewController ()<GMSMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *postScrollView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet FDCommentButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *CommentTextView;

@property (strong, nonatomic) GCGeocodingService *gs;
@property (strong, nonatomic) NSArray * restaurantArray; //of restaurants
@property (strong, nonatomic) NSArray * postArray; // of all posts
@property (strong, nonatomic) NSArray * markerPostsArray; // the posts on the tap marker
@property (strong, nonatomic) PFObject * restaurantInfo;
@property (strong, nonatomic) PFObject * postObj;
@property (strong, nonatomic) NSString *restaurantID;
@property (strong, nonatomic) NSString *userID;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property(nonatomic,strong) UIDynamicAnimator *animator;
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
    self.commentView.hidden = YES;
    [self.indicator startAnimating];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([UIScreen mainScreen].bounds.size.height == 480){
        self.postScrollView.frame = CGRectMake(0, 70, self.view.frame.size.width , 290);
    }else{
        self.postScrollView.frame = CGRectMake(0, self.view.frame.size.height * 0.2, self.view.frame.size.width , 290);
    }
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
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * friendsIdArray = [NSMutableArray arrayWithCapacity:0];
    friendsIdArray = [defaults objectForKey:@"friendsIdArray"];
    
    PFQuery * postQuery = [PFQuery queryWithClassName:@"Posts"];
    [postQuery whereKey:@"userID" containedIn:friendsIdArray];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * postArray, NSError * error){
        self.postArray = postArray;
        [self displayMarker];
    }];
}


#pragma mark displayMarker

-(void) displayMarker{
    
        NSMutableArray * restaurantArray = [ NSMutableArray arrayWithCapacity:0];
    
        for (int i=0 ; i < self.postArray.count ; i++) {
            
            PFObject *postObj = self.postArray[i];
            //use relation in Parse
            PFObject * restaurant = postObj[@"parent"];
            
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
                                                               [self.indicator stopAnimating];                      }else {
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
    if ([UIScreen mainScreen].bounds.size.height == 480){
        point.y = point.y - 205;
    }else if ([UIScreen mainScreen].bounds.size.height == 568){
        point.y = point.y - 210;
    }else if ([UIScreen mainScreen].bounds.size.height == 667){
        point.y = point.y - 175;
    }else if ([UIScreen mainScreen].bounds.size.height == 736){
        point.y = point.y - 155;
    }
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
    self.postScrollView.backgroundColor = [UIColor clearColor];
    
    for (int i= 0; i<self.markerPostsArray.count ; i++){
        int x = (self.view.frame.size.width-260)/2;
        infoWindowView *infoView =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
        infoView.frame = CGRectMake(x+(275 *i), 0, 260, 290);
        infoView.layer.cornerRadius = 5.0;
        infoView.clipsToBounds = YES;
        infoView.restaurantName.text = self.restaurantInfo[@"name"];
        //TDOD: make sure it won't screw up
        NSString *address = self.restaurantInfo[@"address"];
        if ([address containsString:@"台灣"]) {
            NSString * newAddress = [address substringFromIndex:5];
            infoView.addressTextView.text = newAddress;
        }else{
            infoView.addressTextView.text = address;
        }
        infoView.phoneTextView.text = self.restaurantInfo[@"phone"];
        infoView.postTextView.text = self.markerPostsArray[i][@"reason"];
        infoView.userNameLabel.text = self.markerPostsArray[i][@"userName"];
        infoView.likeAndCommentLabel.text = [NSString stringWithFormat:@"%@個讚 · %@則留言",self.markerPostsArray[i][@"likeNumber"],self.markerPostsArray[i][@"commentNumber"]];
        [[NSNotificationCenter defaultCenter]
         addObserverForName:@"likeNumberUpdated"
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             if ([notification.name isEqualToString:@"likeNumberUpdated"]) {
                 NSNumber * likeNumber = self.markerPostsArray[i][@"likeNumber"];
                 likeNumber = @(likeNumber.intValue + 1);
                 infoView.likeAndCommentLabel.text = [NSString stringWithFormat:@"%@個讚 · %@則留言",likeNumber ,self.markerPostsArray[i][@"commentNumber"]];
             }
         }];
        [[NSNotificationCenter defaultCenter]
         addObserverForName:@"commentNumberUpdated"
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             if ([notification.name isEqualToString:@"commentNumberUpdated"]) {
                 NSNumber * commentNumber = self.markerPostsArray[i][@"commentNumber"];
                 commentNumber = @(commentNumber.intValue + 1);
                 infoView.likeAndCommentLabel.text = [NSString stringWithFormat:@"%@個讚 · %@則留言",self.markerPostsArray[i][@"likeNumber"] , commentNumber];
             }
         }];
        infoView.likeButton.postObj =self.markerPostsArray[i];
        PFQuery * query = [PFQuery queryWithClassName:@"Like"];
        [query whereKey:@"postID" equalTo:infoView.likeButton.postObj.objectId];
        [query whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                [infoView.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                infoView.likeButton.enabled = NO;
            } else {
                [infoView.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            }
        }];
    
        //disable commentButton
//        infoView.commentButton.postObj = self.markerPostsArray[i];
//        [infoView.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        infoView.commentButton.enabled = NO;
        infoView.shareButton.enabled = NO;
        
        
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
    // [self viewDismiss];
    self.postScrollView.hidden = YES;
    //remove all the subviews in postScrollView
    for(UIView *subview in [self.postScrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    [self.searchBar resignFirstResponder];
    
}

#pragma mark buttons

- (void) likeButtonPressed:(id)sender{
    FDLikeButton * likeButton = (FDLikeButton *) sender;
    [likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    likeButton.enabled = NO;
    
    PFObject * likeObject = [PFObject objectWithClassName:@"Like"];
    likeObject[@"userID"] = [PFUser currentUser].objectId;
    likeObject[@"userName"] = likeButton.postObj[@"userName"];
    likeObject[@"like"] = @YES;
    likeObject[@"postID"] = likeButton.postObj.objectId;
    
    [likeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
            
            [query getObjectInBackgroundWithId:likeButton.postObj.objectId
                                         block:^(PFObject *object, NSError *error) {
                                             NSNumber * likeNumber = object[@"likeNumber"];
                                             likeNumber = @(likeNumber.intValue + 1);
                                             object[@"likeNumber"] = likeNumber;
                                             [object saveInBackground];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"likeNumberUpdated" object:self];
                                         }];
            
        } else {
            NSLog(@"Save like failed: %@" , error);
        }
    }];
}

- (void) commentButtonPressed:(id)sender{
    self.commentView.hidden = NO;
    [self.CommentTextView becomeFirstResponder];
    
    self.sendButton = (FDCommentButton *) sender;
    self.postObj = self.sendButton.postObj;

}

- (void) sendButtonPressed:(id)sender{
    self.commentView.hidden = YES;
    [self.CommentTextView resignFirstResponder];
    
    if (self.postObj) {
        //TODO: parent
        PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
        [query whereKey:@"objectId" equalTo:self.postObj.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * post, NSError *error){
            PFObject * commentObject = [PFObject objectWithClassName:@"Comment"];
            commentObject[@"replier"] = [PFUser currentUser].objectId;
            commentObject[@"replierName"] = self.postObj[@"userName"];
            commentObject[@"parent"] = post;
            commentObject[@"postID"] = self.postObj.objectId;
            commentObject[@"comment"] = self.CommentTextView.text;
            
            [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.CommentTextView.text = @"";
                    PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
                    
                    [query getObjectInBackgroundWithId:self.postObj.objectId
                                                 block:^(PFObject *object, NSError *error) {
                                                     NSNumber * commentNumber = object[@"commentNumber"];
                                                     commentNumber = @(commentNumber.intValue + 1);
                                                     object[@"commentNumber"] = commentNumber;
                                                     [object saveInBackground];
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"commentNumberUpdated" object:self];
                                                     //remove self.postObj
                                                     self.postObj = nil;
                                                 }];
                    
                } else {
                    NSLog(@"Save comment failed: %@" , error);
                }
            }];

        }];
        
        
    }
    
}


-(void)viewDismiss {
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.postScrollView]];
    //控制方向與速度. 0.0f -->正下方, 10.0f 速度 （數字越大越快）
    gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 2.0f);
    [self.animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.postScrollView]];
    //控制轉動程度,2.0f-->數字越大轉動越大
    [itemBehaviour addAngularVelocity:2.0f forItem:self.postScrollView];
    [self.animator addBehavior:itemBehaviour];
    
    //remove all the subviews in postScrollView
//    for(UIView *subview in [self.postScrollView subviews]) {
//        [subview removeFromSuperview];
//    }

}
@end
