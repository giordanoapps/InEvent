//
//  PeopleViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "GroupCircleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "UIImageView+WebCache.h"
#import "UtilitiesController.h"
#import "CoolBarButtonItem.h"
#import "GroupCircleViewCell.h"
#import "GroupCirclePeopleViewCell.h"
#import "InEventAPI.h"

@interface GroupCircleViewController () {
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedPath;
    NSString *dataPath;
    NSMutableArray *groups;
    NSCache *peopleCache;
}

@end

@implementation GroupCircleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"People", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Group"];
        peopleCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add Button
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) [self loadAddButton];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    // Collection View
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PeopleViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleViewCell"];
    
    // Add Group
    [_nameInput setPlaceholder:NSLocalizedString(@"Name", nil)];
    [_addGroupButton setTitle:NSLocalizedString(@"Add group", nil) forState:UIControlStateNormal];
    
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getGroupsAtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
    } else {
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getGroupsAtEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Bar Methods

- (void)loadAddButton {
    // Right Button
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Plus-2.png"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(loadAddGroupView)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)loadDoneButton {
    // Right Button
    self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeGroupView)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

#pragma mark - Add People Methods

- (void)loadAddGroupView {
    // Add the frame
    [_addGroupView setFrame:CGRectMake(_addGroupView.frame.origin.x, -(_addGroupView.frame.size.height), self.view.frame.size.width, _addGroupView.frame.size.height)];
    [self.view addSubview:_addGroupView];
    
    // Animate the transition
    [UIView animateWithDuration:1.0f animations:^{
        [_addGroupView setFrame:CGRectMake(_addGroupView.frame.origin.x, _addGroupView.frame.origin.y + _addGroupView.frame.size.height, _addGroupView.frame.size.width, _addGroupView.frame.size.height)];
    } completion:^(BOOL completion){
        [self loadDoneButton];
    }];
}

- (void)removeGroupView {
    // Resign the text field responders
    [_nameInput resignFirstResponder];
    
    // Animate the transition
    [UIView animateWithDuration:1.0f animations:^{
        [_addGroupView setFrame:CGRectMake(_addGroupView.frame.origin.x, -(_addGroupView.frame.size.height), _addGroupView.frame.size.width, _addGroupView.frame.size.height)];
    } completion:^(BOOL completion){
        [_addGroupView removeFromSuperview];
        [self loadAddButton];
    }];
}

- (IBAction)addGroup {
    
    if ([_nameInput.text length] > 0) {
        // Send to server
        [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:YES] createGroupAtEvent:[[EventToken sharedInstance] eventID] withName:_nameInput.text withTokenID:[[HumanToken sharedInstance] tokenID]];
        
        // Remove view
        [self removeGroupView];
    }
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
        return [groups count];
    } else {
        return [[peopleCache objectForKey:collectionView] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:_collectionView]) {

        GroupCircleViewCell *cell = (GroupCircleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
        
        NSDictionary *dictionary = [groups objectAtIndex:indexPath.row];
        
        if (selectedPath && [selectedPath compare:indexPath] == NSOrderedSame) {
            [self buildSelectedPeopleViewCell:cell withDictionary:dictionary];
        } else {
            [self buildPeopleViewCell:cell withDictionary:dictionary];
        }
        
        return cell;

    } else {
        
        GroupCirclePeopleViewCell *cell = (GroupCirclePeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier: @"PeopleGroupViewCell" forIndexPath:indexPath];
        
        NSDictionary *dictionary = [[peopleCache objectForKey:collectionView] objectAtIndex:indexPath.row];
        if ([[dictionary objectForKey:@"image"] length] > 0) {
            [cell.image setImage:[NSURL URLWithString:[[dictionary objectForKey:@"image"] stringByDecodingHTMLEntities]]];
        } else if ([[dictionary objectForKey:@"name"] length] > 0) {
            cell.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
        }
        
        return cell;
    }
}

- (void)buildSelectedPeopleViewCell:(GroupCircleViewCell *)cell withDictionary:(NSDictionary *)dictionary {
    
    // Label
    if ([[dictionary objectForKey:@"name"] length] > 0) {
        cell.initial.font = [UIFont fontWithName:@"Thonburi-Bold" size:30.0f];
        cell.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
    }

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        [cell.initial.layer setCornerRadius:30.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            cell.initial.frame = CGRectMake(50.0f, 50.0f, 60.0f, 60.0f);
        } completion:^(BOOL finished) {
            // Collection View
            cell.collectionView.userInteractionEnabled = YES;
            cell.collectionView.delegate = weakSelf;
            cell.collectionView.dataSource = weakSelf;
            UINib *nib = [UINib nibWithNibName:@"PeopleGroupViewCell" bundle:nil];
            [cell.collectionView registerNib:nib forCellWithReuseIdentifier:@"PeopleGroupViewCell"];
            [cell.collectionView reloadData];
        }];
    }];
}

- (void)buildPeopleViewCell:(GroupCircleViewCell *)cell withDictionary:(NSDictionary *)dictionary {
    
    // Label
    cell.initial.font = [UIFont fontWithName:@"Thonburi" size:20.0f];
    cell.initial.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    
    [UIView animateWithDuration:0.2f animations:^{
        [cell.initial.layer setCornerRadius:12.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            cell.initial.frame = CGRectMake(20.0f, 20.0f, 120.0f, 120.0f);
        } completion:^(BOOL finished) {
            // Collection View
            cell.collectionView.userInteractionEnabled = NO;
        }];
    }];
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:_collectionView]) {
        
        if (selectedPath && [selectedPath compare:indexPath] == NSOrderedSame) {
            
            // Update the UI
            [self buildPeopleViewCell:(GroupCircleViewCell *)[self.collectionView cellForItemAtIndexPath:selectedPath] withDictionary:[groups objectAtIndex:selectedPath.row]];
            
            // Reset the selected path
            selectedPath = nil;
            
        } else {
            
            // Reload the old index path
            if (selectedPath != nil) {
                NSIndexPath *oldSelectedPath = selectedPath;
                selectedPath = indexPath;
                [self buildPeopleViewCell:(GroupCircleViewCell *)[self.collectionView cellForItemAtIndexPath:oldSelectedPath] withDictionary:[groups objectAtIndex:oldSelectedPath.row]];
                
            } else {
                // Save the indexPath
                selectedPath = indexPath;
            }
            
            // Load some data
            NSInteger groupID = [[[groups objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
            UICollectionView *cellView = [(GroupCircleViewCell *)[collectionView cellForItemAtIndexPath:indexPath] collectionView];
            [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:YES withUserInfo:@{@"key": cellView}] getPeopleAtGroup:groupID withTokenID:[[HumanToken sharedInstance] tokenID]];
        
        //    [self.collectionView performBatchUpdates:^{
        //        [self.collectionView reloadItemsAtIndexPaths:@[selectedPath]];
        //        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        //    } completion:nil];
        }
    } else {
        NSLog(@"22");
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

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getGroups"]) {
        // Assign the data object to the groups
        groups = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.collectionView reloadData];
        
    } else if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data to the people
        [peopleCache setObject:[dictionary objectForKey:@"data"] forKey:[apiController.userInfo objectForKey:@"key"]];
        
        // Reload some specific rows
        [self buildSelectedPeopleViewCell:(GroupCircleViewCell *)[self.collectionView cellForItemAtIndexPath:selectedPath] withDictionary:[groups objectAtIndex:selectedPath.row]];
        
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
    
    [refreshControl endRefreshing];
}

@end
