//
//  FrontViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "FrontViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilitiesController.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "ODRefreshControl.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "NSObject+Field.h"
#import "UIPlaceHolderTextView.h"
#import "CoolBarButtonItem.h"

@interface FrontViewController () {
    ODRefreshControl *refreshControl;
    NSDictionary *eventData;
    BOOL isEditing;
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
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.scrollView];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    // Scroll view
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 1.01)];
    
    // Wrapper
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Schedule details
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self loadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self allocTapBehind];
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
        [_cover setImageWithURL:[UtilitiesController urlWithFile:[eventData objectForKey:@"cover"]]];
        
        // Name
        ((UILabel *)_name).text = [[eventData objectForKey:@"name"] stringByDecodingHTMLEntities];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Date begin
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateBegin"] integerValue]];
        NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        ((UILabel *)_dateBegin).text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Date end
        date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateEnd"] integerValue]];
        components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        ((UILabel *)_dateEnd).text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Location
        ((UILabel *)_location).text = [[NSString stringWithFormat:@"%@ %@", [eventData objectForKey:@"address"], [eventData objectForKey:@"city"]] stringByDecodingHTMLEntities];
        
        // Fugleman
        ((UILabel *)_fugleman).text = [[eventData objectForKey:@"fugleman"] stringByDecodingHTMLEntities];

        // Fugleman
        ((UILabel *)_enrollmentID).text = [NSString stringWithFormat:@"%.4d", [[eventData objectForKey:@"enrollmentID"] integerValue]];
    }
}

#pragma mark - Private Methods

- (void)dismiss {
    if (isEditing) [self endEditing];
    
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
    _name = [self createField:_name withAttributes:@[@"trimPadding"]];
    _dateBegin = [self createField:_dateBegin withAttributes:@[@"trimPadding"]];
    _dateEnd = [self createField:_dateEnd];
    _location = [self createField:_location];
    _fugleman = [self createField:_fugleman];
    
    isEditing = YES;
    
    [self loadDoneButton];
}

- (void)endEditing {
    
    // Save the fields
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    if (![((UIPlaceHolderTextView *)_name).placeholder isEqualToString:((UIPlaceHolderTextView *)_name).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:@"name" withValue:((UIPlaceHolderTextView *)_name).text atEvent:[[eventData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
    
    if (![((UIPlaceHolderTextView *)_dateBegin).placeholder isEqualToString:((UIPlaceHolderTextView *)_dateBegin).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:@"dateBegin" withValue:((UIPlaceHolderTextView *)_dateBegin).text atEvent:[[eventData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
    
    if (![((UIPlaceHolderTextView *)_dateEnd).placeholder isEqualToString:((UIPlaceHolderTextView *)_dateEnd).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:@"dateEnd" withValue:((UIPlaceHolderTextView *)_dateEnd).text atEvent:[[eventData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
    
    if (![((UIPlaceHolderTextView *)_location).placeholder isEqualToString:((UIPlaceHolderTextView *)_location).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:@"location" withValue:((UIPlaceHolderTextView *)_location).text atEvent:[[eventData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
    
    if (![((UIPlaceHolderTextView *)_fugleman).placeholder isEqualToString:((UIPlaceHolderTextView *)_fugleman).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventEditField:@"fugleman" withValue:((UIPlaceHolderTextView *)_fugleman).text atEvent:[[eventData objectForKey:@"id"] integerValue] withTokenID:tokenID];
    }
    
    // Remove them
    _name = [self removeField:_name];
    _dateBegin = [self removeField:_dateBegin];
    _dateEnd = [self removeField:_dateEnd];
    _location = [self removeField:_location];
    _fugleman = [self removeField:_fugleman];
    
    isEditing = NO;
    
    [self loadMenuButton];
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
