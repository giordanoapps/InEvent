//
//  UIViewController+Present.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 23/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "UIViewController+Present.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "DemoViewController.h"
#import "FeedbackViewController.h"
#import "HumanLoginViewController.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "AKTabBarController.h"
#import "GAI.h"

@implementation UIViewController (Present)

#pragma mark - Verification

- (BOOL)verifyDemo {
        
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // This is the first launch ever
        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:[[DemoViewController alloc] initWithNibName:nil bundle:nil]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)verifyEvent {
    
    // See if the demo has been presented
    [self verifyDemo];
    
    if (![[EventToken sharedInstance] isEventSelected]) {

        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:[[MapViewController alloc] initWithNibName:nil bundle:nil]];
              
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

@end
