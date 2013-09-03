//
//  OrderViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

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
#import "CoolBarButtonItem.h"

@interface ScheduleViewController () {
    ODRefreshControl *refreshControl;
}

@property (nonatomic, strong) NSArray *activities;

@end

@implementation ScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Schedule", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Map"];
        self.activities = [NSArray array];
        
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"scheduleCurrentState" object:nil];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Schedule details
    [self loadData];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    // Right Button
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"64-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Event Actions", nil);
    self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Reload data to calculate the right frame
    [self.tableView reloadData];
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
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetScheduleAtEvent:[[EventToken sharedInstance] eventID] withTokenID:tokenID];
    } else {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetActivitiesAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Exit restaurant", nil), nil];
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Exit restaurant", nil)]) {
        // Remove the tokenID and enterprise
        [[EventToken sharedInstance] removeEvent];
        
        // Check for it again
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
        
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.activities count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.activities objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    [background setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    NSDictionary *dictionary = [[self.activities objectAtIndex:section] objectAtIndex:0];
    
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
    
    NSDictionary *dictionary = [[self.activities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
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
    
    NSDictionary *dictionary = [[self.activities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
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
    self.activities = [dictionary objectForKey:@"data"];
    
    // Reload all table data
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];

    [refreshControl endRefreshing];
}

@end
