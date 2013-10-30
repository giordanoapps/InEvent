//
//  GroupViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "GroupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "UIImageView+WebCache.h"
#import "UtilitiesController.h"
#import "CoolBarButtonItem.h"
#import "GroupViewCell.h"
#import "PeopleViewCell.h"
#import "InEventAPI.h"

@interface GroupViewController () {
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedPath;
    NSString *dataPath;
    NSMutableArray *groups;
    NSCache *peopleCache;
}

@end

@implementation GroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Group", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Users"];
        peopleCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // Table View
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Load groups
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getGroupsAtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
    } else {
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getGroupsAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [groups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    GroupViewCell *cell = (GroupViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"GroupViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell = (GroupViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [groups objectAtIndex:indexPath.row];
    
    [cell.collectionView registerNib:[UINib nibWithNibName:@"PeopleViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleViewCell"];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setDelegate:self];
    cell.name.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.description.text = [[dictionary objectForKey:@"description"] stringByDecodingHTMLEntities];
    
    if ([peopleCache objectForKey:indexPath] != NULL) {
        // Load offline data
        [cell.collectionView reloadData];
    } else {
        // Download some data
        NSInteger groupID = [[dictionary objectForKey:@"id"] integerValue];
        [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:NO withUserInfo:@{@"key": indexPath}] getPeopleAtGroup:groupID withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
    
    return cell;
}

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    ScheduleItemViewController *sivc;
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
//    } else {
//        // Find the sibling navigation controller first child and send the appropriate data
//        sivc = (ScheduleItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
//    }
//    
//    NSDictionary *dictionary = [[activities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    [sivc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
//    [sivc setActivityData:dictionary];
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController pushViewController:sivc animated:YES];
//        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CGPoint point = [collectionView convertPoint:collectionView.bounds.origin toView:self.tableView];
    NSIndexPath *parentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    return [[peopleCache objectForKey:parentIndexPath] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    PeopleViewCell *cell = (PeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
    
    GroupViewCell *groupViewCell = (GroupViewCell *)[[collectionView superview] superview];
    NSIndexPath *parentIndexPath = [self.tableView indexPathForCell:groupViewCell];
    NSDictionary *dictionary = [[peopleCache objectForKey:parentIndexPath] objectAtIndex:indexPath.row];
    
    if ([[dictionary objectForKey:@"image"] length] > 0) {
        [cell.image setImageWithURL:[NSURL URLWithString:[[dictionary objectForKey:@"image"] stringByDecodingHTMLEntities]]];
    } else if ([[dictionary objectForKey:@"name"] length] > 0) {
        cell.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
    }
    
    return cell;
}

#pragma mark - Collection View Delegate

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if ([collectionView isEqual:_collectionView]) {
//        
//        if (selectedPath && [selectedPath compare:indexPath] == NSOrderedSame) {
//            
//            // Update the UI
//            [self buildPeopleViewCell:(GroupCircleViewCell *)[self.collectionView cellForItemAtIndexPath:selectedPath] withDictionary:[groups objectAtIndex:selectedPath.row]];
//            
//            // Reset the selected path
//            selectedPath = nil;
//            
//        } else {
//            
//            // Reload the old index path
//            if (selectedPath != nil) {
//                NSIndexPath *oldSelectedPath = selectedPath;
//                selectedPath = indexPath;
//                [self buildPeopleViewCell:(GroupCircleViewCell *)[self.collectionView cellForItemAtIndexPath:oldSelectedPath] withDictionary:[groups objectAtIndex:oldSelectedPath.row]];
//                
//            } else {
//                // Save the indexPath
//                selectedPath = indexPath;
//            }
//            
//            // Load some data
//            NSInteger groupID = [[[groups objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
//            UICollectionView *cellView = [(GroupCircleViewCell *)[collectionView cellForItemAtIndexPath:indexPath] collectionView];
//            [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:YES withUserInfo:@{@"key": cellView}] getPeopleAtGroup:groupID withTokenID:[[HumanToken sharedInstance] tokenID]];
//            
//            //    [self.collectionView performBatchUpdates:^{
//            //        [self.collectionView reloadItemsAtIndexPaths:@[selectedPath]];
//            //        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//            //    } completion:nil];
//        }
//    } else {
//        NSLog(@"22");
//    }
//}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(40.0f, 40.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getGroups"]) {
        // Assign the data object to the groups
        groups = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.tableView reloadData];
        
    } else if ([apiController.method isEqualToString:@"getPeople"]) {
        
        // Get the proper cell
        NSIndexPath *indexPath = [apiController.userInfo objectForKey:@"key"];
        
        // Assign the data to the people
        [peopleCache setObject:[dictionary objectForKey:@"data"] forKey:indexPath];
        
        // Reload some specific rows
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        [self reloadData];
    }
    
    [refreshControl endRefreshing];
}

- (void)apiController:(InEventAPIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(InEventAPIController *)apiController didSaveForLaterWithError:(NSError *)error {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Save the path of the current file object
        dataPath = apiController.path;
    } else {
        // Save the current object
        [[NSDictionary dictionaryWithObject:groups forKey:@"data"] writeToFile:dataPath atomically:YES];
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
}

@end
