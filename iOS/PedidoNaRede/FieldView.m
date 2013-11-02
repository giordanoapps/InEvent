//
//  FieldView.m
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "FieldView.h"
#import "UIPlaceHolderTextView.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FieldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

// Setters
- (NSString *)text {
    if ([self isKindOfClass:[UIPlaceHolderTextView class]]) {
        return ((UIPlaceHolderTextView *)self).text;
    } else if ([self isKindOfClass:[UITextField class]]) {
        return ((UITextField *)self).text;
    }
    
    return @"";
}

- (void)setText:(NSString *)text {
    if ([self isKindOfClass:[UILabel class]]) {
        [self setText:((UILabel *)self).text];
    } else if ([self isKindOfClass:[UIButton class]]) {
        [self setText:((UIButton *)self).titleLabel.text];
    }
}

// Creation
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

- (UIView *)createField {
    return [self createFieldWithAttributes:nil];
}

- (UIView *)createFieldWithAttributes:(NSArray *)attributes {
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + 8.0f, self.frame.size.height + 4.0f)];
    [textView setBackgroundColor:self.backgroundColor];
//    [textView.layer setBorderColor:[[UIColor redColor] CGColor]];
//    [textView.layer setBorderWidth:0.4f];
    
    if (textView.frame.size.height < 30.0f) {
        [textView setScrollEnabled:NO];
    }
    
    if ([self isKindOfClass:[UILabel class]]) {
        [textView setPlaceholder:((UILabel *)self).text];
        [textView setText:((UILabel *)self).text];
        [textView setTextColor:((UILabel *)self).textColor];
        [textView setFont:((UILabel *)self).font];
        [textView setContentSize:CGSizeMake(self.frame.size.width, [((UILabel *)self).text sizeWithFont:((UILabel *)self).font].height + 2.0f)];
        [self calculateVerticalAlignment:textView];
        [textView setTextAlignment:((UILabel *)self).textAlignment];
    } else if ([self isKindOfClass:[UIButton class]]) {
        [textView setPlaceholder:((UIButton *)self).titleLabel.text];
        [textView setText:((UIButton *)self).titleLabel.text];
        [textView setTextColor:((UIButton *)self).titleLabel.textColor];
        [textView setFont:((UIButton *)self).titleLabel.font];
        [textView setContentSize:CGSizeMake(self.frame.size.width, [((UIButton *)self).titleLabel.text sizeWithFont:((UIButton *)self).titleLabel.font].height + 2.0f)];
        [self calculateVerticalAlignment:textView];
        UIEdgeInsets edgeInsets = ((UIButton *)self).contentEdgeInsets;
        [textView setContentInset:UIEdgeInsetsMake(edgeInsets.top - 6.5f, edgeInsets.left - 4.5f, edgeInsets.bottom, edgeInsets.right)];
        
        // Horizontal
        switch (((UIButton *)self).contentHorizontalAlignment) {
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
        switch (((UIButton *)self).contentVerticalAlignment) {
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
    
    } else if ([self isKindOfClass:[UITextView class]]) {
        [textView setPlaceholder:((UITextView *)self).text];
        [textView setText:((UITextView *)self).text];
        [textView setFont:((UITextView *)self).font];
    }
    
//    if ([attributes containsObject:@"trimPadding"]) [textView setContentInset:UIEdgeInsetsMake(-11, -8, 0, 0)];
    
    [[self superview] addSubview:textView];
    [self removeFromSuperview];
    
    return textView;
}

- (UIView *)removeField {
    return [self removeFieldBelowView:nil];
}

- (UIView *)removeFieldBelowView:(UIView *)awningView {
    UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
    [label setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width - 8.0f, self.frame.size.height - 4.0f)];
    [label setBackgroundColor:self.backgroundColor];
//    [label.layer setBorderColor:[[UIColor redColor] CGColor]];
//    [label.layer setBorderWidth:0.4f];
    [label setTitle:((UIPlaceHolderTextView *)self).text forState:UIControlStateNormal];
    [label setTitleColor:((UIPlaceHolderTextView *)self).textColor forState:UIControlStateNormal];
    [label.titleLabel setFont:((UIPlaceHolderTextView *)self).font];
    [label.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [label.titleLabel setNumberOfLines:2];

    if ([self isKindOfClass:[UIPlaceHolderTextView class]]) {
        
        // Horizontal
        switch (((UIPlaceHolderTextView *)self).textAlignment) {
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
        switch (((UIPlaceHolderTextView *)self).verticalAlignment) {
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
        
        UIEdgeInsets edgeInsets = ((UIPlaceHolderTextView *)self).contentInset;
        [label setContentEdgeInsets:UIEdgeInsetsMake(edgeInsets.top + 6.5f, edgeInsets.left + 4.5f, edgeInsets.bottom, edgeInsets.right)];

    } else if ([self isKindOfClass:[UITextField class]]) {
        [label setContentHorizontalAlignment:((UIButton *)self).contentHorizontalAlignment];
        [label setContentVerticalAlignment:((UIButton *)self).contentVerticalAlignment];
    }

    if (awningView) {
        [[self superview] insertSubview:label belowSubview:awningView];
    } else {
        [[self superview] addSubview:label];
    }
    
//    [label setNeedsDisplay];
    
    [self removeFromSuperview];
    
    return label;
}

- (BOOL)fieldDidChange {
    return ![((UIPlaceHolderTextView *)self).placeholder isEqualToString:((UIPlaceHolderTextView *)self).text];
}

@end
