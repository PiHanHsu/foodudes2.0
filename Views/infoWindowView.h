//
//  infoWindowView.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/20.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDLikeButton.h"
#import "FDCommentButton.h"

@interface infoWindowView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet  FDCommentButton * commentButton;
@property (weak, nonatomic) IBOutlet FDLikeButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *tel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;


@end
