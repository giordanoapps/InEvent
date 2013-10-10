//
//  HumanViewController.m
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "HumanViewController.h"
#import "HumanLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "ODRefreshControl.h"
#import "HumanToken.h"
#import "NSString+HTML.h"

@interface HumanViewController () {
    ODRefreshControl *refreshControl;
}

@property (nonatomic, strong) HumanLoginViewController *hlvc;

@end

@implementation HumanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.scrollView];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    // Photo Wrapper
    [_photoWrapper.layer setCornerRadius:10.0];
    
    // Photo
    [_photo.layer setMasksToBounds:YES];
    [_photo.layer setCornerRadius:10.0];
    [_photo.layer setBorderWidth:0.4];
    [_photo.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    
    // Introduction
    [_introduction setText:NSLocalizedString(@"Welcome to InEvent", nil)];
    [_introduction setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Title
    [_name.titleLabel setNumberOfLines:0];
    [_name setTitle:@"" forState:UIControlStateNormal];
    [_name.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_name setTitleColor:[ColorThemeController tableViewCellTextColor] forState: UIControlStateNormal];
    [_name setTitleColor:[ColorThemeController tableViewCellTextColor] forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Scroll view
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 1.01)];

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
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
        [self.photo setHidden:NO];
        [self.defaultPhoto setHidden:YES];
    } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [self.name setTitle:[[HumanToken sharedInstance] name] forState:UIControlStateNormal];
        [self.photo setHidden:YES];
        [self.defaultPhoto setHidden:NO];
    } else {
        // Alloc login controller
        _hlvc = [[HumanLoginViewController alloc] initWithNibName:@"HumanLoginViewController" bundle:nil];
        [_hlvc setMoveKeyboardRatio:0.7];
        [_hlvc setDelegate:self];
        UINavigationController *nhlvc = [[UINavigationController alloc] initWithRootViewController:_hlvc];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nhlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nhlvc.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            nhlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nhlvc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nhlvc animated:YES completion:nil];
    }
}

#pragma mark - Facebook Methods

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [self.name setTitle:[user.name stringByDecodingHTMLEntities] forState:UIControlStateNormal];
                 [self.photo setProfileID:[user objectForKey:@"id"]];
             }
         }];
    }
}

- (void)logoutButtonWasPressed:(id)sender {
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[HumanToken sharedInstance] removeMember];
    }
    
    // Update the current state of the schedule controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
    
    // Load the login form
    [self checkSession];
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
