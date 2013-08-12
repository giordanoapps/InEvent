//
//  UIViewController+Present.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 23/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "UIViewController+Present.h"
#import "CheckViewController.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "BenchMapViewController.h"
#import "DemoViewController.h"
#import "FeedbackViewController.h"
#import "HumanLoginViewController.h"
#import "TableToken.h"
#import "HumanToken.h"
#import "CompanyToken.h"
#import "CarteViewController.h"
#import "AKTabBarController.h"
#import "WaiterViewController.h"
#import "GAI.h"

@implementation UIViewController (Present)

#pragma mark - Verification

- (BOOL)verifyEnterprise {
    
    if (![[CompanyToken sharedInstance] isCompanySelected]) {

        UINavigationController *viewController;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedOnce"]) {
            // App already launched
            viewController = [[UINavigationController alloc] initWithRootViewController:[[MapViewController alloc] initWithNibName:nil bundle:nil]];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // This is the first launch ever
            viewController = [[UINavigationController alloc] initWithRootViewController:[[DemoViewController alloc] initWithNibName:nil bundle:nil]];
        }
        
        // iOS 6 bug
        [viewController setWantsFullScreenLayout:YES];
        [viewController setNavigationBarHidden:YES];
        [viewController setNavigationBarHidden:NO];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)verifyPerson {
    
    if (![[HumanToken sharedInstance] isMemberAuthenticated]) {
        
        HumanLoginViewController *hlvc = [[HumanLoginViewController alloc] initWithNibName:@"HumanLoginViewController" bundle:nil];
        [hlvc setMoveKeyboardRatio:0.7];
        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:hlvc];
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)verifyTable {
    return [self verifyTableForType:TableViewDataGeneral];
}

- (BOOL)verifyTableForType:(TableViewData)type {

    if (![[TableToken sharedInstance] isMemberAtTable] && [[CompanyToken sharedInstance] isCompanySelected]) {
        
        BenchMapViewController *tmvc = [[BenchMapViewController alloc] initWithNibName:nil bundle:nil];
        [tmvc setType:type];
        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:tmvc];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

- (void)verifyCheck {
    
    UINavigationController *fvc = [[UINavigationController alloc] initWithRootViewController:[[CheckViewController alloc] initWithNibName:@"CheckViewController" bundle:nil]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        fvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        fvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        fvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        fvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:fvc animated:YES completion:nil];
}

- (void)verifyFeedback {
    
    FeedbackViewController *fvc = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [fvc setShouldMoveKeyboardUp:YES];
        CGFloat ratio = (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) ? 0.05 : 0.5;
        [fvc setMoveKeyboardRatio:ratio];
    } else {
        [fvc setShouldMoveKeyboardUp:NO];
    }
    UINavigationController *wvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        wvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        wvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        wvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        wvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:wvc animated:YES completion:nil];
}

- (void)verifyWaiter {
    
    UINavigationController *wvc = [[UINavigationController alloc] initWithRootViewController:[[WaiterViewController alloc] initWithNibName:@"WaiterViewController" bundle:nil]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        wvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        wvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        wvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        wvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:wvc animated:YES completion:nil];
}


#pragma mark - Path Animation

- (void)animateAlongPathWithImageView:(UIImageView *)fixedImageView withRootTouch:(UITouch *)rootTouch withInternalPosition:(CGPoint)internalPosition {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fixedImageView.image];
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setCornerRadius:10.0];
    [imageView.layer setBorderWidth:5.0];
    [imageView.layer setBorderColor:[[UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0] CGColor]];
    
    // Calculate the shift between the touch and the imageView
    CGRect imageFrame = fixedImageView.frame;
    CGSize size = CGSizeMake(internalPosition.x - imageFrame.origin.x, internalPosition.y - imageFrame.origin.y);
    
    // Calculate the root position
    CGPoint rootPosition = [rootTouch locationInView:self.view.window.rootViewController.view];
    
    // Update all the coordinates, shifting it to the middle, applying the internal shift and setting it to the rootView
    imageFrame.origin.y = imageFrame.origin.y + imageFrame.size.height / 2.0f - size.height + rootPosition.y;
    imageFrame.origin.x = imageFrame.origin.x + imageFrame.size.width / 2.0f - size.width + rootPosition.x;
    
    // Apply all the calculated coordinates
    imageView.frame = imageFrame;
    imageView.layer.position = imageFrame.origin;
    
    // Add the imageView to the rootViewController
    [self.view.window.rootViewController.view addSubview:imageView];
    
    // Calculating begin point
    CGPoint beginPoint = CGPointMake(imageFrame.origin.x, imageFrame.origin.y);
    
    // Calculating end point
//    UITabBar *tabBar = self.tabBarController.tabBar;
//    CGFloat tabBarStart = (tabBar.frame.size.width - ([tabBar.items count] * TABBARITEM_WIDTH)) / 2.0f;
//    CGFloat endX = tabBarStart + (TABBARITEM_WIDTH * 1) + (TABBARITEM_WIDTH / 2);
//    CGFloat endY = tabBar.frame.origin.y + (tabBar.frame.size.height / 2);
//    CGPoint endPoint = CGPointMake(endX, endY);

    // Calculating end point
    NSInteger numberControllers = 2;
    if ([[CompanyToken sharedInstance] chatAvailable]) numberControllers++;
    
    // We calculate the number of controllers based on our current allocation and we proceed to the one in middle, always the order controller
    CGFloat endX = (self.view.frame.size.width / (float)numberControllers) * 1.5f;
    CGFloat endY = self.view.frame.size.height;
    CGPoint endPoint = CGPointMake(endX, endY);
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.2]];
    fadeOutAnimation.fillMode = kCAFillModeRemoved;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up scaling
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(40.0f, imageView.frame.size.height * (40.0f / imageView.frame.size.width))]];
    resizeAnimation.fillMode = kCAFillModeRemoved;
    resizeAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationCubic;
    pathAnimation.fillMode = kCAFillModeRemoved;
    pathAnimation.removedOnCompletion = NO;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, beginPoint.x, beginPoint.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, endPoint.x, beginPoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeRemoved;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, resizeAnimation, nil]];
    group.duration = 0.7f;
    group.delegate = self;
    [group setValue:imageView forKey:@"imageViewBeingAnimated"];
    
    [imageView.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    UIImageView *imageView = [animation valueForKey:@"imageViewBeingAnimated"];
//    UIImageView *imageView = [self.view.window.rootViewController.view.subviews lastObject];
    [imageView removeFromSuperview];
}

@end
