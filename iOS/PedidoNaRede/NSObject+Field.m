//
//  NSObject+Field.m
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "NSObject+Field.h"
#import "UIPlaceHolderTextView.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSObject (Field)

- (UIView *)createField:(UIView *)field {
    return [self createField:field withAttributes:nil];
}

- (UIView *)createField:(UIView *)field withAttributes:(NSArray *)attributes {
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:field.frame];
    [textView setBackgroundColor:field.backgroundColor];
    if ([attributes containsObject:@"trimPadding"]) [textView setContentInset:UIEdgeInsetsMake(-11, -8, 0, 0)];
//    [textView.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [textView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [textView.layer setBorderWidth:0.4f];
    [textView.layer setCornerRadius:4.0f];
    
    if (textView.frame.size.height < 30.0f) {
        [textView setScrollEnabled:NO];
    }
    
    if ([field isKindOfClass:[UILabel class]]) {
        [textView setPlaceholder:((UILabel *)field).text];
        [textView setText:((UILabel *)field).text];
        [textView setTextColor:((UILabel *)field).textColor];
        [textView setFont:((UILabel *)field).font];
        [textView setTextAlignment:((UILabel *)field).textAlignment];
    } else if ([field isKindOfClass:[UIButton class]]) {
        [textView setPlaceholder:((UIButton *)field).titleLabel.text];
        [textView setText:((UIButton *)field).titleLabel.text];
        [textView setTextColor:((UIButton *)field).titleLabel.textColor];
        [textView setFont:((UIButton *)field).titleLabel.font];
        [textView setContentInset:((UIButton *)field).contentEdgeInsets];
        
        // Horizontal
        switch (((UIButton *)field).titleLabel.textAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                [textView setTextAlignment:NSTextAlignmentLeft];
                break;
                
            case UIControlContentHorizontalAlignmentCenter:
                [textView setTextAlignment:NSTextAlignmentCenter];
                break;
                
            case UIControlContentHorizontalAlignmentRight:
                [textView setTextAlignment:NSTextAlignmentRight];
                break;
                
            default:
                break;
        }
        
        // Vertical
        switch (((UIButton *)field).contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                [textView setVerticalAlignment:UIPlaceHolderTextViewVerticalAlignmentTop];
                break;
                
            case UIControlContentVerticalAlignmentCenter:
                [textView setVerticalAlignment:UIPlaceHolderTextViewVerticalAlignmentCenter];
                break;
                
            case UIControlContentVerticalAlignmentBottom:
                [textView setVerticalAlignment:UIPlaceHolderTextViewVerticalAlignmentBottom];
                break;
                
            default:
                break;
        }
    
    } else if ([field isKindOfClass:[UITextView class]]) {
        [textView setPlaceholder:((UITextView *)field).text];
        [textView setText:((UITextView *)field).text];
        [textView setFont:((UITextView *)field).font];
    }
    
    [[field superview] addSubview:textView];
    [field removeFromSuperview];
    
    return textView;
}

- (UIView *)removeField:(UIView *)field {
    return [self removeField:field belowView:nil];
}

- (UIView *)removeField:(UIView *)field belowView:(UIView *)awningView {
    UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
    [label setFrame:field.frame];
    [label setBackgroundColor:field.backgroundColor];
    [label setTitle:((UIPlaceHolderTextView *)field).text forState:UIControlStateNormal];
    [label setTitleColor:((UIPlaceHolderTextView *)field).textColor forState:UIControlStateNormal];
    [label.titleLabel setFont:((UIPlaceHolderTextView *)field).font];
    [label.titleLabel setNumberOfLines:2];
    [label.titleLabel setLineBreakMode:UILineBreakModeWordWrap];

    if ([field isKindOfClass:[UIPlaceHolderTextView class]]) {
        
        // Horizontal
        switch (((UIPlaceHolderTextView *)field).textAlignment) {
            case NSTextAlignmentLeft:
                [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                break;
                
            case NSTextAlignmentCenter:
                [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                break;
                
            case NSTextAlignmentRight:
                [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                break;
                
            default:
                break;
        }
        
        // Vertical
        switch (((UIPlaceHolderTextView *)field).verticalAlignment) {
            case UIPlaceHolderTextViewVerticalAlignmentTop:
                [label setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
                break;
                
            case UIPlaceHolderTextViewVerticalAlignmentCenter:
                [label setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                break;
                
            case UIPlaceHolderTextViewVerticalAlignmentBottom:
                [label setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
                break;
        }
        
        [label setContentEdgeInsets:((UIPlaceHolderTextView *)field).contentInset];

    } else if ([field isKindOfClass:[UIButton class]]) {
        [label setContentHorizontalAlignment:((UIButton *)field).contentHorizontalAlignment];
        [label setContentVerticalAlignment:((UIButton *)field).contentVerticalAlignment];
    } else {
        [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [label setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    }

    if (awningView) {
        [[field superview] insertSubview:label belowSubview:awningView];
    } else {
        [[field superview] addSubview:label];
    }
    
    [field removeFromSuperview];
    
    return label;
}

@end
