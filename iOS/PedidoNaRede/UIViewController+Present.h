//
//  UIViewController+Present.h
//  InEvent
//
//  Created by Pedro Góes on 23/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface UIViewController (Present) <AdViewControllerDelegate>

- (BOOL)verifyEvent;
- (BOOL)verifyPerson;
- (BOOL)verifyAd;

@end
