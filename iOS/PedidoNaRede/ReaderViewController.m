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
#import "ODRefreshControl.h"

@interface ReaderViewController () {
    ODRefreshControl *refreshControl;
}

@property (nonatomic, strong) NSMutableArray *people;
@property (nonatomic, strong) NSIndexPath *hightlightedIndexPath;

@end

@implementation ReaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Reader", nil);
        self.people = [NSMutableArray array];
        self.hightlightedIndexPath = nil;
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

- (void)didTap {
    // Remove the keyboard
    [_numberInput resignFirstResponder];
}

- (void)didTouch {
    // Get the current number and confirm it
    [self confirmEntranceForIndexPath:self.hightlightedIndexPath];
}

- (void)confirmEntranceForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
            // Update and change the dictionaries inside people
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.people objectAtIndex:indexPath.row]];
            [dictionary setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"present"];
            [self.people replaceObjectAtIndex:indexPath.row withObject:dictionary];
            
            // Send it to the server
            [[[APIController alloc] initWithDelegate:self forcing:YES] activityConfirmEntranceForPerson:[[dictionary objectForKey:@"id"] integerValue] atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
            
            // Remove the current hightlighted cell
            [cell setSelected:NO animated:YES];
            self.hightlightedIndexPath = nil;
            
            // Reload the given row
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Scroll to it
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

#pragma mark - Gesture Recognizer Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view == gestureRecognizer.view) {
        return YES;
    } else {
        return NO;
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
    
    if ([[dictionary objectForKey:@"present"] integerValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hightlightedIndexPath != nil && self.hightlightedIndexPath.row == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self confirmEntranceForIndexPath:indexPath];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    NSInteger number = [textField.text integerValue];
    
    for (int i = 0; i < [_people count]; i++) {
        if ([[[_people objectAtIndex:i] objectForKey:@"id"] integerValue] == number) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            self.hightlightedIndexPath = indexPath;
            
            // Highlight it
            [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
            
            // Scroll to it
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSInteger number = [textField.text integerValue];
    
    for (int i = 0; i < [_people count]; i++) {
        if ([[[_people objectAtIndex:i] objectForKey:@"id"] integerValue] == number) {
            [self confirmEntranceForIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
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

@end
