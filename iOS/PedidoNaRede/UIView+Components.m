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
- (void)setUpButtonComponent:(UIButton *)button {
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16.0]];
    [button setTag:0];
    [button setAlpha:0.75];
    [button setTitleColor:[ColorThemeController textColor] forState:UIControlStateNormal];
    [button setTitleColor:[ColorThemeController textColor] forState:UIControlStateHighlighted];
//    [button setTitleColor:[ColorThemeController tableViewCellTextHighlightedColor] forState:UIControlStateHighlighted];
    [button removeComponentProperties:button];
    button.layer.shouldRasterize = YES;
    button.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)addComponentProperties:(UIButton *)button {
    [button setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [button.layer setCornerRadius:4.0];
    [button.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [button.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [button.layer setShadowOpacity:1.0];
    [button.layer setShadowRadius:0.0];
    [button.layer setMasksToBounds:NO];
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
}

- (void)removeComponentProperties:(UIButton *)button {
    [button setBackgroundColor:[UIColor clearColor]];
    [button.layer setCornerRadius:0.0];
    [button.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [button.layer setShadowRadius:0.0];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:0.0];
}

@end
