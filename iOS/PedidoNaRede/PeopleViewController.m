//
//  PeopleViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "UIImageView+WebCache.h"
#import "CoolBarButtonItem.h"
#import "InEventAPI.h"
#import "PeopleViewCell.h"
#import "PersonViewController.h"

@interface PeopleViewController () {
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedPath;
    NSString *dataPath;
    NSMutableArray *peopleData;
}

@end

@implementation PeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"People", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Group"];
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
    [self.collectionView addSubview:refreshControl];
    
    // Collection View
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PeopleViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleViewCell"];
    
    // Load people
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getPeopleAtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [peopleData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    PeopleViewCell *cell = (PeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
    
    NSDictionary *dictionary = [peopleData objectAtIndex:indexPath.row];
    [cell layoutInformation:dictionary withDesiredWordCount:2];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    PersonViewController *pvc;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        pvc = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    } else {
        // Find the sibling navigation controller first child and send the appropriate data
        pvc = (PersonViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
    }
    
    NSDictionary *dictionary = [peopleData objectAtIndex:indexPath.row];
    
    [pvc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
    [pvc setPersonData:[peopleData objectAtIndex:indexPath.row]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:pvc animated:YES];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data object to the groups
        peopleData = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.collectionView reloadData];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        [self reloadData];
    }
    
    [refreshControl endRefreshing];
}

- (void)apiController:(InEventAPIController *)apiController didSaveForLaterWithError:(NSError *)error {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Save the path of the current file object
        dataPath = apiController.path;
    } else {
        // Save the current object
        [[NSDictionary dictionaryWithObject:peopleData forKey:@"data"] writeToFile:dataPath atomically:YES];
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
    
    [refreshControl endRefreshing];
}

- (void)apiController:(InEventAPIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
