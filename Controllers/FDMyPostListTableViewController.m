//
//  FDMyPostListTableViewController.m
//  foodudes2.0
//
//  Created by PiHan Hsu on 2015/5/31.
//  Copyright (c) 2015年 PiHan Hsu. All rights reserved.
//

#import "FDMyPostListTableViewController.h"
#import "FDMyPostTableViewCell.h"
#import "FDEditPostTableViewController.h"
#import <Parse/Parse.h>

@interface FDMyPostListTableViewController ()
@property (strong, nonatomic) NSMutableArray * listArray; //array of myPosts
@property (strong, nonatomic) PFObject * currentPost;
@end

@implementation FDMyPostListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    //NSLog(@"MyPostList: %@" , self.myPostListArray);
    //[self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.myPostListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDMyPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myPostCell" forIndexPath:indexPath];
    
        cell.nameLabel.text = self.myPostListArray[indexPath.row][@"rName"];
        cell.addressLabel.text = self.myPostListArray[indexPath.row][@"rAddress"];
        cell.phoneLabel.text= self.myPostListArray[indexPath.row][@"rPhone"];
    
    //TODO: need to fix photo issue
//    if (self.myPostListArray[indexPath.row][@"photo"] == nil){
//        
//        NSLog(@"no photo");
//    }else{
//            PFFile * file = self.myPostListArray[indexPath.row][@"photo"];
//            if(file)  {
//                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    if(!error){
//                        cell.restaurantImageView.image = [UIImage imageWithData:data];
//                        //[tableView reloadData];
//                    }
//                    else
//                        NSLog(@"%@", error);
//                }];
//            }
//
//    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.currentPost = self.myPostListArray[indexPath.row];
    [self performSegueWithIdentifier:@"Go to Edit TVC" sender:indexPath];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[FDEditPostTableViewController class]]) {
        FDEditPostTableViewController *vc = (FDEditPostTableViewController *) segue.destinationViewController;
        
        vc.post =self.currentPost;
        
    }
}

//-(void) loadData{
//    self.listArray = [@[] mutableCopy];
//    for (int i = 0; i < self.myPostListArray.count ; i++) {
//
//        PFObject * post = self.myPostListArray[i];
//        PFFile * file = post[@"photo"];
//        if(file)  {
//            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                if(!error){
//
//
//                    NSData * imageData = data;
//                    NSDictionary * dict = [[NSDictionary alloc]init];
//                    dict = @{ @"name" : post[@"rName"],
//                              @"address" : post[@"rAddress"],
//                              @"phone" : post[@"rPhone"],
//                              @"imageData" : imageData};
//                    [self.listArray addObject:dict];
//                    [self.tableView reloadData];
//                }
//                else
//                    NSLog(@"%@", error);
//            }];
//        }else{
//            NSData * imageData = [[NSData alloc]init];
//
//            NSDictionary * dict = [[NSDictionary alloc]init];
//            dict = @{ @"name" : post[@"rName"],
//                      @"address" : post[@"rAddress"],
//                      @"phone" : post[@"rPhone"],
//                      @"imageData" : imageData
//                      };
//            [self.listArray addObject:dict];
//            [self.tableView reloadData];
//        }
//
//    }
//
//}

@end
