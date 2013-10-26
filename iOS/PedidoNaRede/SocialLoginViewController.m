//
//  SocialLoginViewController.m
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "SocialLoginViewController.h"
#import "HumanLoginViewController.h"
#import "HumanViewController.h"
#import "ColorThemeController.h"
#import "AppDelegate.h"
#import "APIController.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "EventToken.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

@interface SocialLoginViewController ()

@end

@implementation SocialLoginViewController

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

    // Labels
    [_socialLabel setText:NSLocalizedString(@"To login at InEvent, choose your preferred social network", nil)];
    [_accountLabel setTitle:NSLocalizedString(@"Or you want to enter manually?", nil) forState:UIControlStateNormal];
    
    [_separator1 setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
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

- (IBAction)loadAccountLogin:(id)sender {
    HumanLoginViewController *hlvc = [[HumanLoginViewController alloc] initWithNibName:@"HumanLoginViewController" bundle:nil];
    [self.navigationController pushViewController:hlvc animated:YES];
}

#pragma mark - APIController DataSource

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"signIn"] ||
        [apiController.method isEqualToString:@"enroll"] ||
        [apiController.method isEqualToString:@"signInWithLinkedIn"] ||
        [apiController.method isEqualToString:@"signInWithFacebook"] ||
        [apiController.method isEqualToString:@"signInWithTwitter"]) {
        // Get some properties
        NSArray *events = [dictionary objectForKey:@"events"];
        NSString *tokenID = [dictionary objectForKey:@"tokenID"];
        
        if (tokenID.length == 60) {
            
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];
            
            // Go back to the other screen
            [self dismissViewControllerAnimated:YES completion:^{
                // Select an event
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
                
                // Reload the UI beneath this on
                [_delegate checkSession];
            }];
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

#pragma mark - LinkedIn Methods

- (IBAction)linkedinLogin:(id)sender {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.inevent.us/developer/" clientId:@"7obxzmefk9eu" clientSecret:@"rPsCyb8npka6jJHk" state:@"5453sdfggeDCEEFWF4f424" grantedAccess:@[@"r_basicprofile", @"r_fullprofile", @"r_network", @"r_emailaddress"]];
    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application presentingViewController:self];
    
    [client getAuthorizationCode:^(NSString *code) {
        [client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            // Get accessToken
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            
            // Notify our servers about the access token
            [[[APIController alloc] initWithDelegate:self forcing:YES] personSignInWithLinkedInToken:accessToken];
            
        } failure:^(NSError *error) {
            // Session is closed
            AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"LinkedIn couldn't log you in! Try again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
            [alertView show];
        }];
    } cancel:^{
        // Session is closed
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"LinkedIn couldn't log you in! Try again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    } failure:^(NSError *error) {
        // Session is closed
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"LinkedIn couldn't log you in! Try again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }];
}

#pragma mark - Facebook Methods

- (IBAction)facebookLogin:(id)sender {
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
                 
             } else if (session.state == FBSessionStateClosedLoginFailed) {
                 // Session is closed
                 AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Facebook couldn't log you in! Try again?", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
                 [alertView show];
             }
             
         }];
    }
}

#pragma mark - Twitter Methods

- (IBAction)twitterLogin:(id)sender {
    
}


@end
