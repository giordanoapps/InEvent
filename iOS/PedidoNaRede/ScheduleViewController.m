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
        self.title = [self tabTitle];
        self.accessibilityLabel = [self tabTitle];
        self.activities = [NSArray array];
        
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendOrder:) name:@"sendOrder" object:nil];
    }
    return self;
}

#pragma mark - AKTabBarController Category

- (NSString *)tabTitle {
    return NSLocalizedString(@"Order", nil);
}

- (NSString *)tabImageName {
    return @"32-Shopping-Basket";
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [ColorThemeController tableViewCellBorderColor];
    _tableView.rowHeight = 100;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification

- (void)loadData {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventGetScheduleAtEvent:[[EventToken sharedInstance] eventID] withTokenID:tokenID];
    } else {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventGetActivitiesAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

- (void)processNotification:(NSNotification *)notification {
    [self loadData];
}

#pragma mark - Public Methods

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.activities count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CustomCellIdentifier = @"CustomCellIdentifier";
    ScheduleViewCell * cell = (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"OrderItemViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell =  (ScheduleViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [self.activities objectAtIndex:indexPath.row];

//    NSDateFormatter *lastChange = [[NSDateFormatter alloc] init];
//    [lastChange setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    NSTimeZone *gmt = [NSTimeZone timeZoneForSecondsFromGMT:-(3*60*60)];
//    [lastChange setTimeZone:gmt];
//    NSTimeInterval carteDate = [[lastChange dateFromString:dateText] timeIntervalSince1970];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"dateBegin"] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    cell.hour.text = [NSString stringWithFormat:@"%d", [components hour]];
    cell.minute.text = [NSString stringWithFormat:@"%d", [components minute]];
    cell.title.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.description.text = [[dictionary objectForKey:@"description"] stringByDecodingHTMLEntities];

//    cell.orderStatusView.backgroundColor = [UtilitiesController colorFromHexString:[dictionary objectForKey:@"color"]];
    
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
    
    [sivc setActivityData:[_activities objectAtIndex:indexPath.row]];
    
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

@end
