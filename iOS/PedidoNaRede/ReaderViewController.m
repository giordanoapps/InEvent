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

@interface ReaderViewController ()

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
    [self.view addGestureRecognizer:tapGesture];
    
    // Text field
    [_numberInput setFrame:CGRectMake(_numberInput.frame.origin.x, _numberInput.frame.origin.y, _numberInput.frame.size.width, _numberInput.frame.size.height * 2.0)];
    [_numberInput setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_numberInput setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [_numberInput.layer setCornerRadius:6.0];
    [_numberInput.layer setMasksToBounds:NO];
    [_numberInput.layer setBorderWidth:1.0];
    [_numberInput.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
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

- (void)confirmEntranceForRow:(NSInteger)row {
    // Update and change the dictionaries inside people
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.people objectAtIndex:row]];
    [dictionary setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"present"];
    [self.people replaceObjectAtIndex:row withObject:dictionary];
    
    // Send it to the server
    [[[APIController alloc] initWithDelegate:self forcing:YES] activityConfirmEntranceForPerson:[[dictionary objectForKey:@"id"] integerValue] atActivity:[[_activityData objectForKey:@"id"] integerValue] withTokenID:[[HumanToken sharedInstance] tokenID]];
    
    // Reload the given row
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    if ([[dictionary objectForKey:@"present"] integerValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
        [self confirmEntranceForRow:indexPath.row];
    }
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    for (int i = 0; i < [_people count]; i++) {
        if ([[[_people objectAtIndex:i] objectForKey:@"id"] isEqualToString:textField.text]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
                [self confirmEntranceForRow:i];
            }
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
    
    // Assign the data object to the companies
    self.people = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
    
    // Reload all table data
    [self.tableView reloadData];
}

@end
