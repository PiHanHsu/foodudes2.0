//
//  FDAddItemTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/4/6.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDAddItemTableViewController.h"
#import "GCGeocodingService.h"
#import "UIPlaceHolderTextView.h"
#import <Parse/Parse.h>

@interface FDAddItemTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
}

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *restaurantNameTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *phoneTextView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) GCGeocodingService *gs;
@property (assign) BOOL photoImageSelected;

@end

@implementation FDAddItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.restaurantNameTextView.placeholder = @"Name";
    self.addressTextView.placeholder = @"Address";
    self.phoneTextView.placeholder = @"Phone Number";
    self.reasonTextView.placeholder = @"Reasons...";
    

    [self.photoButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (self.restaurantInfoDict){
        self.restaurantNameTextView.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"name"]];
        
        self.phoneTextView.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"formatted_phone_number"]];
        self.addressTextView.text = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"formatted_address"]];
    }else if (self.restaurantName){
        self.restaurantNameTextView.text = self.restaurantName;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonPressed:(id)sender {
    
    if (self.restaurantInfoDict) {
        PFQuery *query = [PFQuery queryWithClassName:@"Restaurant_new"];
        [query whereKey:@"placeID" equalTo:self.restaurantInfoDict[@"id"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                [self saveDataToParse];
            } else {
                NSString *objID = object.objectId;
                
                PFObject *post =[PFObject objectWithClassName:@"Posts"];
                post[@"reason"] = self.reasonTextView.text;
                post[@"parent"] = [PFObject objectWithoutDataWithClassName:@"Restaurant_new" objectId:objID];
                post[@"userID"] = [PFUser currentUser].objectId;
                post[@"userName"] = [PFUser currentUser][@"name"];
                if(self.photoImageSelected) {
                    // reset
                    self.photoImageSelected = NO;
                    
                    NSData *image = UIImageJPEGRepresentation(self.photoButton.imageView.image, 0.5f);
                    PFFile *photo = [PFFile fileWithData:image];
                    [photo saveInBackground];
                    
                    post[@"photo"] = photo;
                }
                
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增成功"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [self _ViewControllerAnimated:YES];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增失敗"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        NSLog(@"Save failed: %@", error);
                    }
                }];
                
                
                
            }
        }];
    }else{
        self.gs = [[GCGeocodingService alloc] init];
        [self.gs geocodeAddress:self.addressTextView.text];
        NSString * lat = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lat"]];
        NSString * lng = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lng"]];
        
        //TODO: need to add more conditions
        PFQuery *query = [PFQuery queryWithClassName:@"Restaurant_new"];
        //[query whereKey:@"name" equalTo:self.restaurantNameTextView.text];
        [query whereKey:@"lat" equalTo:lat];
        [query whereKey:@"lng" equalTo:lng];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                [self saveDataToParse2];
            } else{
                NSString *objID = object.objectId;
                
                PFObject *post =[PFObject objectWithClassName:@"Posts"];
                post[@"reason"] = self.reasonTextView.text;
                post[@"parent"] =[PFObject objectWithoutDataWithClassName:@"Restaurant_new" objectId:objID];                post[@"userID"] = [PFUser currentUser].objectId;
                post[@"userName"] = [PFUser currentUser][@"name"];
                
                if(self.photoImageSelected) {
                    // reset
                    self.photoImageSelected = NO;
                    
                    NSData *image = UIImageJPEGRepresentation(self.photoButton.imageView.image, 0.5f);
                    PFFile *photo = [PFFile fileWithData:image];
                    [photo saveInBackground];
                    
                    post[@"photo"] = photo;
                }
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增成功"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [self _ViewControllerAnimated:YES];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增失敗"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        NSLog(@"Save failed: %@", error);
                    }
                }];
            }
        }];

    }
    
    
}

-(void) saveDataToParse{
        PFObject *restaurant = [PFObject objectWithClassName:@"Restaurant_new"];
        restaurant[@"name"] = self.restaurantNameTextView.text;
        restaurant[@"address"] = self.addressTextView.text;
        restaurant[@"phone"] = self.phoneTextView.text;
        restaurant[@"placeID"] = self.restaurantInfoDict[@"id"];
        restaurant[@"lat"] = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"geometry"][@"location"][@"lat"]];
        restaurant[@"lng"] = [NSString stringWithFormat:@"%@", self.restaurantInfoDict[@"geometry"][@"location"][@"lng"]];
        
        PFObject *post =[PFObject objectWithClassName:@"Posts"];
        post[@"reason"] = self.reasonTextView.text;
        post[@"parent"] =restaurant; //set relation between post and restaurant
        //test code
        //post[@"parent"] = [PFObject objectWithoutDataWithClassName:@"Restaurant_new" objectId:@"b4kJRAYc9o"];
        post[@"userID"] = [PFUser currentUser].objectId;
        post[@"userName"] = [PFUser currentUser][@"name"];
        if(self.photoImageSelected) {
            // reset
            self.photoImageSelected = NO;
            
            NSData *image = UIImageJPEGRepresentation(self.photoButton.imageView.image, 0.5f);
            PFFile *photo = [PFFile fileWithData:image];
            [photo saveInBackground];
            
            post[@"photo"] = photo;
        }
        
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增成功"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self _ViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增失敗"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"Save failed: %@", error);
            }
        }];

}

- (void) saveDataToParse2{

        self.gs = [[GCGeocodingService alloc] init];
        [self.gs geocodeAddress:self.addressTextView.text];
        
        PFObject *restaurant = [PFObject objectWithClassName:@"Restaurant_new"];
        restaurant[@"name"] = self.restaurantNameTextView.text;
        restaurant[@"address"] = self.addressTextView.text;
        restaurant[@"phone"] = self.phoneTextView.text;
        restaurant[@"lat"] = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lat"]];
        restaurant[@"lng"] = [NSString stringWithFormat:@"%@", self.gs.geocode[@"lng"]];
        
        PFObject *post =[PFObject objectWithClassName:@"Posts"];
        post[@"reason"] = self.reasonTextView.text;
        post[@"parent"] =restaurant; //set relation between post and restaurant
        post[@"userID"] = [PFUser currentUser].objectId;
        post[@"userName"] = [PFUser currentUser][@"name"];
        
        if(self.photoImageSelected) {
            // reset
            self.photoImageSelected = NO;
            
            NSData *image = UIImageJPEGRepresentation(self.photoButton.imageView.image, 0.5f);
            PFFile *photo = [PFFile fileWithData:image];
            [photo saveInBackground];
            
            post[@"photo"] = photo;
        }
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增成功"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self _ViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增失敗"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"Save failed: %@", error);
            }
        }];
    

}

- (void)_ViewControllerAnimated:(BOOL)animated {
    
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:1];
    [self presentViewController:tabBarVC animated:YES completion:nil];
}


- (void) showOptions:(id)sender{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* camera = [UIAlertAction
                             actionWithTitle:@"Take photo from Camera"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self takePhoto];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    UIAlertAction* album = [UIAlertAction
                            actionWithTitle:@"Choose photo from Album"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [self selectPhoto];
                                [view dismissViewControllerAnimated:YES completion:nil];
                                
                            }];
    
    
    [view addAction:camera];
    [view addAction:album];
    [self presentViewController:view animated:YES completion:nil];
}
- (void)selectPhoto {
    //使用內建相簿
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//使用內建相簿
        //modal
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)takePhoto {
    
    //先檢查是否有照相機功能
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeSavedPhotosAlbum)]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls =YES;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self.photoButton setImage:chosenImage forState:UIControlStateNormal];
    self.photoImageSelected = YES;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}



//user有可能會按"cancel"取消操作
//只要移除PickerController就可以了
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - Navigation


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.destinationViewController isKindOfClass:[FDSetAddressTableViewController class]]) {
//        FDSetAddressTableViewController *vc = (FDSetAddressTableViewController *) segue.destinationViewController;
//        vc.addressString =self.address;
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





@end
