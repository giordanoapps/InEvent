//
//  UIImage+Color.h
//  InEvent
//
//  Created by Pedro Góes on 13/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

- (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)frame;
- (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)frame withRadius:(CGFloat)radius;
- (UIImage *)imageForDashedBorderWidth:(CGFloat)width withColor:(UIColor *)color;

@end
