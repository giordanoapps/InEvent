//
//  RestaurantViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 28/11/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "RestaurantViewController.h"
#import "AppDelegate.h"
#import "CarteViewController.h"
#import "CarteCategoryViewController.h"
#import "CarteItemViewController.h"
#import "OrderViewController.h"
#import "ChatViewController.h"
#import "ChatItemViewController.h"
#import "MapViewController.h"
#import "ReservationViewController.h"
#import "TableToken.h"
#import "CompanyToken.h"
#import "HumanToken.h"
#import "BenchMapViewController.h"
#import "BenchViewController.h"
#import "UITabBarController+ShowHideBar.h"
#import "UIViewController+AKTabBarController.h"
#import "IntelligentSplitViewController.h"
#import "UIImage+Color.h"

@interface RestaurantViewController ()

@property (strong, nonatomic) UIViewController *tableMapViewController;
@property (strong, nonatomic) UIViewController *menuViewController;
@property (strong, nonatomic) UIViewController *orderViewController;
@property (strong, nonatomic) UIViewController *chatViewController;

@end

@implementation RestaurantViewController

- (id)initWithTabBarHeight:(NSUInteger)height
{
    self = [super initWithTabBarHeight:height];
    if (self) {
        // Title
        self.title = NSLocalizedString(@"My location", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Map"];
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setViewControllersForCurrentState) name:@"restaurantCurrentState" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFirstController) name:@"selectFirstController" object:nil];
        
        [self setViewControllersForCurrentState];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View
    self.view.userInteractionEnabled = YES;
    self.view.contentMode = UIViewContentModeRedraw;
    self.view.opaque = YES;
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    self.view.backgroundColor = [ColorThemeController tabBarBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setViewControllersForCurrentState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return ((1 << toInterfaceOrientation) | self.supportedInterfaceOrientations) == self.supportedInterfaceOrientations;
}

#pragma mark - Alloc Methods

- (void)allocTableMapViewController {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        BenchMapViewController *tmvc = [[BenchMapViewController alloc] initWithNibName:@"TableMapViewController" bundle:nil];
        [tmvc setType:TableViewDataEmployee];
        _tableMapViewController = [[UINavigationController alloc] initWithRootViewController:tmvc];
    } else {
        _tableMapViewController = [[IntelligentSplitViewController alloc] init];
        BenchMapViewController *tmvc = [[BenchMapViewController alloc] initWithNibName:@"TableMapViewController" bundle:nil];
        [tmvc setType:TableViewDataEmployee];
        UINavigationController *ntmvc = [[UINavigationController alloc] initWithRootViewController:tmvc];
        BenchViewController *tvc = [[BenchViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
        UINavigationController *ntvc = [[UINavigationController alloc] initWithRootViewController:tvc];
        ((UISplitViewController *)_tableMapViewController).delegate = tvc;
        ((UISplitViewController *)_tableMapViewController).viewControllers = @[ntmvc, ntvc];
    }
}

- (void)allocChatViewController {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _chatViewController = [[UINavigationController alloc] initWithRootViewController:[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil]];
    } else {
        _chatViewController = [[IntelligentSplitViewController alloc] init];
        ChatViewController *cvc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        UINavigationController *ncvc = [[UINavigationController alloc] initWithRootViewController:cvc];
        ChatItemViewController *cdvc = [[ChatItemViewController alloc] initWithNibName:@"ChatItemViewController" bundle:nil];
        UINavigationController *ncdvc = [[UINavigationController alloc] initWithRootViewController:cdvc];
        ((UISplitViewController *)_chatViewController).delegate = cdvc;
        ((UISplitViewController *)_chatViewController).viewControllers = @[ncvc, ncdvc];
    }
}

- (void)allocMenuViewController {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _menuViewController = [[UINavigationController alloc] initWithRootViewController:[[CarteViewController alloc] initWithNibName:@"CarteViewController" bundle:nil]];
    } else {
        _menuViewController = [[IntelligentSplitViewController alloc] init];
        CarteViewController *mvc = [[CarteViewController alloc] initWithNibName:@"CarteViewController" bundle:nil];
        UINavigationController *nmvc = [[UINavigationController alloc] initWithRootViewController:mvc];
        CarteCategoryViewController *mcvc = [[CarteCategoryViewController alloc] initWithNibName:@"CarteCategoryViewController" bundle:nil];
        UINavigationController *nmcvc = [[UINavigationController alloc] initWithRootViewController:mcvc];
        ((UISplitViewController *)_menuViewController).delegate = mcvc;
        ((UISplitViewController *)_menuViewController).viewControllers = @[nmvc, nmcvc];
    }
}


- (void)allocOrderViewController {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _orderViewController = [[UINavigationController alloc] initWithRootViewController:[[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil]];
    } else {
        // Order
        _orderViewController = [[UISplitViewController alloc] init];
        OrderViewController *ovc = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
        UINavigationController *novc = [[UINavigationController alloc] initWithRootViewController:ovc];
        CarteItemViewController *mivc = [[CarteItemViewController alloc] initWithNibName:@"CarteItemViewController" bundle:nil];
        UINavigationController *nmivc = [[UINavigationController alloc] initWithRootViewController:mivc];
        ((UISplitViewController *)_orderViewController).delegate = mivc;
        ((UISplitViewController *)_orderViewController).viewControllers = @[novc, nmivc];
    }
}

#pragma mark - User Methods

- (void)updateControllers:(NSMutableArray *)viewControllers {
    for (int i = 0; i < [viewControllers count]; i++) {
        
        UIViewController *controller = [viewControllers objectAtIndex:i];
        UIViewController *fatherController;
        NSString *title;
        UIImage *image;
        
        if ([controller isKindOfClass:[UINavigationController class]]) {
            fatherController = controller;
            controller = [((UINavigationController *)controller).viewControllers objectAtIndex:0];
        } else if ([controller isKindOfClass:[UISplitViewController class]]) {
            fatherController = controller;
            controller = [[[((UISplitViewController *)controller).viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
        }
        
        if ([controller isKindOfClass:[CarteViewController class]]) {
            title = NSLocalizedString(@"Menu", nil);
            image = [UIImage imageNamed:@"32-Book"];
        } else if ([controller isKindOfClass:[OrderViewController class]]) {
            title = NSLocalizedString(@"Order", nil);
            image = [UIImage imageNamed:@"32-Shopping-Basket"];
        } else if ([controller isKindOfClass:[ChatViewController class]]) {
            title = NSLocalizedString(@"Chat", nil);
            image = [UIImage imageNamed:@"32-Speech-Bubbles"];
        }
        
        if (fatherController) {
            fatherController.title = title;
            fatherController.tabBarItem.image = image;
        } else {
            controller.title = title;
            controller.tabBarItem.image = image;
        }
    }
}

- (void)selectFirstController {
    
    // Get the tab bar first top controller
    UIViewController *controller = [self.viewControllers objectAtIndex:0];
    
    // We have to find the UINavigationController and pop its controllers to the rootViewController
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)controller) popToRootViewControllerAnimated:NO];
    } else if ([controller isKindOfClass:[UISplitViewController class]]) {
        controller = (UINavigationController *)[((UISplitViewController *)controller).viewControllers objectAtIndex:0];
        [(UINavigationController *)controller popToRootViewControllerAnimated:NO];
    }
    
    // After we have done so, we can set the tabViewController to the menu
    [self setSelectedIndex:0];
}

#pragma mark - Controller Operations

- (void)setViewControllersForCurrentState {
    
    HumanToken *human = [HumanToken sharedInstance];
    CompanyToken *company = [CompanyToken sharedInstance];
    
    if ([human isMemberAuthenticated] && [human worksAtCompany:company.companyID]) {
        [self hideTabBarAnimated:YES];
        if (self.tableMapViewController == nil) [self allocTableMapViewController];
        // Create a single controller
        [self setViewControllers:[NSMutableArray arrayWithObject:self.tableMapViewController]];
    } else {
        [self setViewControllers:[NSMutableArray array]];
        if (![self isVisible]) [self showTabBarAnimated:YES];
        // Update the controllers with our last state
        [self setViewControllersForCompanyToken];
    }
}

- (void)setViewControllersForCompanyToken {

    if (self.menuViewController == nil) [self allocMenuViewController];
    self.menuViewController = [self setViewControllerWithState:YES withViewController:self.menuViewController withClass:[CarteViewController class]];
    
    BOOL orderAvailable = [[CompanyToken sharedInstance] orderAvailable];
    if (self.orderViewController == nil) [self allocOrderViewController];
    self.orderViewController = [self setViewControllerWithState:orderAvailable withViewController:self.orderViewController withClass:[OrderViewController class]];
    
//    // Process the states before sending them to further device consumption
//    if ((self.orderViewController == nil  && orderAvailable == NO) || (self.orderViewController != nil  && orderAvailable == YES)) {
//        self.orderViewController = [self setViewControllerWithState:orderAvailable withViewController:self.orderViewController withClass:[OrderViewController class]];
//    }

    BOOL chatAvailable = [[CompanyToken sharedInstance] chatAvailable];
    if (self.chatViewController == nil) [self allocChatViewController];
    self.chatViewController = [self setViewControllerWithState:chatAvailable withViewController:self.chatViewController withClass:[ChatViewController class]];
}

- (UIViewController *)setViewControllerWithState:(BOOL)state withViewController:(UIViewController *)controller withClass:(Class)controllerClass {
    
    if (self.viewControllers == nil) self.viewControllers = [NSArray array];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewControllers];
    
    if (state) {
        NSInteger index = [array indexOfObject:controller];
        if (index == NSNotFound) [array addObject:controller];
    } else {
        [array removeObject:controller];
    }
    
    // Update the viewControllers
    [self setViewControllers:array];
    
    return controller;
}

- (UIViewController *)setExemptedViewControllerWithState:(BOOL)state withViewController:(UIViewController *)controller withClass:(Class)controllerClass {

    NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewControllers];
    UIViewController *internalViewController = nil;
    
    if (state) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            [array addObject:(UINavigationController *)controller];
            controller = nil;
        } else if ([controller isKindOfClass:[UISplitViewController class]]) {
            [array addObject:(UISplitViewController *)controller];
            controller = nil;
        }
    } else {
        
        for (int i = 0; i < [array count]; i++) {
            
            internalViewController = [array objectAtIndex:i];
            
            if ([internalViewController isKindOfClass:[UINavigationController class]]) {
                internalViewController = [((UINavigationController *)internalViewController).viewControllers objectAtIndex:0];
            } else if ([internalViewController isKindOfClass:[UISplitViewController class]]) {
                internalViewController = [[[((UISplitViewController *)internalViewController).viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
            }
            
            // See if the controller belongs to the chat
            if ([internalViewController isKindOfClass:controllerClass]) {
                // If so, we can save it
                controller = [array objectAtIndex:i];
                [array removeObject:controller];
            }
        }
        
    }
    
    // Update the viewControllers
    [self setViewControllers:array];

    return controller;
}


@end
