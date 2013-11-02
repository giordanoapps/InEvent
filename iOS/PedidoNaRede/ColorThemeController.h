//
//  ColorThemeController.h
//  InEvent
//
//  Created by Pedro Góes on 22/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorThemeController : UIColor

typedef enum {
    ColorThemeOceanWater = 0,
    ColorThemePetoskeyStone,
    ColorThemeForestLeaf,
    ColorThemeRosePetal
} ColorThemeType;

@property (assign, nonatomic) ColorThemeType theme;

+ (ColorThemeController *)sharedInstance;

#pragma mark - Global

+ (UIColor *)backgroundColor;
+ (UIColor *)borderColor;
+ (UIColor *)shadowColor;
+ (UIColor *)textColor;

#pragma mark - Navigator Bar

+ (UIColor *)navigationBarBackgroundColor;
+ (UIColor *)navigationBarTextColor;

#pragma mark - Navigator Item

+ (UIColor *)navigationItemBackgroundColor;
+ (UIColor *)navigationItemBorderColor;
+ (UIColor *)navigationItemShadowColor;
+ (UIColor *)navigationItemTextColor;

#pragma mark - Tab Bar

+ (UIColor *)tabBarBackgroundColor;
+ (UIColor *)tabBarSelectedBackgroundColor;

#pragma mark - Tab Bar Item

+ (UIColor *)tabBarItemBackgroundColor;
+ (UIColor *)tabBarItemSelectionBackgroundColor;
+ (UIColor *)tabBarItemTextColor;

#pragma mark - Table View

+ (UIColor *)tableViewBackgroundColor;

#pragma mark - Table View Cell

+ (UIColor *)tableViewCellBackgroundColor;
+ (UIColor *)tableViewCellSelectedBackgroundColor;
+ (UIColor *)tableViewCellInternalBorderColor;
+ (UIColor *)tableViewCellBorderColor;
+ (UIColor *)tableViewCellShadowColor;
+ (UIColor *)tableViewCellTextColor;
+ (UIColor *)tableViewCellTextHighlightedColor;

@end
