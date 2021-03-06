//
//  UIViewController+Present.m
//  InEvent
//
//  Created by Pedro Góes on 23/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "UIViewController+Present.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "MarketplaceViewController.h"
#import "DemoViewController.h"
#import "FeedbackViewController.h"
#import "SocialLoginViewController.h"
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
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)verifyEvent {
    
    // See if the demo has been presented
    [self verifyDemo];
    
    if (![[EventToken sharedInstance] isEventSelected]) {

        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:[[MarketplaceViewController alloc] initWithNibName:nil bundle:nil]];
              
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
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)verifyPerson {
    
    if (![[HumanToken sharedInstance] isMemberAuthenticated]) {
        
        SocialLoginViewController *hlvc = [[SocialLoginViewController alloc] initWithNibName:@"SocialLoginViewController" bundle:nil];
        UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:hlvc];
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)verifyAd {
    
    AdViewController *avc = [[AdViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
    [avc setDelegate:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        avc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        avc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        avc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        avc.modalPresentationStyle = UIModalPresentationFullScreen;
    }
        
    return YES;
}

#pragma mark - Ad Delegate

- (void)adController:(AdViewController *)adController shouldLoadController:(BOOL)shouldLoad {
    // Only load the ad if there is any
    if (shouldLoad) {
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:adController animated:YES completion:nil];
    }
}

@end
