//
//  GroupDetailViewController.m
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "GroupDetailViewController.h"
#import "SocialLoginViewController.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "CoolBarButtonItem.h"
#import "UIImageView+WebCache.h"
#import "InEventAPI.h"
#import "PeopleViewCell.h"
#import "PersonViewController.h"

@interface GroupDetailViewController () {
    UIRefreshControl *refreshControl;
    BOOL editingMode;
    CLLocationManager *locationManager;
}

@end

@implementation GroupDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Wrapper
    _wrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    // Collection View
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PeopleViewCell" bundle:nil] forCellWithReuseIdentifier:@"PeopleViewCell"];
    
    // Text fields
    _name.textColor = [ColorThemeController tableViewCellTextColor];
    _description.textColor = [ColorThemeController tableViewCellTextHighlightedColor];
    _location.textColor = [ColorThemeController tableViewCellTextColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self cleanData];
        [self paint];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self cleanData];
        [self paint];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loader Methods

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:forcing] getPeopleAtGroup:[[_groupData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Setter Methods

- (void)setGroupData:(NSDictionary *)groupData {
    _groupData = groupData;
    
    [self cleanData];
    [self paint];
}

- (void)setPeopleData:(NSArray *)peopleData {
    _peopleData = peopleData;
    
    [self.collectionView reloadData];
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (_groupData) {
        
        // Actions
        if ([[HumanToken sharedInstance] isMemberAuthenticated]) [self loadMenuButton];
        
        // Text fields
        self.name.text = [[_groupData objectForKey:@"name"] stringByDecodingHTMLEntities];
        self.description.text = [[_groupData objectForKey:@"description"] stringByDecodingHTMLEntities];
        self.location.text = [[_groupData objectForKey:@"location"] stringByDecodingHTMLEntities];
    }
}

#pragma mark - Private Methods

- (void)cleanData {
    if (editingMode) [self endEditing];
    self.navigationItem.rightBarButtonItem = nil;
    [_name setText:NSLocalizedString(@"Activity", nil)];
    [_description setText:@""];
}

- (void)loadMenuButton {
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
    self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)loadDoneButton {
    self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

#pragma mark - Editing

- (void)startEditing {
    
    // Set the placeholders
    [self.name setPlaceholder:self.name.text];
    [self.description setPlaceholder:self.description.text];
    [self.location setPlaceholder:self.location.text];
    
    // Start editing
    editingMode = YES;
    
    [self loadDoneButton];
}

- (void)saveEditing:(UIView *)field forName:(NSString *)name {
    
    // Save the fields
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    // Field will always have a placeholder, so we can cast it as a UITextField
    if (![((UITextField *)field).placeholder isEqualToString:((UITextField *)field).text]) {
        [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:YES] editField:name withValue:((UITextField *)field).text atGroup:[[_groupData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
}

- (void)endEditing {
    
    // Save the fields
    [self saveEditing:self.name forName:@"name"];
    [self saveEditing:self.description forName:@"description"];
    [self saveEditing:self.location forName:@"location"];
    
    // End editing
    [self.view endEditing:YES];
    editingMode = NO;
    
    [self loadMenuButton];
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet;
    
    if ([[HumanToken sharedInstance] isMemberWorking]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit fields", nil), NSLocalizedString(@"Enroll", nil), nil];
    } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Enroll", nil), nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Edit fields", nil)]) {
        [self startEditing];
    } else if ([title isEqualToString:NSLocalizedString(@"Enroll", nil)]) {
        [[[InEventGroupAPIController alloc] initWithDelegate:self forcing:YES] requestEnrollmentAtGroup:[[_groupData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (editingMode) {
        return [super textFieldShouldBeginEditing:textField];
    } else {
        return NO;
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_peopleData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PeopleViewCell *cell = (PeopleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PeopleViewCell" forIndexPath:indexPath];
    
    NSDictionary *dictionary = [_peopleData objectAtIndex:indexPath.row];
    [cell layoutInformation:dictionary withDesiredWordCount:2];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonViewController *pvc;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        pvc = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    } else {
        // Find the sibling navigation controller first child and send the appropriate data
        pvc = (PersonViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
    }
    
    NSDictionary *dictionary = [_peopleData objectAtIndex:indexPath.row];
    
    [pvc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
    [pvc setPersonData:[_peopleData objectAtIndex:indexPath.row]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:pvc animated:YES];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(80.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getDetails"]) {
        // Assign the data object to people
        _peopleData = [dictionary objectForKey:@"data"];
        
        // Assign the working events
        [[HumanToken sharedInstance] setWorkingEvents:[dictionary objectForKey:@"events"]];
        
        // Pain the UI
        [self paint];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        // Assign the data object to people
        _peopleData = [dictionary objectForKey:@"data"];
        
        // Reload data
        [self.collectionView reloadData];
    }
    
    // Stop refreshing
    [refreshControl endRefreshing];
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
