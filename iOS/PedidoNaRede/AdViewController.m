//
//  AdViewController.m
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "AdViewController.h"
#import "EventToken.h"
#import "UtilitiesController.h"
#import "UIImageView+WebCache.h"

@interface AdViewController () {
    NSArray *adData;
}

@end

@implementation AdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Paint the UI
    [self paint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters

- (void)setDelegate:(id<AdViewControllerDelegate>)delegate {
    _delegate = delegate;
    
    [self loadData];
}

#pragma mark - Loader Methods

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    [[[APIController alloc] initWithDelegate:self forcing:forcing] adGetAdsAtEvent:[[EventToken sharedInstance] eventID]];
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (adData && [adData count] > 0) {
        // Ad piece
        NSDictionary *singleAd = [adData objectAtIndex:(arc4random() % [adData count])];
        [_piece setImageWithURL:[UtilitiesController urlWithFile:[singleAd objectForKey:@"image"]]];
        
        // Mark the ad as seen
        [[[APIController alloc] initWithDelegate:self forcing:YES] adSeenAd:[[singleAd objectForKey:@"id"] integerValue]];
    }
}

#pragma mark - Private Methods

- (void)dismiss {
    // Dismiss the controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getAds"]) {
        
        // Assign the data object to the companies
        adData = [dictionary objectForKey:@"data"];
        
        // Schedule the timer
        [NSTimer scheduledTimerWithTimeInterval:2.2f target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
        
        if ([self.delegate respondsToSelector:@selector(adController:shouldLoadController:)]) {
            if ([adData count] > 0) {
                [self.delegate adController:self shouldLoadController:YES];
            } else {
                [self.delegate adController:self shouldLoadController:NO];
            }
        }
    }
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {

    if ([self.delegate respondsToSelector:@selector(adController:shouldLoadController:)]) {
        [self.delegate adController:self shouldLoadController:NO];
    }
    
    [super apiController:apiController didFailWithError:error];
}

@end
