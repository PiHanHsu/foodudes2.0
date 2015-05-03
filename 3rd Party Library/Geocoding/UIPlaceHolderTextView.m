//
//  UIPlaceHolderTextView.m
//  ProperlyOwner
//
//  Created by Shyne on 10/23/14.
//  Copyright (c) 2014 shynetseng. All rights reserved.
//

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView ()

@property (nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation UIPlaceHolderTextView

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    self.textStorage.delegate = (id <NSTextStorageDelegate>)self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        self.textStorage.delegate = (id <NSTextStorageDelegate>)self;
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
//        NSAttributedString *as = self.attributedText;
        if([[self attributedText] length] == 0)
        {
            [[self viewWithTag:999] setAlpha:1];
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void) setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textChanged:nil];
}
- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self attributedText] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.inputTextAlignment;
    paragraphStyle.minimumLineHeight = 22.f;
    paragraphStyle.maximumLineHeight = 1000.f;
    
    [textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:editedRange];
}

#if 0
- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    //FLOG(@"textStorage:didProcessEditing:range:changeInLength: called");
    __block NSMutableDictionary *dict;
    
    [textStorage enumerateAttributesInRange:editedRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         
         dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
         
         // Iterate over each attribute and look for attachments
         [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             
             NSLog(@"Key : %@", key);
             if ([[key description] isEqualToString:NSAttachmentAttributeName]) {
                 //FLOG(@" textAttachment found");
                 //FLOG(@" textAttachment class is %@", [obj class]);
                 
                 NSTextAttachment *attachment = obj;
                 PPTextAttachment *osAttachment;
                 
                 if (attachment.image) {
                     //FLOG(@" attachment.image found");
                     osAttachment = [[PPTextAttachment alloc] initWithData:UIImagePNGRepresentation(attachment.image) ofType:attachment.fileType];
                 }
                 else {
                     //FLOG(@" attachment.image is nil");
                     osAttachment = [[PPTextAttachment alloc] initWithData:attachment.fileWrapper.regularFileContents ofType:attachment.fileType];
                 }
                 
                 [dict setValue:osAttachment forKey:key];
             }
             
         }];
         
         [textStorage setAttributes:dict range:range];
         
     }];
    
}
#endif
@end
