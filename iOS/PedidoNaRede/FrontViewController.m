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
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "CoolBarButtonItem.h"

@interface FrontViewController () {
    NSDictionary *eventData;
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
    
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    // Wrapper
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Schedule details
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadData];
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
        _name.text = [[eventData objectForKey:@"name"] stringByDecodingHTMLEntities];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Date begin
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateBegin"] integerValue]];
        NSDateComponents *components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        _dateBegin.text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Date end
        date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateEnd"] integerValue]];
        components = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        _dateEnd.text = [NSString stringWithFormat:@"%.2d/%.2d %.2d:%.2d", [components month], [components day], [components hour], [components minute]];
        
        // Location
        _location.text = [[NSString stringWithFormat:@"%@ %@", [eventData objectForKey:@"address"], [eventData objectForKey:@"city"]] stringByDecodingHTMLEntities];
        
        // Fugleman
        _fugleman.text = [[eventData objectForKey:@"fugleman"] stringByDecodingHTMLEntities];

        // Fugleman
        _enrollmentID.text = [NSString stringWithFormat:@"%.4d", [[eventData objectForKey:@"enrollmentID"] integerValue]];
    }
}

#pragma mark - User Methods

- (void)dismiss {
    
    // Dismiss the controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    eventData = [[dictionary objectForKey:@"data"] objectAtIndex:0];
    
    // Paint the UI
    [self paint];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];

}

@end
