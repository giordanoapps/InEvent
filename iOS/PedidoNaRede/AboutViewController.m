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
        self.title = NSLocalizedString(@"About", nil);
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
//    _upArrow.transform = CGAffineTransformMakeRotation(0.75f);
    _leftArrow.transform = CGAffineTransformMakeRotation(0.2f);
    
    // About
    NSString *html = @"<p style='font-family: TrebuchetMS; font-size: 160%; text-align: center;'><b>InEvent</b> é um produto do <b>Estúdio Trilha</b>.</p>";
    [_aboutText loadHTMLString:html baseURL:nil];
    
    _aboutText.scrollView.scrollEnabled = NO;
    _aboutText.scrollView.bounces = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (IBAction)openLink:(id)sender {
    // Open Facebook Page
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/estudiotrilha"]];
}

@end
