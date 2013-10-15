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
#import "UtilitiesController.h"
#import "ODRefreshControl.h"
#import "CoolBarButtonItem.h"
#import "PeopleViewCell.h"
#import "PeopleGroupViewCell.h"

@interface PeopleViewController () {
    ODRefreshControl *refreshControl;
    NSString *dataPath;
}

@property (nonatomic, strong) NSMutableArray *people;

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
    
    // Load people
    [self loadData];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.collectionView];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    self.collectionView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PeopleViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleViewCell"];
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
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetPeopleAtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Bar Methods

- (void)loadAddButton {
    // Right Button
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Plus-2.png"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(loadAddPersonView)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)loadDoneButton {
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removePersonView)];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if ([collectionView isEqual:_collectionView]) {
        return 1;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:_collectionView]) {
        return [self.people count];
    } else {
        return 5;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:_collectionView]) {

        PeopleViewCell *cell = (PeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
        
        NSDictionary *dictionary = [self.people objectAtIndex:indexPath.row];
        cell.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
        cell.collectionView.delegate = self;
        cell.collectionView.dataSource = self;
        [cell.collectionView registerNib:[UINib nibWithNibName:@"PeopleGroupViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleGroupViewCell"];
        
        [cell.collectionView reloadData];
        
        return cell;

    } else {
        
        PeopleGroupViewCell *cell = (PeopleGroupViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier: @"PeopleGroupViewCell" forIndexPath:indexPath];
        
        NSDictionary *dictionary = [self.people objectAtIndex:indexPath.row];
        cell.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
        
        return cell;
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:_collectionView]) {
        return CGSizeMake(160.0f, 160.0f);
    } else {
        return CGSizeMake(40.0f, 40.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([collectionView isEqual:_collectionView]) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data object to the companies
        self.people = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.collectionView reloadData];
        
        [refreshControl endRefreshing];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        [self reloadData];
    }
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didSaveForLaterWithError:(NSError *)error {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Save the path of the current file object
        dataPath = apiController.path;
    } else {
        // Save the current object
        [[NSDictionary dictionaryWithObject:self.people forKey:@"data"] writeToFile:dataPath atomically:YES];
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
}

@end
