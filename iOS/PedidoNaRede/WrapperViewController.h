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

@interface WrapperViewController : GAITrackedViewController <UIActionSheetDelegate, UITextFieldDelegate, APIControllerDelegate, UISplitViewControllerDelegate, AlertViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) UIBarButtonItem *leftBarButton;
@property (assign, nonatomic) BOOL shouldMoveKeyboardUp;
@property (assign, nonatomic) CGFloat moveKeyboardRatio;
@property (assign, nonatomic) WrapperViewController *decentPresentingViewController;

// Keyboard
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;

// Tap Behind
- (void)allocTapBehind;
- (void)deallocTapBehind;
- (void)handleTapBehind:(UITapGestureRecognizer *)sender;

@end
