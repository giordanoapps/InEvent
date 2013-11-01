//
//  HumanLoginViewController.m
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "HumanLoginViewController.h"
#import "HumanViewController.h"
#import "ColorThemeController.h"
#import "AppDelegate.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "EventToken.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "InEventAPI.h"

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
    
    // Navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonWasPressed)];
    
    // View
    [self.view setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [self.view addTarget:self action:@selector(hideFieldBox) forControlEvents:UIControlEventTouchUpInside];
    
    // Labels
    [_accountLabel setText:NSLocalizedString(@"Already enrolled?", nil)];
    
    // Box
    [_bottomBox setBackgroundColor:[ColorThemeController backgroundColor]];
    [_bottomBox addTarget:self action:@selector(hideFieldBox) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBox.layer setMasksToBounds:YES];
    
    [_bottomInternalBox addTarget:self action:@selector(hideFieldBox) forControlEvents:UIControlEventTouchUpInside];
    
    [_separator2 setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    
    // Login toggle button
    UIImage *buttonImage, *buttonImageHighlight;
    
    buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_loginButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(toggleFieldBox:) forControlEvents:UIControlEventTouchUpInside];
    
    // Register toggle button
    buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_registerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_registerButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(toggleFieldBox:) forControlEvents:UIControlEventTouchUpInside];
    
    // Padding views
    UIView *waiterEmailPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *waiterNamePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *waiterPasswordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    // Field Wrapper
	_personFieldWrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    [_personFieldWrapper.layer setCornerRadius:8.0];
    [_personFieldWrapper.layer setBorderWidth:1.0];
    [_personFieldWrapper.layer setBorderColor:[[ColorThemeController tableViewCellBorderColor] CGColor]];
    
    // Person email field
    _personEmail.backgroundColor = [UIColor clearColor];
    _personEmail.borderStyle = UITextBorderStyleNone;
    _personEmail.delegate = self;
    _personEmail.frame = CGRectMake(0.0, 0.0, _personEmail.frame.size.width, 50.0);
    _personEmail.leftView = waiterEmailPaddingView;
    _personEmail.leftViewMode = UITextFieldViewModeAlways;
	_personEmail.placeholder = NSLocalizedString(@"Email", nil);
	_personEmail.textColor = [ColorThemeController textColor];
    // Bottom Border
    UIView *emailBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _personEmail.frame.size.height - 1.0f, _personEmail.frame.size.width, 1.0f)];
    emailBorder.backgroundColor = [ColorThemeController tableViewCellBorderColor];
    emailBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_personEmail addSubview:emailBorder];
    
	// Person name field
    _personName.backgroundColor = [UIColor clearColor];
    _personName.borderStyle = UITextBorderStyleNone;
    _personName.delegate = self;
    _personName.frame = CGRectMake(0.0, 50.0, _personName.frame.size.width, 50.0);
    _personName.leftView = waiterNamePaddingView;
    _personName.leftViewMode = UITextFieldViewModeAlways;
	_personName.placeholder = NSLocalizedString(@"Name", nil);
	_personName.textColor = [ColorThemeController textColor];
    // Bottom Border
    UIView *nameBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _personEmail.frame.size.height - 1.0f, _personEmail.frame.size.width, 1.0f)];
    nameBorder.backgroundColor = [ColorThemeController tableViewCellBorderColor];
    nameBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_personName addSubview:nameBorder];
    
	// Person password field
    _personPassword.backgroundColor = [UIColor clearColor];
    _personPassword.borderStyle = UITextBorderStyleNone;
    _personPassword.delegate = self;
    _personPassword.frame = CGRectMake(0.0, 100.0, _personPassword.frame.size.width, 50.0);
    _personPassword.leftView = waiterPasswordPaddingView;
    _personPassword.leftViewMode = UITextFieldViewModeAlways;
	_personPassword.placeholder = NSLocalizedString(@"Password", nil);
	_personPassword.textColor = [ColorThemeController textColor];
    
	// Field action button
	[_personAction setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    [_personAction setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_personAction setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_personAction addTarget:self action:@selector(chooseAction) forControlEvents:UIControlEventTouchUpInside];
    [_personAction.layer setCornerRadius:8.0];
    
    
    // ---------------------
    // Reset the field box
    // ---------------------
    [self toggleFieldBoxWithDuration:0.0 andHideIt:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)cancelButtonWasPressed {
    PaperFoldMenuController *menuController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] menuController];
    [menuController setSelectedIndex:1];
    
    [self dismissViewControllerAnimated:YES completion:^{
        // Select an event
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }];
}

#pragma mark - Email Methods

- (void)hideNameField {
    [_personName setHidden:YES];
    [_personPassword setFrame:CGRectMake(_personPassword.frame.origin.x, 50.0, _personPassword.frame.size.width, 50.0)];
    [_personFieldWrapper setFrame:CGRectMake(_personFieldWrapper.frame.origin.x, 100.0, _personFieldWrapper.frame.size.width, 100.0)];
    [_personAction setFrame:CGRectMake(_personAction.frame.origin.x, 220.0, _personAction.frame.size.width, _personAction.frame.size.height)];
}

- (void)showNameField {
    [_personName setHidden:NO];
    [_personPassword setFrame:CGRectMake(_personPassword.frame.origin.x, 100.0, _personPassword.frame.size.width, 50.0)];
    [_personFieldWrapper setFrame:CGRectMake(_personFieldWrapper.frame.origin.x, 100.0, _personFieldWrapper.frame.size.width, 150.0)];
    [_personAction setFrame:CGRectMake(_personAction.frame.origin.x, 270.0, _personAction.frame.size.width, _personAction.frame.size.height)];
}

#pragma mark - Box Methods

- (void)hideFieldBox {
    [self toggleFieldBoxWithDuration:0.5 andHideIt:YES];
}

- (void)toggleFieldBox:(id)sender {
    
    if ((UIButton *)sender == _registerButton) {
        [self showNameField];
    } else if ((UIButton *)sender == _loginButton) {
        [self hideNameField];
    }
    
    [self toggleFieldBoxWithDuration:0.5 andHideIt:NO];
}

- (void)toggleFieldBoxWithDuration:(CGFloat)duration andHideIt:(BOOL)hide {
    
    // Resign the keyboard on all the fields
    [_personEmail resignFirstResponder];
    [_personName resignFirstResponder];
    [_personPassword resignFirstResponder];
    
    // Create the frames
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

#pragma - Action Methods

- (void)chooseAction {
    
    if ([_personName isHidden]) {
        [self signIn];
    } else {
        [self enroll];
    }
}

- (void)signIn {
    
    if ([_personEmail.text length] > 0 && [_personPassword.text length] > 0) {
        // Set loading message on button
        [_personAction setTitle:NSLocalizedString(@"Logging ...", nil) forState:UIControlStateNormal];
        
        // Notify our servers about the login attempt
        [[[InEventPersonAPIController alloc] initWithDelegate:self forcing:YES] signIn:_personEmail.text withPassword:_personPassword.text];
        
    } else {
        // Give some data man!
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please give me some details about you.", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

- (void)enroll {
    
    if ([_personEmail.text length] > 0 && [_personName.text length] > 0 && [_personPassword.text length] > 0) {
        // Set loading message on button
        [_personAction setTitle:NSLocalizedString(@"Enrolling ...", nil) forState:UIControlStateNormal];
        
        // Notify our servers about the login attempt
        [[[InEventPersonAPIController alloc] initWithDelegate:self forcing:YES] enroll:_personName.text withPassword:_personPassword.text withEmail:_personEmail.text];
        
    } else {
        // Give some data man!
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"If you wanna be part of this event, please give some basic details.", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

#pragma mark - APIController DataSource

- (void)apiController:(InEventAPIController *)apiController didFailWithError:(NSError *)error {
    // Implement a method that allows every failing requisition to be reloaded
    
    // Reset password
    [_personPassword setText:@""];
    
    if (error.code == 401) {
        [_personAction setTitle:NSLocalizedString(@"Try Again :(", nil) forState:UIControlStateNormal];
    } else if (error.code == 403) {
        [_personAction setTitle:NSLocalizedString(@"Wait 10 min to try again!", nil) forState:UIControlStateNormal];
    } else {
        [super apiController:apiController didFailWithError:error];
    }
}

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"signIn"] ||
        [apiController.method isEqualToString:@"enroll"] ||
        [apiController.method isEqualToString:@"signInWithFacebook"]) {
        // Get some properties
        NSArray *events = [dictionary objectForKey:@"events"];
        NSString *tokenID = [dictionary objectForKey:@"tokenID"];
        
        if (tokenID.length == 60) {
            // Set loaded message on button
            [_personAction setTitle:NSLocalizedString(@"Logged!", nil) forState:UIControlStateNormal];

            // Remove the current event so the information can be reloaded
            [[EventToken sharedInstance] removeEvent];
            
            // Get some properties
            NSInteger memberID = [[dictionary objectForKey:@"memberID"] integerValue];
            
            // Notify the singleton that we have authenticated the user
            [[HumanToken sharedInstance] setTokenID:tokenID];
            [[HumanToken sharedInstance] setWorkingEvents:events];
            [[HumanToken sharedInstance] setMemberID:memberID];
            [[HumanToken sharedInstance] setName:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
            
            // Notify our tracker about the new event
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"person" action:@"signIn" label:@"iOS" value:[NSNumber numberWithInteger:memberID]] build]];
            
            // Notify our tracker about the new event
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"person_%d", memberID] forKey:@"channels"];
            [currentInstallation saveEventually];
            
            // Update the current state of the schedule controller
            [[NSNotificationCenter defaultCenter] postNotificationName:@"eventCurrentState" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];
            
            // Hide box
            [self toggleFieldBoxWithDuration:0.5 andHideIt:NO];
            
            // Go back to the other screen
            [self dismissViewControllerAnimated:YES completion:^{
                // Select an event
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
                
                // Reset the UI
                [_personAction setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
                [_personEmail setText:@""];
                [_personName setText:@""];
                [_personPassword setText:@""];
                
                // Reload the UI beneath this on
                [_delegate checkSession];
            }];
        } else {
            // Set loaded message on button
            [_personAction setTitle:NSLocalizedString(@"Try Again :(", nil) forState:UIControlStateNormal];
            
            // Reset password
            [_personPassword setText:@""];
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

@end
