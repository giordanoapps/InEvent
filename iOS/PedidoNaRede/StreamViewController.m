//
//  ScheduleViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "StreamViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "StreamViewCell.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "ODRefreshControl.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "CoolBarButtonItem.h"

@interface StreamViewController () {
    ODRefreshControl *refreshControl;
    NSArray *posts;
    FBRequestConnection *requestConnection;
    NSCache *imagesCache;
}

@end

@implementation StreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Photos", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Image-2"];
        
        // Alloc variables
        imagesCache = [[NSCache alloc] init];
        
        // Add notification observer for updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"scheduleCurrentState" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"activityNotification" object:nil];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation delegate
    self.navigationController.delegate = self;
    
    // Schedule details
    [self loadData];
    [self sendRequests];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(sendRequests) forControlEvents:UIControlEventValueChanged];
    
    // Right Button
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Image"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Send photo", nil);
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
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetActivitiesAtEvent:[[EventToken sharedInstance] eventID] withTokenID:tokenID];
    } else {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetActivitiesAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Facebook Methods

- (void)sendRequests {
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection result:result error:error];
    };

    // Make the API request that uses FQL
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:[NSString stringWithFormat:@"/search?q=%@&type=post", @"brazil"] parameters:nil HTTPMethod:@"GET"];
    
//                          [[EventToken sharedInstance] nick]]
                          
    [newConnection addRequest:request completionHandler:handler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [requestConnection cancel];
    requestConnection = newConnection;
    [newConnection start];
}

- (void)requestCompleted:(FBRequestConnection *)connection result:(id)result error:(NSError *)error {
    
    if (requestConnection && connection != requestConnection) return;
    
    requestConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error) {
        // error contains details about why the request failed
        NSLog(@"%@", error.localizedDescription);
    } else {
        // Assign all the results
        posts = [(NSDictionary *)result objectForKey:@"data"];
        
        // Reload the table
        [self.tableView reloadData];
        
        // Stop refreshing
        [refreshControl endRefreshing];
    }
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    //    NSString *title = (selection == ScheduleSubscribed) ? NSLocalizedString(@"All activities", nil) : NSLocalizedString(@"My activities", nil);
    
    UIActionSheet *actionSheet;
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Event details", nil), NSLocalizedString(@"Send feedback", nil), NSLocalizedString(@"Exit event", nil), nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Event details", nil), NSLocalizedString(@"Exit event", nil), nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Event details", nil)]) {
    
    }
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 
//    NSDictionary *dictionary = [[posts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadWithURL:[UtilitiesController urlWithFile:[dictionary objectForKey:@"image"]] options:0 progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//
//        if (image != nil) {
//            return image.size.height;
//        }
//    }];
    

    if ([imagesCache objectForKey:indexPath] != NULL) {
        CGSize size = ((UIImage *)[imagesCache objectForKey:indexPath]).size;
        return (self.view.frame.size.width / size.width) * size.height;
    } else {
        return 0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CustomCellIdentifier = @"CustomCellIdentifier";
    StreamViewCell * cell = (StreamViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"StreamViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell =  (StreamViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [posts objectAtIndex:indexPath.row];
    [cell.picture setImageWithURL:[NSURL URLWithString:[[dictionary objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"_s." withString:@"_n."]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        // Save the image
        [imagesCache setObject:image forKey:indexPath];
        
        // Reload it
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    return cell;
}

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    ScheduleItemViewController *sivc;
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
//        [sivc setMoveKeyboardRatio:0.0f];
//    } else {
//        // Find the sibling navigation controller first child and send the appropriate data
//        sivc = (ScheduleItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
//        [sivc setMoveKeyboardRatio:0.5f];
//    }
//    
//    NSDictionary *dictionary = [[posts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    [sivc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
//    [sivc setActivityData:dictionary];
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController pushViewController:sivc animated:YES];
//        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Reload all table data
    [self.tableView reloadData];
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
