//
//  HumanLoginViewController.m
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "HumanLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "AppDelegate.h"
#import "APIController.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "EventToken.h"

@interface HumanLoginViewController ()

@end

@implementation HumanLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(cancelButtonWasPressed)];
    
    [self.view setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [(UIControl *)self.view addTarget:self action:@selector(hideEmployeeBox) forControlEvents:UIControlEventTouchUpInside];
    
    
    // ---------------------
    // Top Wrapper
    // ---------------------
    [_topBox setBackgroundColor:[ColorThemeController backgroundColor]];
    [_topBox addTarget:self action:@selector(hideEmployeeBox) forControlEvents:UIControlEventTouchUpInside];
    
    [_facebook setBackgroundImage:[UIImage imageNamed:@"facebookButton"] forState:UIControlStateNormal];
    [_facebook setTitle:@"" forState:UIControlStateNormal];
    [_facebook addTarget:self action:@selector(loginFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    [_separator1 setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    
    // ---------------------
    // Bottom Wrapper
    // ---------------------
    [_bottomBox setBackgroundColor:[ColorThemeController backgroundColor]];
    [_bottomBox.layer setMasksToBounds:YES];

    [_separator2 setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    
    // Employee toggle button
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_waiter setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_waiter setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_waiter setTitle:NSLocalizedString(@"Person", nil) forState:UIControlStateNormal];
    [_waiter addTarget:self action:@selector(toggleEmployeeBox) forControlEvents:UIControlEventTouchUpInside];
    
    // Padding views
    UIView *waiterUsernamePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *waiterPasswordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    // Employee Field Wrapper
	_waiterFieldWrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    [_waiterFieldWrapper.layer setCornerRadius:8.0];
    [_waiterFieldWrapper.layer setBorderWidth:1.0];
    [_waiterFieldWrapper.layer setBorderColor:[[ColorThemeController tableViewCellBorderColor] CGColor]];

	// Employee username field
    _waiterUsername.backgroundColor = [UIColor clearColor];
    _waiterUsername.borderStyle = UITextBorderStyleNone;
    _waiterUsername.delegate = self;
    _waiterUsername.frame = CGRectMake(0.0, 0.0, 218.0, 50.0);
    _waiterUsername.leftView = waiterUsernamePaddingView;
    _waiterUsername.leftViewMode = UITextFieldViewModeAlways;
    _waiterUsername.keyboardType = UIKeyboardTypeASCIICapable;
	_waiterUsername.placeholder = NSLocalizedString(@"Name", nil);
	_waiterUsername.textColor = [UIColor colorWithWhite:0.000 alpha:1.000];
    // Bottom Border
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, _waiterUsername.frame.size.height - 1.0f, _waiterUsername.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [[ColorThemeController tableViewCellBorderColor] CGColor];
    [_waiterUsername.layer addSublayer:bottomBorder];
    
	// Employee password field
    _waiterPassword.backgroundColor = [UIColor clearColor];
    _waiterPassword.borderStyle = UITextBorderStyleNone;
    _waiterPassword.delegate = self;
    _waiterPassword.frame = CGRectMake(0.0, 50.0, 218.0, 50.0);
    _waiterPassword.leftView = waiterPasswordPaddingView;
    _waiterPassword.leftViewMode = UITextFieldViewModeAlways;
    _waiterPassword.keyboardType = UIKeyboardTypeASCIICapable;
	_waiterPassword.placeholder = NSLocalizedString(@"Password", nil);
	_waiterPassword.textColor = [ColorThemeController textColor];
    
	// Employee login button
	[_waiterButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    [_waiterButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_waiterButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_waiterButton addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    [_waiterButton.layer setCornerRadius:8.0];

    
    // ---------------------
    // Reset the employee box state
    // ---------------------
    [self toggleEmployeeBoxWithDuration:0.0 andHideIt:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Methods

- (void)cancelButtonWasPressed {
    PaperFoldMenuController *menuController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] menuController];
    [menuController setSelectedIndex:1];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }];
}

- (void)hideEmployeeBox {
    [self toggleEmployeeBoxWithDuration:0.5 andHideIt:YES];
}

- (void)toggleEmployeeBox {
    [self toggleEmployeeBoxWithDuration:0.5 andHideIt:NO];
}

- (void)toggleEmployeeBoxWithDuration:(CGFloat)duration andHideIt:(BOOL)hide {
    
    CGRect frameBox, frameInternal;
    
    if (_bottomInternalBox.frame.origin.y == 0.0 && hide == NO) {
        // Show
        frameBox = _bottomBox.frame;
        frameBox.origin.y = self.view.frame.size.height - frameBox.size.height;
        
        frameInternal = _bottomInternalBox.frame;
        frameInternal.origin.y = frameInternal.origin.y - frameInternal.size.height / 4.0;
        
    } else {
        // Hide
        frameBox = _bottomBox.frame;
        frameBox.origin.y = self.view.frame.size.height - frameBox.size.height / 4.0;
        
        frameInternal = _bottomInternalBox.frame;
        frameInternal.origin.y = 0.0;
    }
    
    // Animate
    [UIView animateWithDuration:duration animations:^{
        [_bottomBox setFrame:frameBox];
        [_bottomInternalBox setFrame:frameInternal];
    }];
}

#pragma - Login Methods

- (void)logIn {
    
    // Set loading message on button
    [_waiterButton setTitle:NSLocalizedString(@"Logging ...", nil) forState:UIControlStateNormal];
    
    // Notify our servers about the login attempt
    [[[APIController alloc] initWithDelegate:self forcing:YES] personSignIn:_waiterUsername.text withPassword:_waiterPassword.text];
}

#pragma mark - APIController DataSource

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    // Implement a method that allows every failing requisition to be reloaded
    
    if (error.code == 401) {
        [_waiterButton setTitle:NSLocalizedString(@"Try Again :(", nil) forState:UIControlStateNormal];
    } else if (error.code == 403) {
        [_waiterButton setTitle:NSLocalizedString(@"Wait 10 min to try again!", nil) forState:UIControlStateNormal];
    } else {
        [super apiController:apiController didFailWithError:error];
    }
}

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"signIn"] || [apiController.method isEqualToString:@"signInWithFacebookToken"]) {
        // Get some properties
        NSArray *events = [dictionary objectForKey:@"events"];
        NSString *tokenID = [dictionary objectForKey:@"tokenID"];
        
        if (tokenID.length == 60) {
            // Set loaded message on button
            [_waiterButton setTitle:NSLocalizedString(@"Logged!", nil) forState:UIControlStateNormal];
            
            // Notify the singleton that we have authenticated the user
            [[HumanToken sharedInstance] setTokenID:tokenID];
            [[HumanToken sharedInstance] setWorkingEvents:events];
            [[HumanToken sharedInstance] setName:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
        
            // Update the current state of the schedule controller
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];
            
            // Go back to the other screen
            [self dismissViewControllerAnimated:YES completion:^{
                [_waiterButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
                [_waiterUsername setText:@""];
                [_waiterPassword setText:@""];
            }];
        } else {
            // Set loaded message on button
            [_waiterButton setTitle:NSLocalizedString(@"Try Again :(", nil) forState:UIControlStateNormal];
        }
    } else if ([apiController.method isEqualToString:@"getEvents"]) {
        
        NSArray *events = [[dictionary objectForKey:@"data"] objectForKey:@"events"];
        [[HumanToken sharedInstance] setWorkingEvents:events];
    }
}

#pragma - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Facebook Methods

- (void)loginFacebook {
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             if ([session isOpen]) {
                 // Session is open
                 [self cancelButtonWasPressed];
                 
                 // Notify our servers about the access token
                 [[[APIController alloc] initWithDelegate:self forcing:YES] personSignInWithFacebookToken:FBSession.activeSession.accessTokenData.accessToken];
                 
             } else {
                 // Session is closed
                 AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Facebook couldn't log you in! Try again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok!", nil)];
                 [alertView show];
             }
             
         }];
    }
}


@end
