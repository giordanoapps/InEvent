//
//  WrapperViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 18/12/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WrapperViewController.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "CoolBarButtonItem.h"
#import "EventToken.h"
#import "HumanToken.h"
#import "UINavigationBar+Height.h"

@interface WrapperViewController () {
    UITapGestureRecognizer *behindRecognizer;
}

@property (assign, nonatomic) BOOL isUp;
@property (strong, nonatomic) APIController *apiController;
@property (strong, nonatomic) UIBarButtonItem *barButtonItem;

@end

@implementation WrapperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _shouldMoveKeyboardUp = YES;
        _moveKeyboardRatio = 1.0;
        _isUp = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Wrapper";
    
    // Navigation Bar
    if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"7.0"]) {
        self.navigationController.navigationBar.barTintColor = [ColorThemeController navigationBarBackgroundColor];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // We check if the back button is already set, so we have to preserve it
    // The navigationBar items is an array that counts how many controllers we already have on the stack
    if ([self.navigationController.viewControllers count] == 1 && self.presentingViewController == nil && ![[[self.splitViewController viewControllers] objectAtIndex:1] isEqual:self.navigationController]) {
        
        // Left Button
        _leftBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"20-Hamburguer-White"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0) target:self action:@selector(showSlidingMenu)];
        _leftBarButton.accessibilityLabel = NSLocalizedString(@"Menu Options", nil);
        _leftBarButton.accessibilityTraits = UIAccessibilityTraitButton;
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = 5;
        
        if ([self.navigationItem.leftBarButtonItems count] == 1) {
            NSMutableArray *barButtons = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
            [barButtons insertObject:negativeSpacer atIndex:0];
            [barButtons insertObject:_leftBarButton atIndex:1];
            self.navigationItem.leftBarButtonItems = barButtons;
        } else if ([self.navigationItem.leftBarButtonItems count] != 3) {
            self.navigationItem.leftBarButtonItems = @[negativeSpacer, _leftBarButton];
        }
    }
    
    // The Right Button may have different options across various controllers, so we can't declare it on the superclass
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Sliding Menu

- (void)showSlidingMenu {
    
    PaperFoldMenuController *menuController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] menuController];
    
    if (menuController.paperFoldView.state == PaperFoldStateDefault) {
        [menuController showMenu:YES animated:YES];
    } else {
        [menuController showMenu:NO animated:YES];
    }
}

#pragma mark - Keyboard Notifications

- (CGRect) calculateKeyboardFrame:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    UIView *mainSubviewOfWindow = window.rootViewController.view;
    CGRect keyboardFrameConverted = [mainSubviewOfWindow convertRect:keyboardFrame fromView:window];
    
    return keyboardFrameConverted;
    
    // keyboard frame is in window coordinates
//	NSDictionary *userInfo = [notification userInfo];
//	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//	// convert own frame to window coordinates, frame is in superview's coordinates
//	CGRect ownFrame = [self.view.window convertRect:self.view.frame fromView:self.view.superview];
//    
//	// calculate the area of own frame that is covered by keyboard
//	CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
//    
//	// now this might be rotated, so convert it back
//	coveredFrame = [self.view.window convertRect:coveredFrame toView:self.view.superview];
    
    return keyboardFrame;
}

- (void)keyboardWillShow:(NSNotification*)notification {

    // Only go up if the view is still DOWN and we should move the keyboard up
    if (!_isUp && _shouldMoveKeyboardUp) {
        [self moveViewUp:YES withNotification:notification];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {

    // Only go down if the view is UP
    if (_isUp) {
        [self moveViewUp:NO withNotification:notification];
    }
}


- (void)moveViewUp:(BOOL)moveUp withNotification:(NSNotification*)notification {
    // Move the view up/down whenever the keyboard is shown/dismissed

    // Set our property
    self.isUp = moveUp;
    
    CGRect keyboardFrame = [self calculateKeyboardFrame:notification];
    
    // We apply the transformation bound to the screen pixel density
    CGFloat offset = keyboardFrame.size.height * (_moveKeyboardRatio / [[UIScreen mainScreen] scale]);
    CGRect rect = self.view.frame;
    
    if (self.tabBarController) {
        offset -= self.tabBarController.tabBar.frame.size.height;
    }
    
    if (moveUp) {
        rect.origin.y -= offset;
    } else {
        rect.origin.y += offset;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = rect;
    }];
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    // Implement a method that allows every failing requisition to be reloaded
    
    AlertView *alertView;
    
    if ((int)(error.code / 100) == 5) {
        // We have a server error
        alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Oh oh.. It appears that our server is having some trouble. Do you want to try again?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitle:NSLocalizedString(@"Yes", nil)];
        
        [self setApiController:apiController];
        
    } else if (error.code == 401 || error.code == 204) {
        // We have a server error
        alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"It appears that your credentials expired! Can you log again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok!", nil)];
        
        // We check which permission we should remove
        if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
            [[HumanToken sharedInstance] removeMember];
        }
        
        // Update the current state of the schedule controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
        
        [self setApiController:nil];
        
    } else {
        alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Hum, it appears that the connectivity is unstable.. Do you want to try again?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitle:NSLocalizedString(@"Yes", nil)];
        
        [self setApiController:apiController];
    }
    
    [alertView setErrorCode:error.code];
    [alertView show];
}

#pragma mark - Alert View Delegate

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        if (alertView.errorCode == 401) {
            [[HumanToken sharedInstance] removeMember];
        } else if (_apiController != nil) {
            [_apiController start];
        }
    }
}

#pragma mark - Tap Behind methods

- (void)allocTapBehind {
    // Add the gesture recognizer
    behindRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [behindRecognizer setNumberOfTapsRequired:1];
    [behindRecognizer setCancelsTouchesInView:NO]; // So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:behindRecognizer];
}

- (void)deallocTapBehind {
    // Remove the gesture recognizer
    [self.view.window removeGestureRecognizer:behindRecognizer];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        // Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside.
        // If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Split View Controller Delegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.barButtonItem = barButtonItem;
    [self showRootPopoverButtonItem];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self invalidateRootPopoverButtonItem];
    self.barButtonItem = nil;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

#pragma mark - Split View Controller Rotation Methods

- (void)showRootPopoverButtonItem {
    // Append the button into the ones that we already have
    NSMutableArray *barButtons = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    if (_barButtonItem && ![barButtons containsObject:_barButtonItem]) [barButtons addObject:_barButtonItem];
    [self.navigationItem setLeftBarButtonItems:barButtons animated:YES];
}

- (void)invalidateRootPopoverButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    NSMutableArray *barButtons = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    [barButtons removeObject:_barButtonItem];
    [self.navigationItem setLeftBarButtonItems:barButtons animated:YES];
}

@end
