//
//  UIView+Components.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 23/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Components.h"
#import "ColorThemeController.h"

@implementation UIView (Components)

#pragma mark - Button
- (void)setUpButtonComponent:(UIButton *)price {
    [price.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [price.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:14.0]];
    [price setTag:0];
    [price setAlpha:0.75];
    [price setTitleColor:[ColorThemeController textColor] forState:UIControlStateNormal];
    [price setTitleColor:[ColorThemeController textColor] forState:UIControlStateHighlighted];
//    [price setTitleColor:[ColorThemeController tableViewCellTextHighlightedColor] forState:UIControlStateHighlighted];
    [price setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [price.layer setCornerRadius:4.0];
    [price.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [price.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [price.layer setShadowOpacity:1.0];
    [price.layer setShadowRadius:0.0];
    [price.layer setMasksToBounds:NO];
    [price.layer setBorderWidth:1.0];
    [price.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
    price.layer.shouldRasterize = YES;
    price.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    price.accessibilityLabel = NSLocalizedString(@"Order", nil);
    price.accessibilityHint = NSLocalizedString(@"Click twice to order", nil);
}

@end
