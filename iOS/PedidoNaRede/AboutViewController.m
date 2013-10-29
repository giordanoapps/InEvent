//
//  AboutViewController.m
//  Garça
//
//  Created by Pedro Góes on 05/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "UIViewController+Present.h"
#import "ColorThemeController.h"
#import "GAI.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Title
        self.title = NSLocalizedString(@"Our Company", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Footprints"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // View
    [self.view setBackgroundColor:[ColorThemeController tableViewBackgroundColor]];
    
    // Arrows
//    _leftArrow.transform = CGAffineTransformMakeRotation(0.2f);
    
    // About
    _aboutText.scrollEnabled = NO;
    _aboutText.bounces = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (IBAction)openProductPage:(id)sender {
    // Open Facebook Page
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/pages/In-Event/150798025113523"]];
}

- (IBAction)openCompanyPage:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/estudiotrilha"]];
}

@end
