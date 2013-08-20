//
//  MenuViewController.m
//  Garça
//
//  Created by Pedro Góes on 20/11/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+Present.h"
#import "HumanViewController.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "NSString+HTML.h"
#import "GAI.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *headers;

@end

@implementation MenuViewController

- (id)initWithMenuWidth:(float)menuWidth numberOfFolds:(int)numberOfFolds
{
    self = [super initWithMenuWidth:menuWidth numberOfFolds:numberOfFolds];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performVerification:) name:@"verify" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ColorThemeController tabBarBackgroundColor];
    
    // Load the table background
    UIView *tableBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [tableBgView setBackgroundColor:[UIColor colorWithRed:0.170 green:0.166 blue:0.175 alpha:1.000]];
    [self.menuTableView setBackgroundView:tableBgView];
    [self.menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _headers = @[NSLocalizedString(@"Your Account", nil), NSLocalizedString(@"General", nil), NSLocalizedString(@"About", nil)];
    
    // Selected the restaurant controller
    [self setSelectedIndex:1];
    
    // Update the menu
    [self performSelector:@selector(reloadMenu)];
 
    // Load the enterprise
    [self performSelector:@selector(verifyEvent) withObject:nil afterDelay:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Methods

- (void)performVerification:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    if (userInfo != nil) {
        
        NSString *type = [userInfo objectForKey:@"type"];
        
        if ([type isEqualToString:@"person"]) {
            // Verify if company is already selected
            [self performSelector:@selector(verifyPerson) withObject:nil afterDelay:0];
            
        } else if ([type isEqualToString:@"enterprise"]) {
            // Verify if company is already selected
            [self performSelector:@selector(verifyEvent) withObject:nil afterDelay:0];
            
        } else if ([type isEqualToString:@"person"]) {
            // Load the feedback controler
            [self performSelector:@selector(verifyFeedback) withObject:nil afterDelay:0];
            
        } else if ([type isEqualToString:@"menu"]) {
            // Update the menu
            [self performSelector:@selector(reloadMenu)];
        }
    }
    
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_headers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    [background setBackgroundColor:[ColorThemeController navigationBarBackgroundColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 12.0, tableView.frame.size.width, 32.0)];
    [title setText:[[_headers objectAtIndex:section] uppercaseString]];
    [title setFont:[UIFont fontWithName:@"Thonburi-Bold" size:16.0]];
    [title setTextColor:[ColorThemeController navigationBarTextColor]];
    [title setBackgroundColor:[UIColor clearColor]];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0.0, 42.0, tableView.frame.size.width, 2.0)];
    [border setBackgroundColor:[ColorThemeController tableViewCellBorderColor]];
    
    [headerView addSubview:background];
    [headerView addSubview:title];
    [headerView addSubview:border];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    static NSString *identifier = @"CustomCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setTextColor:[ColorThemeController navigationBarTextColor]];
        [cell.textLabel setHighlightedTextColor:[ColorThemeController navigationBarTextColor]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Thonburi" size:18.0]];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 36.0)];
        [background setBackgroundColor:[ColorThemeController navigationBarBackgroundColor]];
        [cell setBackgroundView:background];
    }

    if (indexPath.section == 0) {
        NSString *title = ([[HumanToken sharedInstance] isMemberAuthenticated]) ? [[HumanToken sharedInstance] name] : NSLocalizedString(@"Log In", nil);
        [cell.textLabel setText:title];
        
        UIViewController *viewController = [self.viewControllers objectAtIndex:indexPath.row];
        [cell.imageView setImage:viewController.tabBarItem.image];
    } else {
        UIViewController *viewController = [self.viewControllers objectAtIndex:indexPath.section];
        [cell.textLabel setText:viewController.title];
        [cell.imageView setImage:viewController.tabBarItem.image];
    }

    if ((indexPath.section <= 1 && self.selectedIndex == indexPath.row + indexPath.section) ||
        (indexPath.section == 2 && self.selectedIndex == 2)) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"16-Check"]];
        [cell setAccessoryView:imageView];
    } else {
        [cell setAccessoryView:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section <= 2) {
        // We must transform the current indexPath into something that the library can read
        NSIndexPath *transformed = [NSIndexPath indexPathForRow:indexPath.row + indexPath.section inSection:0];
        [super tableView:tableView didSelectRowAtIndexPath:transformed];
    }
    
    // Reload all sections
    [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
