//
//  UITabBarController+ShowHideBar.m
//  Garça
//
//  Created by Pedro Góes on 08/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "UITabBarController+ShowHideBar.h"

@implementation UITabBarController (ShowHideBar)

- (void)setHidden:(BOOL)hidden{
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    float fHeight = screenRect.size.height;
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        fHeight = screenRect.size.width;
    }

    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                CGFloat tabOffset = (hidden) ? fHeight : fHeight - self.tabBar.frame.size.height;
                
                [view setFrame:CGRectMake(view.frame.origin.x, tabOffset, view.frame.size.width, view.frame.size.height)];
            } else {
                CGFloat tabPadding = (hidden) ? 0.0 : self.tabBar.frame.size.height;
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight - view.frame.origin.y - tabPadding)];
            }
        }
    } completion:NULL];
    
}

@end
