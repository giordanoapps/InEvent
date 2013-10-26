//
//  AppDelegate.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage+Color.h"
#import "AboutViewController.h"
#import "ScheduleViewController.h"
#import "ScheduleItemViewController.h"
#import "PeopleViewController.h"
#import "PersonViewController.h"
#import "StreamViewController.h"
#import "StreamDetailViewController.h"
#import "ColorThemeController.h"
#import "PushController.h"
#import "HumanViewController.h"
#import "LauchImageViewController.h"
#import "GAI.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "IntelligentSplitViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@property (strong, nonatomic) UIViewController *humanViewController;
@property (strong, nonatomic) UIViewController *scheduleViewController;
@property (strong, nonatomic) UIViewController *photosViewController;
@property (strong, nonatomic) UIViewController *peopleViewController;
@property (strong, nonatomic) UIViewController *aboutViewController;

@end

@implementation AppDelegate

#pragma mark - Facebook Methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.scheme isEqualToString:@"inevent"]) {
        return [self parseQueryString:[url query]];
    } else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if ([url.scheme isEqualToString:@"inevent"]) {
        return [self parseQueryString:[url query]];
    } else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (BOOL)parseQueryString:(NSString *)query {

    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] >= 2) {
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if ([key isEqualToString:@"tokenID"]) {
                [[HumanToken sharedInstance] setTokenID:val];
            } else if ([key isEqualToString:@"eventID"]) {
                [[EventToken sharedInstance] setEventID:[val integerValue]];
            } else if ([key isEqualToString:@"name"]) {
                [[HumanToken sharedInstance] setName:val];
            } else if ([key isEqualToString:@"memberID"]) {
                [[HumanToken sharedInstance] setMemberID:[val integerValue]];
            }
        }
    }
    
    // Update the current state of the schedule controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];

    return YES;
}

#pragma mark - Parse Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Deliver a notification to the proper controller
    [PushController deliverPushNotification:userInfo];
}


#pragma mark - Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *userInfo;
    
    userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [PushController deliverPushNotification:userInfo];
        application.applicationIconBadgeNumber = 0;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Status Bar
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    }
    
    // Each controller
    [self loadHumanController];
    [self loadScheduleController];
    [self loadPhotosController];
    [self loadPeopleController];
    [self loadAboutController];
    
    // Global Controller
    _menuController = [[MenuViewController alloc] initWithMenuWidth:180.0 numberOfFolds:3];
    [_menuController setDelegate:self];
    [_menuController setViewControllers:[NSMutableArray arrayWithObjects:_humanViewController, _scheduleViewController, _photosViewController, _peopleViewController, _aboutViewController, nil]];
    
    // Set the default theme color
    [[ColorThemeController sharedInstance] setTheme:ColorThemePetoskeyStone];

    // Create components
    [self createCustomAppearance];
    [self createGoogleAnalyticsTracker];
    [self createGoogleMapsTracker];
    [self createParseTrackerWithApplication:application withOptions:launchOptions];
    
    // Set the default controller
    self.window.rootViewController = self.menuController;
//    self.window.rootViewController = [[LauchImageViewController alloc] initWithNibName:@"LauchImageViewController" bundle:nil];

    // Display it
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self storeEssentialData];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self storeEssentialData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self loadEssentialData];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self loadEssentialData];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Clean badge notification
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self storeEssentialData];
}

#pragma mark - Controllers

- (void)loadAboutController {
    
    _aboutViewController = [[UINavigationController alloc] initWithRootViewController:[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil]];
}

- (void)loadHumanController {
    
    _humanViewController = [[UINavigationController alloc] initWithRootViewController:[[HumanViewController alloc] initWithNibName:@"HumanViewController" bundle:nil]];
}

- (void)loadPeopleController {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _peopleViewController = [[UINavigationController alloc] initWithRootViewController:[[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil]];
    } else {
        _peopleViewController = [[IntelligentSplitViewController alloc] init];
        PeopleViewController *pvc = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
        UINavigationController *npvc = [[UINavigationController alloc] initWithRootViewController:pvc];
        PersonViewController *pivc = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
        UINavigationController *npivc = [[UINavigationController alloc] initWithRootViewController:pivc];
        ((UISplitViewController *)_peopleViewController).title = pvc.title;
        ((UISplitViewController *)_peopleViewController).tabBarItem.image = pvc.tabBarItem.image;
        ((UISplitViewController *)_peopleViewController).delegate = pivc;
        ((UISplitViewController *)_peopleViewController).viewControllers = @[npvc, npivc];
    }
}

- (void)loadPhotosController {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _photosViewController = [[UINavigationController alloc] initWithRootViewController:[[StreamViewController alloc] initWithNibName:@"StreamViewController" bundle:nil]];
    } else {
        _photosViewController = [[IntelligentSplitViewController alloc] init];
        StreamViewController *pvc = [[StreamViewController alloc] initWithNibName:@"StreamViewController" bundle:nil];
        UINavigationController *npvc = [[UINavigationController alloc] initWithRootViewController:pvc];
        StreamDetailViewController *pdvc = [[StreamDetailViewController alloc] initWithNibName:@"StreamDetailViewController" bundle:nil];
        UINavigationController *npdvc = [[UINavigationController alloc] initWithRootViewController:pdvc];
        ((UISplitViewController *)_photosViewController).title = pvc.title;
        ((UISplitViewController *)_photosViewController).tabBarItem.image = pvc.tabBarItem.image;
        ((UISplitViewController *)_photosViewController).delegate = pdvc;
        ((UISplitViewController *)_photosViewController).viewControllers = @[npvc, npdvc];
    }
}

- (void)loadScheduleController {

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _scheduleViewController = [[UINavigationController alloc] initWithRootViewController:[[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil]];
    } else {
        _scheduleViewController = [[IntelligentSplitViewController alloc] init];
        ScheduleViewController *svc = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
        UINavigationController *nsvc = [[UINavigationController alloc] initWithRootViewController:svc];
        ScheduleItemViewController *sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
        UINavigationController *nsivc = [[UINavigationController alloc] initWithRootViewController:sivc];
        ((UISplitViewController *)_scheduleViewController).title = svc.title;
        ((UISplitViewController *)_scheduleViewController).tabBarItem.image = svc.tabBarItem.image;
        ((UISplitViewController *)_scheduleViewController).delegate = sivc;
        ((UISplitViewController *)_scheduleViewController).viewControllers = @[nsvc, nsivc];
    }
}


#pragma mark - Creators

- (void)createCustomAppearance {
    
    // ----------------------
    // UIPopover
    // ----------------------
    UINavigationBar *appearanceProxBar = [UINavigationBar appearance];
    UIImage *defaultImage = [appearanceProxBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [appearanceProxBar setBackgroundImage:[[UIImage alloc] imageWithColor:[ColorThemeController navigationBarBackgroundColor]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setBackgroundImage:defaultImage forBarMetrics:UIBarMetricsDefault];
    
    // ----------------------
    // UIToolbar
    // ----------------------
    [[UIToolbar appearance] setBackgroundImage:[[UIImage alloc] imageWithColor:[ColorThemeController navigationBarBackgroundColor]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // ----------------------
    // UINavigationBar
    // ----------------------
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] imageWithColor:[ColorThemeController navigationBarBackgroundColor]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0.0 forBarMetrics:UIBarMetricsDefault];
 
    // ----------------------
    // UIBarButtonItem
    // ----------------------
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundVerticalPositionAdjustment:0.0 forBarMetrics:UIBarMetricsDefault];
    }
    
    // ----------------------
    // UITabBarItem
    // ----------------------
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[ColorThemeController tabBarItemTextColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
}

- (void)createGoogleAnalyticsTracker {
    // Create the Google Analytics tracker
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
#ifdef DEBUG
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#endif
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-33888939-6"];
}

- (void)createGoogleMapsTracker {
    [GMSServices provideAPIKey:@"AIzaSyAdQ_ARtScsEywqn6vQfYKT8m0QyObDaFQ"];
}

- (void)createParseTrackerWithApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    // Create the Parse tracker
    [Parse setApplicationId:@"GVhc1mnm0Zi2b7RxOZ8jFNbqhYQIE59sYxfKSlyE" clientKey:@"vaCGSz1JXSVkDNTX9oE8bwu15faHHVi3B3ChLgRL"];
    
//    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
}

#pragma mark - Data

- (void)storeEssentialData {
    
}

- (void)loadEssentialData {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"ad"}];
}

@end
