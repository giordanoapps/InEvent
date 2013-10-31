//
//  MarketplaceViewController.m
//  InEvent
//
//  Created by Pedro Góes on 03/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Parse/Parse.h>
#import "MarketplaceViewController.h"
#import "MarketplaceViewCell.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+AKTabBarController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Enrollment.h"
#import "InEventAPI.h"

@interface MarketplaceViewController () {
    UIRefreshControl *refreshControl;
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
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self loadData];
    }
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getEventsWithTokenID:tokenID];
    } else {
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getEvents];
    }
}

#pragma mark - Private Methods

- (IBAction)tapEnroll:(UITapGestureRecognizer *)gestureRecognizer {
    
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    [[[InEventEventAPIController alloc] initWithDelegate:self forcing:YES] requestEnrollmentAtEvent:[[[self.events objectAtIndex:swipedIndexPath.row] objectForKey:@"id"] integerValue] withTokenID:tokenID];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    MarketplaceViewCell *cell = (MarketplaceViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"MarketplaceViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell = (MarketplaceViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [self.events objectAtIndex:indexPath.row];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    cell.dateBegin.text = [NSString stringWithFormat:@"%.2d/%.2d", [components day], [components month]];
    cell.timeBegin.text = [NSString stringWithFormat:@"%.2d:%.2d", [components hour], [components minute]];
    
    date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateEnd"] integerValue]];
    components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    cell.dateEnd.text = [NSString stringWithFormat:@"%.2d/%.2d", [components day], [components month]];
    cell.timeEnd.text = [NSString stringWithFormat:@"%.2d:%.2d", [components hour], [components minute]];
    
    cell.name.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.approved = [[dictionary objectForKey:@"approved"] integerValue];
    
    // Only query the enrollment date if necessary
    if (cell.approved == EnrollmentStateUnknown) {
        NSDate *enrollmentBegin = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"enrollmentBegin"] integerValue]];
        NSDate *enrollmentEnd = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"enrollmentEnd"] integerValue]];
        
        if ([[NSDate date] compare:enrollmentBegin] == NSOrderedDescending
            && [[NSDate date] compare:enrollmentEnd] == NSOrderedAscending) {
            cell.canEnroll = YES;
        } else {
            cell.canEnroll = NO;
        }
    } else {
        cell.canEnroll = NO;
    }
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEnroll:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    [cell.status addGestureRecognizer:tapRecognizer];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // We set some essential data
    NSDictionary *dictionary = [self.events objectAtIndex:indexPath.row];
    
    // Get some properties
    NSInteger eventID = [[dictionary objectForKey:@"id"] integerValue];
    
    [[EventToken sharedInstance] setEventID:eventID];
    [[EventToken sharedInstance] setName:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
    [[EventToken sharedInstance] setNick:[[dictionary objectForKey:@"nickname"] stringByDecodingHTMLEntities]];
    [[HumanToken sharedInstance] setApproved:[[dictionary objectForKey:@"approved"] integerValue]];
    
    // Notify our tracker about the new event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"event" action:@"getEvents" label:@"iOS" value:[NSNumber numberWithInteger:eventID]] build]];
    
    // Notify our tracker about the new event
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"event_%d", eventID] forKey:@"channels"];
    [currentInstallation saveEventually];
    
    // Update the current state of the schedule controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    

//    AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enroll on the event before proceeding.", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok!", nil)];
//    [alertView show];
    
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getEvents"]) {
        // Assign the data object to the companies
        self.events = [dictionary objectForKey:@"data"];
        
        // Reload all table data
        [self.tableView reloadData];
        
        [refreshControl endRefreshing];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        // Force reload
        [self forceDataReload:YES];
    }
}

- (void)apiController:(InEventAPIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
