//
//  UIPlaceHolderTextView.h
//  InEvent
//
//  Created by Pedro Góes on 24/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UIPlaceHolderTextViewVerticalAlignmentTop = -1,
    UIPlaceHolderTextViewVerticalAlignmentCenter,
    UIPlaceHolderTextViewVerticalAlignmentBottom
} UIPlaceHolderTextViewVerticalAlignment;

@interface UIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    
@private
    UILabel *placeHolderLabel;
}

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, assign) UIPlaceHolderTextViewVerticalAlignment verticalAlignment;

- (void)textChanged:(NSNotification*)notification;

@end
