//
//  ScheduleViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ScheduleViewCell.h"
#import "ScheduleItemViewController.h"
#import "FrontViewController.h"
#import "FeedbackViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+AKTabBarController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "CoolBarButtonItem.h"
#import "Schedule.h"
#import "InEventEventAPIController.h"

@interface ScheduleViewController () {
    UIRefreshControl *refreshControl;
    NSArray *activities;
    ScheduleSelection selection;
}

@end

@implementation ScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Schedule", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Day-Calendar"];
        activities = [NSArray array];
        selection = ([[HumanToken sharedInstance] isMemberAuthenticated] && [[HumanToken sharedInstance] isMemberApproved]) ? ScheduleSubscribed : ScheduleAll;
        
        // Add notification observer for updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"eventCurrentState" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"activityNotification" object:nil];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Right Button
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) [self loadMenuButton];
    
    // Navigation delegate
    self.navigationController.delegate = self;
    
    // Schedule details
    [self loadData];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
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

#pragma mark - Loader

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getActivitiesAtEvent:[[EventToken sharedInstance] eventID] withTokenID:tokenID];
    } else {
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getActivitiesAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Red Line

- (void)createRedLineAtPosition:(CGRect)frame {
    UIView *redLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.origin.y, frame.size.width, 2.5f)];
    [redLine setBackgroundColor:[UIColor redColor]];
    [redLine setAlpha:0.2f];
    [self.tableView addSubview:redLine];
    
    // Remove red line
    [self performSelector:@selector(removeRedLine:) withObject:redLine afterDelay:2.0f];
}

- (void)removeRedLine:(UIView *)redLine {
    [UIView animateWithDuration:1.2f animations:^{
        [redLine setAlpha:0.0f];
    } completion:^(BOOL finished){
        [redLine removeFromSuperview];
    }];
}

#pragma mark - Private Methods

- (void)loadMenuButton {
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
    self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
//    NSString *title = (selection == ScheduleSubscribed) ? NSLocalizedString(@"All activities", nil) : NSLocalizedString(@"My activities", nil);
    
    UIActionSheet *actionSheet;
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"Send feedback", nil), nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"All activities", nil)]) {
        // Get all the activities
        selection = ScheduleAll;
        
        [self loadData];
        
    } else if ([title isEqualToString:NSLocalizedString(@"My activities", nil)]) {
        // Get only the activities that we are enrolled to
        selection = ScheduleSubscribed;
        
        [self loadData];
        
    } else if ([title isEqualToString:NSLocalizedString(@"Send feedback", nil)]) {
        // Load our reader
        FeedbackViewController *fvc = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        UINavigationController *nfvc = [[UINavigationController alloc] initWithRootViewController:fvc];
        
        [fvc setFeedbackType:FeedbackTypeEvent withReference:[[EventToken sharedInstance] eventID]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nfvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nfvc.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            nfvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nfvc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nfvc animated:YES completion:nil];
        
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [activities count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[activities objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0)];
    [background setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    NSDictionary *dictionary = [[activities objectAtIndex:section] objectAtIndex:0];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 6.0, tableView.frame.size.width, 32.0)];
    [title setText:[NSString stringWithFormat:@"%.2d/%.2d - %@", [components day], [components month], [UtilitiesController weekNameFromIndex:[components weekday]]]];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setFont:[UIFont fontWithName:@"Thonburi-Bold" size:17.0]];
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
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    ScheduleViewCell *cell = (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"ScheduleViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell = (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [[activities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    cell.hour.text = [NSString stringWithFormat:@"%.2d", [components hour]];
    cell.minute.text = [NSString stringWithFormat:@"%.2d", [components minute]];
    cell.name.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.description.text = [[dictionary objectForKey:@"description"] stringByDecodingHTMLEntities];
    cell.approved = [[dictionary objectForKey:@"approved"] integerValue];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ScheduleItemViewController *sivc;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
    } else {
        // Find the sibling navigation controller first child and send the appropriate data
        sivc = (ScheduleItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
    }
    
    NSDictionary *dictionary = [[activities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [sivc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
    [sivc setActivityData:dictionary];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:sivc animated:YES];
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Reload all table data
    [self.tableView reloadData];
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    activities = [dictionary objectForKey:@"data"];
    
    // Reload all table data
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
    
    // Scroll to the current moment
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    for (int i = 0; i < [activities count]; i++) {
        for (int j = 0; j < [[activities objectAtIndex:i] count]; j++) {
            // Get the current dictionary
            NSDictionary *activity = [[activities objectAtIndex:i] objectAtIndex:j];
            
            // See if it matches
            if (timestamp < [[activity objectForKey:@"dateEnd"] integerValue]) {
                
                // Current index path
                NSIndexPath *currentPath = [NSIndexPath indexPathForRow:((j > 0) ? (j - 1) : j) inSection:i];
                
                // Create a temporary red line
                [self createRedLineAtPosition:[self.tableView rectForRowAtIndexPath:currentPath]];
                
                // Scroll to the moment before the next activity finishes
                [self.tableView scrollToRowAtIndexPath:currentPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                // Break the current loop
                return;
            }
        }
    }
}

- (void)apiController:(InEventAPIController *)apiController didSaveForLaterWithError:(NSError *)error {
    [super apiController:apiController didSaveForLaterWithError:error];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(InEventAPIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];

    [refreshControl endRefreshing];
}

@end
