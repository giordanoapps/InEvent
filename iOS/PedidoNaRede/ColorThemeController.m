//
//  ColorThemeController.m
//  InEvent
//
//  Created by Pedro Góes on 22/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "ColorThemeController.h"
#import "SebraeColorThemeController.h"

@implementation ColorThemeController

#pragma mark - Singleton

+ (ColorThemeController *)sharedInstance
{
    static ColorThemeController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ColorThemeController alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

#pragma mark - Global

+ (UIColor *)backgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:194.0/255.0 green:207.0/255.0 blue:237.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)borderColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithWhite:0.200 alpha:1.000];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithWhite:0.200 alpha:1.000];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)shadowColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)textColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

#pragma mark - Navigator Bar

+ (ColorThemeController *)findChild {
    return (SebraeColorThemeController *)self;
}

+ (UIColor *)navigationBarBackgroundColor {
    
    return [[self findChild] naviga]

	// Init and switch
//	switch ([[self sharedInstance] theme]) {
//		case ColorThemeOceanWater:
//			return [UIColor colorWithRed:54.0/255.0 green:86.0/255.0 blue:142.0/255.0 alpha:1.0];
//			break;
//
//		case ColorThemePetoskeyStone:
////            return [UIColor colorWithPatternImage:[UIImage imageNamed:@"AKTabBarController.bundle/noise-pattern"]];
//			return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//			break;
//
//		case ColorThemeForestLeaf:
//			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
//			break;
//
//		case ColorThemeRosePetal:
//			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
//			break;
//	}
}

+ (UIColor *)navigationBarTextColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}


#pragma mark - Navigator Item

+ (UIColor *)navigationItemBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor clearColor];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor clearColor];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)navigationItemBorderColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:8.0/255.0 green:20.0/255.0 blue:74.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)navigationItemShadowColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)navigationItemTextColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [self navigationBarTextColor];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}


#pragma mark - Tab Bar

+ (UIColor *)tabBarBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:11.0/255.0 green:5.0/255.0 blue:31.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
            return [UIColor colorWithPatternImage:[UIImage imageNamed:@"AKTabBarController.bundle/noise-pattern"]];
//			return [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tabBarSelectedBackgroundColor {
    
    	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:11.0/255.0 green:5.0/255.0 blue:31.0/255.0 alpha:1.0];
			break;
            
		case ColorThemePetoskeyStone:
            return [UIColor colorWithPatternImage:[UIImage imageNamed:@"AKTabBarController.bundle/noise-pattern"]];
			break;
            
		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
            
		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

#pragma mark - Tab Bar Item

+ (UIColor *)tabBarItemBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor clearColor];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor clearColor];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tabBarItemSelectionBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tabBarItemTextColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [self navigationBarTextColor];
			break;

		case ColorThemePetoskeyStone:
			return [self navigationBarTextColor];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}


#pragma mark - Table View

+ (UIColor *)tableViewBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:194.0/255.0 green:207.0/255.0 blue:237.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}


#pragma mark - Table View Cell

+ (UIColor *)tableViewCellBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:224.0 green:228.0 blue:255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellSelectedBackgroundColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:194.0/255.0 green:207.0/255.0 blue:237.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellInternalBorderColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:224.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellBorderColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:127.0/255.0 green:138.0/255.0 blue:173.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
            return [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellShadowColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellTextColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}

+ (UIColor *)tableViewCellTextHighlightedColor {

	// Init and switch
	switch ([[self sharedInstance] theme]) {
		case ColorThemeOceanWater:
			return [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0];
			break;

		case ColorThemePetoskeyStone:
			return [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0];
			break;

		case ColorThemeForestLeaf:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;

		case ColorThemeRosePetal:
			return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
			break;
	}
}




@end
