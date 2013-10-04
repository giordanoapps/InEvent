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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    // Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

- (UIView *)createField:(UIView *)field {
    return [self createField:field withAttributes:nil];
}

- (UIView *)createField:(UIView *)field withAttributes:(NSArray *)attributes {
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:field.frame];
    [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
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
        [textView setTextAlignment:((UILabel *)field).textAlignment];
        [textView setFont:((UILabel *)field).font];
    } else if ([field isKindOfClass:[UIButton class]]) {
        [textView setPlaceholder:((UIButton *)field).titleLabel.text];
        [textView setText:((UIButton *)field).titleLabel.text];
        [textView setTextColor:((UIButton *)field).titleLabel.textColor];
        [textView setTextAlignment:((UIButton *)field).titleLabel.textAlignment];
        [textView setFont:((UIButton *)field).titleLabel.font];
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
    UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
    [label setFrame:field.frame];
    [label setBackgroundColor:field.backgroundColor];
    [label setTitle:((UIPlaceHolderTextView *)field).text forState:UIControlStateNormal];
    [label setTitleColor:((UIPlaceHolderTextView *)field).textColor forState:UIControlStateNormal];
    [label.titleLabel setFont:((UIPlaceHolderTextView *)field).font];
    [label.titleLabel setNumberOfLines:2];
    [label.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [label setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    [field removeObserver:self forKeyPath:@"contentSize"];

    [[field superview] addSubview:label];
    [field removeFromSuperview];
    
    return label;
}

@end
