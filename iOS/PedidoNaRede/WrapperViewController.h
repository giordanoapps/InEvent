//
//  WrapperViewController.h
//  InEvent
//
//  Created by Pedro Góes on 18/12/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIController.h"
#import "ColorThemeController.h"
#import "AlertView.h"
#import "GAITrackedViewController.h"

@interface WrapperViewController : GAITrackedViewController <UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, APIControllerDelegate, UISplitViewControllerDelegate, AlertViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) UIBarButtonItem *leftBarButton;
@property (assign, nonatomic) WrapperViewController *decentPresentingViewController;

// Tap Behind
- (void)allocTapBehind;
- (void)deallocTapBehind;
- (void)handleTapBehind:(UITapGestureRecognizer *)sender;

@end
