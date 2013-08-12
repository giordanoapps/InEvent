//
//  RestaurantWrapperViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 06/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "RestaurantWrapperViewController.h"
#import "WaiterViewController.h"
#import "AppDelegate.h"
#import "UIViewController+Present.h"
#import "CoolBarButtonItem.h"
#import "TableToken.h"
#import "HumanToken.h"
#import "CompanyToken.h"

@interface RestaurantWrapperViewController ()

@end

@implementation RestaurantWrapperViewController

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
    
    // Controller is inside a splitViewController and it's on the detail view
    if (self.splitViewController && [[[self.splitViewController viewControllers] objectAtIndex:0] isEqual:self.navigationController]) {
        // Left Button
        self.leftBarButton = nil;
        self.navigationItem.leftBarButtonItems = [NSArray array];
    } else {
        // Right Button
        self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"64-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
        self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Restaurant Actions", nil);
        self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    NSString *title = ([[HumanToken sharedInstance] tokenID] != nil) ? NSLocalizedString(@"Call check", nil) : NSLocalizedString(@"Exit restaurant", nil);
    
    UIActionSheet *actionSheet;
    
    if ([[CompanyToken sharedInstance] waiterAvailable]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:title, NSLocalizedString(@"Call Waiter", nil),  nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:title, nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
    
    
    // NSLocalizedString(@"Make reservation", nil),
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Call check", nil)]) {
        // Load the check
        if ([[HumanToken sharedInstance] tokenID] != nil) [self verifyCheck];
        
    } else if ([title isEqualToString:NSLocalizedString(@"Exit restaurant", nil)]) {
        // Remove the tokenID and enterprise
        [[CompanyToken sharedInstance] removeEnterprise];
        [[TableToken sharedInstance] removeMemberFromTable];
        
        // Check for it again
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
        
    } else if ([title isEqualToString:NSLocalizedString(@"Call Waiter", nil)]) {
        // Call Waiter
        if ([self verifyTable]) [self verifyWaiter];
    }
    
    // Make Reservation
//    } else if (buttonIndex == 2) {
//        PaperFoldMenuController *menuController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] menuController];
//        // Load the Reservation Controller
//        [menuController setSelectedIndex:1];
//    }
    
}


@end
