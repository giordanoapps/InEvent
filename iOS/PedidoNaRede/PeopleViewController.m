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

@interface PeopleViewController () {
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedPath;
    NSString *dataPath;
    NSMutableArray *people;
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
    return [people count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    PeopleViewCell *cell = (PeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
    
    NSDictionary *dictionary = [people objectAtIndex:indexPath.row];
    
    if ([[dictionary objectForKey:@"facebookID"] integerValue] != 0) {
        [cell.image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=%d&height=%d", [dictionary objectForKey:@"facebookID"], (int)(cell.image.frame.size.width * [[UIScreen mainScreen] scale]), (int)(cell.image.frame.size.height * [[UIScreen mainScreen] scale])]] placeholderImage:[UIImage imageNamed:@"128-user"]];
        [cell.image setHidden:NO];
        [cell.initial setHidden:YES];
    } else if (![[dictionary objectForKey:@"image"] isEqualToString:@""]) {
        [cell.image setImageWithURL:[NSURL URLWithString:[[dictionary objectForKey:@"image"] stringByDecodingHTMLEntities]] placeholderImage:[UIImage imageNamed:@"128-user"]];
        [cell.image setHidden:NO];
        [cell.initial setHidden:YES];
    } else if (![[dictionary objectForKey:@"name"] isEqualToString:@""]) {
        NSString *name = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
        NSMutableArray *split = [NSMutableArray arrayWithArray:[[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "]];
        if ([split count] > 1) {
            for (int i = 0; i < [split count]; i++) {
                if ([[split objectAtIndex:i] length] == 0) [split removeObjectAtIndex:i];
            }
            
            cell.initial.text = [NSString stringWithFormat:@"%@ %@.", [[split objectAtIndex:0] substringToIndex:1], [[split objectAtIndex:1] substringToIndex:1]];
        } else {
           cell.initial.text = [name substringToIndex:1];
        }
        [cell.image setHidden:YES];
        [cell.initial setHidden:NO];
    }
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data object to the groups
        people = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.collectionView reloadData];
        
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
        [[NSDictionary dictionaryWithObject:people forKey:@"data"] writeToFile:dataPath atomically:YES];
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
}

@end
