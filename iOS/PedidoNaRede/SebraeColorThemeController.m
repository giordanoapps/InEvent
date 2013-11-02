//
//  SebraeColorThemeController.m
//  InEvent
//
//  Created by Pedro Góes on 17/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "SebraeColorThemeController.h"
#import "UtilitiesController.h"

@implementation SebraeColorThemeController

#pragma mark - Global

+ (UIColor *)backgroundColor {
    return [UtilitiesController colorFromHexString:@"#208cd7"];
}

+ (UIColor *)borderColor {
//    return [UIColor colorWithWhite:0.200 alpha:1.000];
    return [UtilitiesController colorFromHexString:@"#FFFFFF"];
}

+ (UIColor *)shadowColor {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)textColor {
    return [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
}

#pragma mark - Navigator Bar

+ (UIColor *)navigationBarBackgroundColor {
    return [UtilitiesController colorFromHexString:@"#208cd7"];
}

+ (UIColor *)navigationBarTextColor {
    return [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
}


#pragma mark - Navigator Item

+ (UIColor *)navigationItemBackgroundColor {
    return [UIColor clearColor];
}

+ (UIColor *)navigationItemBorderColor {
    return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *)navigationItemShadowColor {
    return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
}

+ (UIColor *)navigationItemTextColor {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}


#pragma mark - Tab Bar

+ (UIColor *)tabBarBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"AKTabBarController.bundle/noise-pattern"]];
}

+ (UIColor *)tabBarSelectedBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"AKTabBarController.bundle/noise-pattern"]];
}

#pragma mark - Tab Bar Item

+ (UIColor *)tabBarItemBackgroundColor {
    return [UIColor clearColor];
}

+ (UIColor *)tabBarItemSelectionBackgroundColor {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)tabBarItemTextColor {
    return [self navigationBarTextColor];
}


#pragma mark - Table View

+ (UIColor *)tableViewBackgroundColor {
    return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
}


#pragma mark - Table View Cell

+ (UIColor *)tableViewCellBackgroundColor {
    return [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellSelectedBackgroundColor {
    return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellInternalBorderColor {
    return [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellBorderColor {
    return [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellShadowColor {
    return [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellTextColor {
    return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellTextHighlightedColor {
    return [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0];
}




@end
