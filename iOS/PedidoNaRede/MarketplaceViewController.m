//
//  MarketplaceViewController.m
//  InEvent
//
//  Created by Pedro Góes on 03/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "MarketplaceViewController.h"
#import "ScheduleViewController.h"
#import "ScheduleViewCell.h"
#import "ScheduleItemViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "ODRefreshControl.h"
#import "UIViewController+AKTabBarController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"

@interface MarketplaceViewController () {
    ODRefreshControl *refreshControl;
}

@property (nonatomic, strong) NSArray *events;

@end

@implementation MarketplaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Marketplace", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Map"];
        self.events = [NSArray array];
        
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"scheduleCurrentState" object:nil];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetEventsWithTokenID:tokenID];
    } else {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetEvents];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.events objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    [background setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    NSDictionary *dictionary = [[self.events objectAtIndex:section] objectAtIndex:0];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 6.0, tableView.frame.size.width, 32.0)];
    [title setText:[NSString stringWithFormat:@"%.2d/%.2d - %@", [components day], [components month], [UtilitiesController weekNameFromIndex:[components weekday]]]];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setFont:[UIFont fontWithName:@"Thonburi-Bold" size:22.0]];
    [title setTextColor:[ColorThemeController textColor]];
    [title setBackgroundColor:[UIColor clearColor]];
    
    [headerView addSubview:background];
    [headerView addSubview:title];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CustomCellIdentifier = @"CustomCellIdentifier";
    ScheduleViewCell * cell = (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"ScheduleViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell =  (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    cell.hour.text = [NSString stringWithFormat:@"%.2d", [components hour]];
    cell.minute.text = [NSString stringWithFormat:@"%.2d", [components minute]];
    cell.name.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.description.text = [[dictionary objectForKey:@"description"] stringByDecodingHTMLEntities];
    cell.approved = [dictionary objectForKey:@"approved"];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ScheduleItemViewController *sivc;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
        [sivc setMoveKeyboardRatio:2.0f];
    } else {
        // Find the sibling navigation controller first child and send the appropriate data
        sivc = (ScheduleItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
        [sivc setMoveKeyboardRatio:0.5f];
    }
    
    NSDictionary *dictionary = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [sivc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
    [sivc setActivityData:dictionary];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:sivc animated:YES];
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    self.events = [dictionary objectForKey:@"data"];
    
    // Reload all table data
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
