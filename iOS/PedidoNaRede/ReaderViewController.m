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
#import "ODRefreshControl.h"

@interface ReaderViewController () {
    ODRefreshControl *refreshControl;
    NSIndexPath *hightlightedIndexPath;
    NSIndexPath *panIndexPath;
    CGPoint panStartLocation;
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load people
    [self loadData];
    
    // View
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [tapGesture setDelegate:self];
    [self.view addGestureRecognizer:tapGesture];
    
    // Text field
    [_numberInput setFrame:CGRectMake(_numberInput.frame.origin.x, _numberInput.frame.origin.y, _numberInput.frame.size.width, _numberInput.frame.size.height * 2.0)];
    [_numberInput setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_numberInput setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [_numberInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_numberInput.layer setCornerRadius:6.0];
    [_numberInput.layer setMasksToBounds:NO];
    [_numberInput.layer setBorderWidth:1.0];
    [_numberInput.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    
    // Message Button
    [_numberButton setBackgroundImage:[[UIImage imageNamed:@"greyButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateNormal];
    [_numberButton setBackgroundImage:[[UIImage imageNamed:@"greyButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateHighlighted];
    [_numberButton addTarget:self action:@selector(didTouch) forControlEvents:UIControlEventTouchUpInside];
    // Defining the border radius of the image
    [_numberButton.layer setMasksToBounds:YES];
    [_numberButton.layer setCornerRadius:4.0];
    // Adding a border
    [_numberButton.layer setBorderWidth:0.6];
    [_numberButton.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
    // Table View
    [self.tableView setAllowsSelection:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Window
    [self allocTapBehind];
    
    // Table View
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [panGesture setDelegate:self];
    [self.tableView addGestureRecognizer:panGesture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Window
    [self deallocTapBehind];
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
        NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
        [[[APIController alloc] initWithDelegate:self forcing:YES] activityGetPeopleAtActivity:activityID withTokenID:tokenID];
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

- (void)didTouch {
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
            [[[APIController alloc] initWithDelegate:self forcing:YES] activityConfirmEntranceForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
        }
    } else {
        
        NSInteger memberID = [self confirmAttribute:[NSString stringWithFormat:@"%d", 0] forKey:@"present" atIndexPath:indexPath highligthing:highlight];
        
        if (memberID != 0) {
            // Send it to the server
            [[[APIController alloc] initWithDelegate:self forcing:YES] activityRevokeEntranceForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
        }
    }
}

- (void)togglePaymentForIndexPath:(NSIndexPath *)indexPath {
    NSInteger memberID = [self confirmAttribute:[NSString stringWithFormat:@"%d", 1] forKey:@"paid" atIndexPath:indexPath highligthing:NO];
    
    if (memberID != 0) {
        // Send it to the server
        [[[APIController alloc] initWithDelegate:self forcing:YES] activityConfirmPaymentForPerson:memberID atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

- (NSInteger)confirmAttribute:(NSString *)attribute forKey:(NSString *)key atIndexPath:(NSIndexPath *)indexPath highligthing:(BOOL)highlight {
    
    if (indexPath != nil) {
        // Get the current cell
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Update and change the dictionaries inside people
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.people objectAtIndex:indexPath.row]];
        [dictionary setObject:attribute forKey:key];
        [self.people replaceObjectAtIndex:indexPath.row withObject:dictionary];
        
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

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [self.people objectAtIndex:indexPath.row];
    cell.textLabel.text = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
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
    if (hightlightedIndexPath != nil && [hightlightedIndexPath compare:indexPath] == NSOrderedSame) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
}

#pragma mark - Text Field Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    NSInteger number = [textField.text integerValue];
    
    for (int i = 0; i < [_people count]; i++) {
        if ([[[_people objectAtIndex:i] objectForKey:@"enrollmentID"] integerValue] == number) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            hightlightedIndexPath = indexPath;
            
            // Highlight it
            [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
            
            // Scroll to it
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPeople"]) {
        // Assign the data object to the companies
        self.people = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Reload all table data
        [self.tableView reloadData];
        
        [refreshControl endRefreshing];
    }
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
