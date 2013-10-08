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

- (void)calculateVerticalAlignment:(UIPlaceHolderTextView *)view {
    
    // Top vertical alignment
    if (view.verticalAlignment == UIPlaceHolderTextViewVerticalAlignmentTop) {
        //        CGFloat topCorrect = ([self bounds].size.height - [self contentSize].height * [self zoomScale])/2.0;
        //        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        //        self.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
        
        // Center vertical alignment
    } else if (view.verticalAlignment == UIPlaceHolderTextViewVerticalAlignmentCenter) {
        CGFloat topCorrect = ([view bounds].size.height - [view contentSize].height * [view zoomScale]) / 2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        view.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
        
        // Bottom vertical alignment
    } else if (view.verticalAlignment == UIPlaceHolderTextViewVerticalAlignmentBottom) {
        CGFloat topCorrect = ([view bounds].size.height - [view contentSize].height);
        topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
        view.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}

- (UIView *)createField:(UIView *)field {
    return [self createField:field withAttributes:nil];
}

- (UIView *)createField:(UIView *)field withAttributes:(NSArray *)attributes {
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(field.frame.origin.x, field.frame.origin.y, field.frame.size.width + 4.0f, field.frame.size.height)];
    [textView setBackgroundColor:field.backgroundColor];
//    [textView.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [textView.layer setBorderColor:[[UIColor redColor] CGColor]];
    [textView.layer setBorderWidth:0.4f];
    
    if (textView.frame.size.height < 30.0f) {
        [textView setScrollEnabled:NO];
    }
    
    if ([field isKindOfClass:[UILabel class]]) {
        [textView setPlaceholder:((UILabel *)field).text];
        [textView setText:((UILabel *)field).text];
        [textView setTextColor:((UILabel *)field).textColor];
        [textView setFont:((UILabel *)field).font];
        [textView setContentSize:CGSizeMake(field.frame.size.width, [((UILabel *)field).text sizeWithFont:((UILabel *)field).font].height + 2.0f)];
        [textView setTextAlignment:((UILabel *)field).textAlignment];
    } else if ([field isKindOfClass:[UIButton class]]) {
        [textView setPlaceholder:((UIButton *)field).titleLabel.text];
        [textView setText:((UIButton *)field).titleLabel.text];
        [textView setTextColor:((UIButton *)field).titleLabel.textColor];
        [textView setFont:((UIButton *)field).titleLabel.font];
        [textView setContentSize:CGSizeMake(field.frame.size.width, [((UIButton *)field).titleLabel.text sizeWithFont:((UIButton *)field).titleLabel.font].height + 2.0f)];
        [self calculateVerticalAlignment:textView];
        UIEdgeInsets edgeInsets = ((UIButton *)field).contentEdgeInsets;
        [textView setContentInset:UIEdgeInsetsMake(edgeInsets.top - 8, edgeInsets.left, edgeInsets.bottom, edgeInsets.right)];
        
        // Horizontal
        switch (((UIButton *)field).contentHorizontalAlignment) {
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
    
//    if ([attributes containsObject:@"trimPadding"]) [textView setContentInset:UIEdgeInsetsMake(-11, -8, 0, 0)];
    
    [[field superview] addSubview:textView];
    [field removeFromSuperview];
    
    return textView;
}

- (UIView *)removeField:(UIView *)field {
    return [self removeField:field belowView:nil];
}

- (UIView *)removeField:(UIView *)field belowView:(UIView *)awningView {
    UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
    [label setFrame:CGRectMake(field.frame.origin.x, field.frame.origin.y, field.frame.size.width - 4.0f, field.frame.size.height)];
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
        
        UIEdgeInsets edgeInsets = ((UIPlaceHolderTextView *)field).contentInset;
        [label setContentEdgeInsets:UIEdgeInsetsMake(edgeInsets.top + 8, edgeInsets.left, edgeInsets.bottom, edgeInsets.right)];

    } else if ([field isKindOfClass:[UITextField class]]) {
        [label setContentHorizontalAlignment:((UIButton *)field).contentHorizontalAlignment];
        [label setContentVerticalAlignment:((UIButton *)field).contentVerticalAlignment];
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
