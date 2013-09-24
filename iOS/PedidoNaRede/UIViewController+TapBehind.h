//
//  UIViewController+TapBehind.h
//  InEvent
//
//  Created by Pedro Góes on 24/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TapBehind)

- (void)allocTapBehind;
- (void)handleTapBehind:(UITapGestureRecognizer *)sender;

@end
