//
//  FDEditPostTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/6/1.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDEditPostTableViewController.h"
#import "UIPlaceHolderTextView.h"

@interface FDEditPostTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *nameTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *phoneTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *reasonTextView;

@end

@implementation FDEditPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"post: %@", self.post);
    
    self.nameTextView.text = self.post[@"rName"];
    self.addressTextView.text = self.post[@"rAddress"];
    self.phoneTextView.text = self.post[@"rPhone"];
    self.reasonTextView.text = self.post[@"reason" ];
    [self.editPhotoButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
    PFFile * file = self.post[@"photo"];
    if (file) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if(!error){
                                 [self.editPhotoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal] ;
                                //self.editPhotoButton.imageView.image = [UIImage imageWithData:data];
                                    
                                }
                                else
                                    NSLog(@"%@", error);
        }];
    }
 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_ViewControllerAnimated:(BOOL)animated {
    
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:1];
    [self presentViewController:tabBarVC animated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {

    PFQuery * query = [PFQuery queryWithClassName:@"Posts"];
    
    [query getObjectInBackgroundWithId:self.post.objectId
                                 block:^(PFObject *post, NSError *error) {
                                    post[@"reason"] = self.reasonTextView.text;
                                     //TODO: finish this
//                                    post[@"rName"] = self.nameTextView.text;
//                                    post[@"rAddress"] = self.addressTextView.text;
//                                    post[@"rPhone"] = self.phoneTextView.text;
                                     
                                     NSData *image = UIImageJPEGRepresentation(self.editPhotoButton.imageView.image, 0.5f);
                                     if (image) {
                                         PFFile *photo = [PFFile fileWithData:image];
                                         [photo saveInBackground];
                                         post[@"photo"] = photo;
                                     }
                                     
                                     
                                     [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded) {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改成功"
                                                                                             message:nil
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             [self _ViewControllerAnimated:YES];
                                         } else {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失敗"
                                                                                             message:nil
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             NSLog(@"Save failed: %@", error);
                                         }
                                     }];

                                 }];
    
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
    [self.editPhotoButton setImage:chosenImage forState:UIControlStateNormal];
    //self.photoImageSelected = YES;
    
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


#pragma mark - Table view data source


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
