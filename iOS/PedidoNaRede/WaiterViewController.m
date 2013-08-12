//
//  WaiterViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 02/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "WaiterViewController.h"
#import "AppDelegate.h"
#import "TableToken.h"
#import "HumanToken.h"
#import "UIViewController+Present.h"
#import "ColorThemeController.h"
#import "GAI.h"

@interface WaiterViewController ()

@end

@implementation WaiterViewController

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
    
    // View
    [self.view setBackgroundColor:[ColorThemeController tableViewBackgroundColor]];
    
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    // Info Label
    [_infoLabel setText:NSLocalizedString(@"Waiter will be coming shortly.", nil)];
    [_infoLabel setTextColor:[ColorThemeController textColor]];
    
    // Cancel Button
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_cancelButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([self verifyTable]) {
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[APIController alloc] initWithDelegate:self forcing:YES] tableCallWaiterWithToken:tokenID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Methods

- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) message:NSLocalizedString(@"The request for the waiter will be canceled. Are you sure?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitle:NSLocalizedString(@"Yes", nil)];

    [alertView show];
}

#pragma mark - AlertView Delegate

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Exit restaurant
    if (buttonIndex == 1) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Notify our tracker about the new event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"table" withAction:@"callWaiter" withLabel:@"iOS" withValue:[NSNumber numberWithInteger:[[TableToken sharedInstance] tableID]]];
}

@end
