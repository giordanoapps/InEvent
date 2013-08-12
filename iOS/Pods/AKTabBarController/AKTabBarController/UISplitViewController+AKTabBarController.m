//
//  UISplitViewController+AKTabBarController.m
//  Pods
//
//  Created by Pedro Góes on 15/04/13.
//
//

#import "UISplitViewController+AKTabBarController.h"

@implementation UISplitViewController (AKTabBarController)

- (NSString *)tabImageName
{
	return [[self.viewControllers objectAtIndex:0] tabImageName];
}

- (NSString *)tabTitle
{
	return [[self.viewControllers objectAtIndex:0] tabTitle];
}

@end
