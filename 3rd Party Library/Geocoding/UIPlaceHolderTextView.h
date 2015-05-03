//
//  UIPlaceHolderTextView.h
//  ProperlyOwner
//
//  Created by Shyne on 10/23/14.
//  Copyright (c) 2014 shynetseng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (assign) NSTextAlignment inputTextAlignment;

-(void)textChanged:(NSNotification*)notification;

@end