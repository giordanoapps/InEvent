//
//  AppDelegate.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage+Color.h"
#import "AboutViewController.h"
#import "ScheduleViewController.h"
#import "ScheduleItemViewController.h"
#import "ColorThemeController.h"
#import "PushController.h"
#import "HumanViewController.h"
#import "ReaderViewController.h"
#import "LauchImageViewController.h"
#import "GAI.h"
#import "IntelligentSplitViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (strong, nonatomic) UIViewController *humanViewController;
@property (strong, nonatomic) UIViewController *scheduleViewController;
@property (strong, nonatomic) UIViewController *aboutViewController;

@end

@implementation AppDelegate

#pragma mark - Facebook Methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
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

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

#pragma mark - Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Each controller
    // LOGIN
    _humanViewController = [[UINavigationController alloc] initWithRootViewController:[[HumanViewController alloc] initWithNibName:@"HumanViewController" bundle:nil]];
    
    // SCHEDULE
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
    
    // ABOUT
    _aboutViewController = [[UINavigationController alloc] initWithRootViewController:[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil]];
    
    // Global Controller
    _menuController = [[MenuViewController alloc] initWithMenuWidth:180.0 numberOfFolds:3];
    [_menuController setDelegate:self];
    [_menuController setViewControllers:[NSMutableArray arrayWithObjects:_humanViewController, _scheduleViewController, _aboutViewController, nil]];
    
    // Set the default theme color
    [[ColorThemeController sharedInstance] setTheme:ColorThemePetoskeyStone];

    // Create components
    [self createCustomAppearance];
    [self createGoogleAnalyticsTracker];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self loadEssentialData];
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
    UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
    UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundVerticalPositionAdjustment:0.0 forBarMetrics:UIBarMetricsDefault];
    
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
    [GAI sharedInstance].debug = NO;
#endif
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-33888939-6"];
}

- (void)createParseTrackerWithApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    // Create the Parse tracker
    [Parse setApplicationId:@"GVhc1mnm0Zi2b7RxOZ8jFNbqhYQIE59sYxfKSlyE" clientKey:@"vaCGSz1JXSVkDNTX9oE8bwu15faHHVi3B3ChLgRL"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
}

#pragma mark - Store

- (void)storeEssentialData {
    
}

- (void)loadEssentialData {
    
}

@end
