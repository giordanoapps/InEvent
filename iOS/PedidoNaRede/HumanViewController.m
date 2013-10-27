//
//  HumanViewController.m
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "HumanViewController.h"
#import "SocialLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "HumanToken.h"
#import "NSString+HTML.h"

@interface HumanViewController () {
    UIRefreshControl *refreshControl;
}

@end

@implementation HumanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Me", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-User"];
        
        // Register for some updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"personNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonWasPressed:)];
    
    [self.view setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
    
    // Scroll View
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, 550.0f);
	[self.view flashScrollIndicators];
    
    // Photo
    [_photo.layer setCornerRadius:10.0];
    
    // Text fields
    _name.textColor = [ColorThemeController tableViewCellTextColor];
    _description.textColor = [ColorThemeController tableViewCellTextColor];
    _telephone.textColor = [ColorThemeController tableViewCellTextColor];
    _email.textColor = [ColorThemeController tableViewCellTextColor];
    _location.textColor = [ColorThemeController tableViewCellTextColor];
    
    // Restart Facebook connection
    [self connectWithFacebook];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Session
    [self checkSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loader Methods

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] personGetWorkingEventsWithToken:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Public Methods

- (void)checkSession {
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        _name.text = [[HumanToken sharedInstance] name];
    } else {
        // Alloc login controller
        SocialLoginViewController *lvc = [[SocialLoginViewController alloc] initWithNibName:@"SocialLoginViewController" bundle:nil];
        [lvc setDelegate:self];
        UINavigationController *nlvc = [[UINavigationController alloc] initWithRootViewController:lvc];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nlvc.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            nlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nlvc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nlvc animated:YES completion:nil];
    }
}

#pragma mark - Facebook Methods

//- (void)populateUserDetails
//{
//    if (FBSession.activeSession.isOpen) {
//        [[FBRequest requestForMe] startWithCompletionHandler:
//         ^(FBRequestConnection *connection,
//           NSDictionary<FBGraphUser> *user,
//           NSError *error) {
//             if (!error) {
//                 [self.name setTitle:[user.name stringByDecodingHTMLEntities] forState:UIControlStateNormal];
//                 [self.photo setProfileID:[user objectForKey:@"id"]];
//             }
//         }];
//    }
//}

- (void)logoutButtonWasPressed:(id)sender {
    
    // Remove Facebook Login
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    // Remove InEvent Login
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[HumanToken sharedInstance] removeMember];
    }
    
    // Update the current state of the schedule controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
    
    // Load the login form
    [self checkSession];
}

- (void)connectWithFacebook {
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                           allowLoginUI:NO
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {}];
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the working events
    [[HumanToken sharedInstance] setWorkingEvents:[dictionary objectForKey:@"data"]];
    
    // Stop refreshing
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
