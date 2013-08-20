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
#import "HumanToken.h"
#import "NSString+HTML.h"

@interface HumanViewController ()

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
        
        // Alloc login controller
        _hlvc = [[HumanLoginViewController alloc] initWithNibName:@"HumanLoginViewController" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"Logout", nil)
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(logoutButtonWasPressed:)];
    
    [self.view setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    
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
    [_name setTitleColor:[ColorThemeController tableViewCellTextColor] forState: UIControlStateNormal];
    [_name setTitleColor:[ColorThemeController tableViewCellTextColor] forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self checkSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Methods

- (void)checkSession {
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [self.name setTitle:[[HumanToken sharedInstance] name] forState:UIControlStateNormal];
    } else {
        [_hlvc setMoveKeyboardRatio:0.7];
        UINavigationController *nhlvc = [[UINavigationController alloc] initWithRootViewController:_hlvc];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nhlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nhlvc.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            nhlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nhlvc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:nhlvc animated:YES completion:nil];
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
                 [self.photo setProfileID: user.id];
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

@end
