//
//  AdViewController.h
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@class AdViewController;

@protocol AdViewControllerDelegate <NSObject>
@optional
- (void)adController:(AdViewController *)adController shouldLoadController:(BOOL)shouldLoad;

@end

@interface AdViewController : WrapperViewController <APIControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<AdViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *piece;

@end
