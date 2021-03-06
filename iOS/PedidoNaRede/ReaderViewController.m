//
//  ReaderViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "ReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "UtilitiesController.h"
#import "CoolBarButtonItem.h"
#import "ReaderViewCell.h"
#import "InEventAPI.h"

@interface ReaderViewController () {
    UIRefreshControl *refreshControl;
    NSIndexPath *hightlightedIndexPath;
    NSIndexPath *panIndexPath;
    CGPoint panStartLocation;
    NSString *dataPath;
    NSArray *titleIndexes;
}

@property (nonatomic, strong) NSMutableArray *people;

@end

@implementation ReaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Reader", nil);
        self.people = [NSMutableArray array];
        titleIndexes = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"X", @"Z"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add People View
    [self loadAddButton];
    
    // View
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [tapGesture setDelegate:self];
    [self.view addGestureRecognizer:tapGesture];
    
    // Add person
    [_nameInput setPlaceholder:NSLocalizedString(@"Name", nil)];
    [_emailInput setPlaceholder:NSLocalizedString(@"Email", nil)];
    [_addPersonButton setTitle:NSLocalizedString(@"Add person", nil) forState:UIControlStateNormal];
    
    // Number field
    [_numberInput setFrame:CGRectMake(_numberInput.frame.origin.x, _numberInput.frame.origin.y, _numberInput.frame.size.width, _numberInput.frame.size.height * 2.0)];
    [_numberInput setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_numberInput setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [_numberInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_numberInput.layer setCornerRadius:6.0];
    [_numberInput.layer setMasksToBounds:NO];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [_numberInput.layer setBorderWidth:1.0];
        [_numberInput.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    }
    
    // Message Button
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [_numberButton setBackgroundImage:[[UIImage imageNamed:@"greyButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateNormal];
        [_numberButton setBackgroundImage:[[UIImage imageNamed:@"greyButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateHighlighted];
        [_numberButton.layer setMasksToBounds:YES];
        [_numberButton.layer setCornerRadius:4.0];
        [_numberButton.layer setBorderWidth:0.6];
        [_numberButton.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    }
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // Table View
    [self.tableView setSectionIndexColor:[ColorThemeController tableViewCellTextColor]];
    [self.tableView setAllowsSelection:NO];
    
    // Load people
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self allocTapBehind];
    
    // Table View
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [panGesture setDelegate:self];
    [self.tableView addGestureRecognizer:panGesture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self deallocTapBehind];
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
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
        [[[InEventActivityAPIController alloc] initWithDelegate:self forcing:forcing] getPeopleAtActivity:activityID withTokenID:tokenID];
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

#pragma mark - Add People Methods

- (void)loadAddPersonView {
    // Add the frame
    [_addPersonView setFrame:CGRectMake(_addPersonView.frame.origin.x, -(_addPersonView.frame.size.height), self.view.frame.size.width, _addPersonView.frame.size.height)];
    [self.view addSubview:_addPersonView];
    
    // Animate the transition
    [UIView animateWithDuration:0.7f animations:^{
        [_addPersonView setFrame:CGRectMake(_addPersonView.frame.origin.x, _addPersonView.frame.origin.y + _addPersonView.frame.size.height, _addPersonView.frame.size.width, _addPersonView.frame.size.height)];
    } completion:^(BOOL completion){
        [self loadDoneButton];
    }];
}

- (void)removePersonView {
    // Resign the text field responders
    [_nameInput resignFirstResponder];
    [_emailInput resignFirstResponder];
    
    // Animate the transition
    [UIView animateWithDuration:0.7f animations:^{
        [_addPersonView setFrame:CGRectMake(_addPersonView.frame.origin.x, -(_addPersonView.frame.size.height), _addPersonView.frame.size.width, _addPersonView.frame.size.height)];
    } completion:^(BOOL completion){
        [_addPersonView removeFromSuperview];
        [self loadAddButton];
    }];
}

- (IBAction)addPerson {

    if ([_nameInput.text length] > 0 && [_emailInput.text length] > 0) {
        // Send to server
        [[[InEventActivityAPIController alloc] initWithDelegate:self forcing:YES] requestEnrollmentForPersonWithName:_nameInput.text andEmail:_emailInput.text atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
        
        // Remove view
        [self removePersonView];
    }
}

#pragma mark - Private Methods

- (void)didPan:(UIPanGestureRecognizer *)gestureRecognizer {

    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    UITableViewCell *swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        if (abs(velocity.x) > abs(velocity.y)) {
            panIndexPath = swipedIndexPath;
            panStartLocation = [gestureRecognizer locationInView:self.view];
        } else {
            panIndexPath = nil;
        }
        
//        [swipedCell setBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
        [swipedCell setBackgroundView:[[UIView alloc] initWithFrame:swipedCell.contentView.frame]];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        [title setFont:[UIFont fontWithName:@"Thonburi-Bold" size:22.0]];
        [title setTextColor:[ColorThemeController textColor]];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTag:1];
        [swipedCell.backgroundView addSubview:title];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // If we have different paths, we must cancel the operations
        if (panIndexPath != nil && [panIndexPath compare:swipedIndexPath] != NSOrderedSame) {
            [self resetCell:[self.tableView cellForRowAtIndexPath:panIndexPath]];
            
        } else if (panIndexPath != nil) {
            CGPoint actualLocation = [gestureRecognizer locationInView:self.view];
            
            CGRect frame = swipedCell.contentView.frame;
            frame.origin.x = actualLocation.x - panStartLocation.x;
            swipedCell.contentView.frame = frame;
            
            UISwipeGestureRecognizerDirection direction = (actualLocation.x > panStartLocation.x) ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft;
            
            if (direction == UISwipeGestureRecognizerDirectionRight) {
                // Green on background color
                [swipedCell.backgroundView setBackgroundColor:[UtilitiesController colorFromHexString:@"#F0F01E"]];
                
                for (UIView *view in [swipedCell.backgroundView subviews]) {
                    if ([view isKindOfClass:[UILabel class]]) {
                        [(UILabel *)view setFrame:CGRectMake(21.0, 6.0, self.tableView.frame.size.width, 32.0)];
                        [(UILabel *)view setText:NSLocalizedString(@"Present", nil)];
                        [(UILabel *)view setTextAlignment:NSTextAlignmentLeft];
                    }
                }
                
            } else if (direction == UISwipeGestureRecognizerDirectionLeft) {
                // Yellow on background color
                [swipedCell.backgroundView setBackgroundColor:[UtilitiesController colorFromHexString:@"#278D27"]];

                for (UIView *view in [swipedCell.backgroundView subviews]) {
                    if ([view isKindOfClass:[UILabel class]]) {
                        [(UILabel *)view setFrame:CGRectMake(-21.0, 6.0, self.tableView.frame.size.width, 32.0)];
                        [(UILabel *)view setText:NSLocalizedString(@"Paid", nil)];
                        [(UILabel *)view setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }
            
            // Swipe went over the limit, so we can validate
            if (fabsf(actualLocation.x - panStartLocation.x) >= self.tableView.frame.size.width * 0.4f) {
                if (direction == UISwipeGestureRecognizerDirectionRight) {
                    [self toggleEntranceForIndexPath:swipedIndexPath highligthing:NO];
                } else if (direction == UISwipeGestureRecognizerDirectionLeft) {
                    [self togglePaymentForIndexPath:swipedIndexPath];
                }
                
                [self resetCell:swipedCell];
            }
        }
    
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resetCell:swipedCell];
        
    } else {
        [self resetCell:swipedCell];
    }
}

- (void)resetCell:(UITableViewCell *)cell {
    CGRect frame = cell.contentView.frame;
    frame.origin.x = 0.0;
    
    // Reset as soon as possible to cancel posterior gestures
    panIndexPath = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        cell.contentView.frame = frame;
    } completion:^(BOOL finished){
        cell.backgroundView = nil;
    }];
}

- (void)didTap {
    // Remove the keyboard
    [_numberInput resignFirstResponder];
}

- (IBAction)didTouch {
    // Get the current number and confirm it
    [self toggleEntranceForIndexPath:hightlightedIndexPath highligthing:YES];
    
    // Erase the current number
    [_numberInput setText:@""];
}

- (void)toggleEntranceForIndexPath:(NSIndexPath *)indexPath highligthing:(BOOL)highlight {
    
    if ([[[self.people objectAtIndex:indexPath.row] objectForKey:@"present"] integerValue] == 0) {
        
        NSInteger memberID = [self confirmAttribute:[NSString stringWithFormat:@"%d", 1] forKey:@"present" atIndexPath:indexPath highligthing:highlight];
        
        if (memberID != 0) {
            // Send it to the server
            [[[InEventActivityAPIController alloc] initWithDelegate:self forcing:YES] confirmEntranceForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
        }
    } else {
        
        NSInteger memberID = [self confirmAttribute:[NSString stringWithFormat:@"%d", 0] forKey:@"present" atIndexPath:indexPath highligthing:highlight];
        
        if (memberID != 0) {
            // Send it to the server
            [[[InEventActivityAPIController alloc] initWithDelegate:self forcing:YES] revokeEntranceForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
        }
    }
}

- (void)togglePaymentForIndexPath:(NSIndexPath *)indexPath {
    NSInteger memberID = [self confirmAttribute:[NSString stringWithFormat:@"%d", 1] forKey:@"paid" atIndexPath:indexPath highligthing:NO];
    
    if (memberID != 0) {
        // Send it to the server
        [[[InEventActivityAPIController alloc] initWithDelegate:self forcing:YES] confirmPaymentForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

- (NSInteger)confirmAttribute:(NSString *)attribute forKey:(NSString *)key atIndexPath:(NSIndexPath *)indexPath highligthing:(BOOL)highlight {
    
    if (indexPath != nil) {
        // Get the current cell
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Update and change the dictionaries inside people
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.people objectAtIndex:[self calculateIndex:indexPath]]];
        [dictionary setObject:attribute forKey:key];
        [self.people replaceObjectAtIndex:[self calculateIndex:indexPath] withObject:dictionary];
        
        // Remove the current hightlighted cell
        [cell setSelected:NO animated:YES];
        hightlightedIndexPath = nil;
        
        // Reload the given row
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (highlight) {
            // Scroll to it
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        return [[dictionary objectForKey:@"memberID"] integerValue];
    }
    
    return 0;
}

#pragma mark - Gesture Recognizer Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIView *cell = [(UIPanGestureRecognizer *)gestureRecognizer view];
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:[cell superview]];

        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

#pragma mark - Index Methods

- (NSInteger)calculateIndex:(NSIndexPath *)indexPath {
    
    NSInteger index = 0;
    
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        NSInteger numberRows = [self.tableView numberOfRowsInSection:i];
        if (indexPath.section > i) {
            index += numberRows;
        } else {
            for (int j = 0; j < numberRows; j++) {
                if (indexPath.section == i && indexPath.row == j) {
                    return index;
                } else {
                    index++;
                }
            }
        }
    }
    
    return index;
}

- (NSIndexPath *)calculateIndexPath:(NSInteger)index {
    
    NSInteger count = 0;
    
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        NSInteger numberRows = [self.tableView numberOfRowsInSection:i];
        if (count + numberRows < i) {
            count += numberRows;
        } else {
            for (int j = 0; j < numberRows; j++) {
                if (index == count) {
                    return [NSIndexPath indexPathForRow:j inSection:i];
                } else {
                    count++;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [titleIndexes count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *letterIndex = [titleIndexes objectAtIndex:section];
    NSInteger numLetters = 0;
    BOOL countHasStarted = NO;
    
    for (int i = 0; i < [self.people count]; i++) {
        NSString *name = [[self.people objectAtIndex:i] objectForKey:@"name"];
        NSString *unaccentedString = [name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        NSString *firstLetter = ([unaccentedString length] > 0) ? [[unaccentedString capitalizedString] substringToIndex:1] : @"";
        
        if ([firstLetter isEqualToString:letterIndex]) {
            numLetters++;
            countHasStarted = YES;
        } else if (countHasStarted) {
            break;
        }
    }
    
    return numLetters;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    ReaderViewCell *cell = (ReaderViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"ReaderViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell = (ReaderViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [self.people objectAtIndex:[self calculateIndex:indexPath]];
    cell.enrollmentID.text = [dictionary objectForKey:@"enrollmentID"];
    cell.name.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = nil;
    
    if ([[dictionary objectForKey:@"present"] integerValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (hightlightedIndexPath != nil && [self calculateIndex:hightlightedIndexPath] == [self calculateIndex:indexPath]) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return titleIndexes;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [titleIndexes indexOfObject:title];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSInteger number = [textField.text integerValue];
    
    for (int i = 0; i < [_people count]; i++) {
        if ([[[_people objectAtIndex:i] objectForKey:@"enrollmentID"] integerValue] == number) {
            NSIndexPath *indexPath = [self calculateIndexPath:i];
            hightlightedIndexPath = indexPath;
            
            // Highlight it
            [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
            
            // Scroll to it
            [self.tableView scrollToRowAtIndexPath:[self calculateIndexPath:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    // Get the current number and confirm it
    [self toggleEntranceForIndexPath:hightlightedIndexPath highligthing:YES];
    
    // Erase the current number
    [_numberInput setText:@"000"];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data object to the companies
        self.people = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.tableView reloadData];
        
    } else if ([apiController.method isEqualToString:@"requestEnrollment"]) {
        
        // Reset our text field
        [self.nameInput setText:@""];
        [self.emailInput setText:@""];
        
        // Reload all our rows
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
        [[NSDictionary dictionaryWithObject:self.people forKey:@"data"] writeToFile:dataPath atomically:YES];
        
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
