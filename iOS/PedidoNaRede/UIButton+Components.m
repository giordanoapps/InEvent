//
//  UIButton+Components.m
//  InEvent
//
//  Created by Pedro Góes on 23/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIButton+Components.h"
#import "ColorThemeController.h"

@implementation UIButton (Components)

#pragma mark - Button
- (void)setUpButtonComponent {
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16.0]];
    [self setTag:0];
    [self setAlpha:0.75];
    [self setTitleColor:[ColorThemeController textColor] forState:UIControlStateNormal];
    [self setTitleColor:[ColorThemeController textColor] forState:UIControlStateHighlighted];
//    [self setTitleColor:[ColorThemeController tableViewCellTextHighlightedColor] forState:UIControlStateHighlighted];
    [self removeComponentProperties];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)addComponentProperties {
    [self setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [self.layer setCornerRadius:4.0];
    [self.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.layer setShadowOpacity:1.0];
    [self.layer setShadowRadius:0.0];
    [self.layer setMasksToBounds:NO];
    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
}

- (void)removeComponentProperties {
    [self setBackgroundColor:[UIColor clearColor]];
    [self.layer setCornerRadius:0.0];
    [self.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [self.layer setShadowRadius:0.0];
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderWidth:0.0];
}

@end
