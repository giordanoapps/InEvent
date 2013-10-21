//
//  FrontViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FrontViewController.h"
#import "UtilitiesController.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "ODRefreshControl.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "UIPlaceHolderTextView.h"
#import "CoolBarButtonItem.h"

@interface FrontViewController () {
    ODRefreshControl *refreshControl;
    NSDictionary *eventData;
    BOOL editingMode;
}

@property (nonatomic, strong) NSArray *activities;

@end

@implementation FrontViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Left Button
    if ([[HumanToken sharedInstance] isMemberWorking]) [self loadMenuButton];
    
    // Right Button
    [self loadDismissButton];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.view];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    // Scroll View
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, 842.0f);
	[self.view flashScrollIndicators];

    // Wrapper
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Schedule details
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self allocTapBehind];
    }
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

#pragma mark - Loader Methods

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetSingleEvent:[[EventToken sharedInstance] eventID] WithTokenID:[[HumanToken sharedInstance] tokenID]];
    } else {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetSingleEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (eventData) {
        
        // Cover
        [self.cover setImageWithURL:[UtilitiesController urlWithFile:[eventData objectForKey:@"cover"]]];
        
        // Name
        self.name.text = [[eventData objectForKey:@"name"] stringByDecodingHTMLEntities];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Date begin
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateBegin"] integerValue]];
        NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        self.dateBegin.text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Date end
        date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateEnd"] integerValue]];
        components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        self.dateEnd.text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Location
        self.location.text = [[NSString stringWithFormat:@"%@ %@", [eventData objectForKey:@"address"], [eventData objectForKey:@"city"]] stringByDecodingHTMLEntities];
        
        // Fugleman
        self.fugleman.text = [[eventData objectForKey:@"fugleman"] stringByDecodingHTMLEntities];

        // Fugleman
        self.enrollmentID.text = [NSString stringWithFormat:@"%.4d", [[eventData objectForKey:@"enrollmentID"] integerValue]];
    }
}

#pragma mark - Private Methods

- (void)dismiss {
    if (editingMode) [self endEditing];
    
    // Dismiss the controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadMenuButton {
    // Right Button
    self.leftBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Pencil-_-Edit.png"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(startEditing)];
    self.navigationItem.leftBarButtonItem = self.leftBarButton;
}

- (void)loadDoneButton {
    // Right Button
    self.leftBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Check-2.png"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(endEditing)];
    self.navigationItem.leftBarButtonItem = self.leftBarButton;
}

- (void)loadDismissButton {
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
}

#pragma mark - Editing

- (void)startEditing {
    
    // Set the placeholders
    [self.name setPlaceholder:self.name.text];
    [self.dateBegin setPlaceholder:self.dateBegin.text];
    [self.dateEnd setPlaceholder:self.dateEnd.text];
    [self.location setPlaceholder:self.location.text];
    [self.fugleman setPlaceholder:self.fugleman.text];
    [self.description setPlaceholder:self.description.text];

    // Start editing
    [self.name setEditable:YES];
    [self.description setEditable:YES];
    editingMode = YES;
    
    [self loadDoneButton];
}

- (void)saveEditing:(UIView *)field forName:(NSString *)name {
    
    // Save the fields
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    NSInteger eventID = [[eventData objectForKey:@"id"] integerValue];
    
    // Field will always have a placeholder, so we can cast it as a UITextField
    if (![((UITextField *)field).placeholder isEqualToString:((UITextField *)field).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:name withValue:((UITextField *)field).text atEvent:eventID withTokenID:tokenID];
    }
}

- (void)endEditing {
    
    // Save the fields
    [self saveEditing:self.name forName:@"name"];
    [self saveEditing:self.dateBegin forName:@"dateBegin"];
    [self saveEditing:self.dateEnd forName:@"dateEnd"];
    [self saveEditing:self.location forName:@"location"];
    [self saveEditing:self.fugleman forName:@"fugleman"];
    [self saveEditing:self.description forName:@"description"];
    
    // End editing
    [self.name setEditable:NO];
    [self.description setEditable:NO];
    [self.view endEditing:YES];
    editingMode = NO;
    
    [self loadMenuButton];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (editingMode) {
        return [super textFieldShouldBeginEditing:textField];
    } else {
        return NO;
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    eventData = [[dictionary objectForKey:@"data"] objectAtIndex:0];
    
    // Stop refreshing
    [refreshControl endRefreshing];
    
    // Paint the UI
    [self paint];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
