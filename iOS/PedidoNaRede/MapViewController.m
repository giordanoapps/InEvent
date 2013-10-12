//
//  MapViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "NSString+HTML.h"
#import "MKPointExpandedAnnotation.h"
#import "ODRefreshControl.h"
#import "EventToken.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <Parse/Parse.h>

@interface MapViewController () {
    ODRefreshControl *refreshControl;
}

@property (nonatomic, strong) NSArray *companies;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"178-city"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.shouldMoveKeyboardUp = NO;
    self.view.backgroundColor = [ColorThemeController navigationBarBackgroundColor];
    
    // The searchField will only be available on the master map class
    if (_searchField) {
        
        // APIController
        [self loadData];
        
        // Create the view for the search field
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        UIImageView *searchTool = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"64-Magnifying-Glass-2"]];
        [searchTool setFrame:CGRectMake(10.0, 3.0, 24.0, 24.0)];
        [leftView addSubview:searchTool];
        
        // Search field
        _searchField.backgroundColor = [ColorThemeController backgroundColor];
        _searchField.borderStyle = UITextBorderStyleNone;
        _searchField.leftView = leftView;
        _searchField.leftViewMode = UITextFieldViewModeAlways;
        _searchField.placeholder = NSLocalizedString(@"Where?", nil);
        _searchField.textColor = [ColorThemeController textColor];
        _searchField.accessibilityHint = NSLocalizedString(@"Where do you want to go?", nil);
        _searchField.accessibilityTraits = UIAccessibilityTraitSearchField;
        [_searchField.layer setMasksToBounds:YES];
        [_searchField.layer setCornerRadius:6.0];
        [_searchField.layer setBorderWidth:1.0];
        [_searchField.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
        
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [ColorThemeController tableViewCellBorderColor];
        _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
        
        // Refresh Control
        refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    }
    
    if (_mapView) {
        
        _mapView.accessibilityLabel = NSLocalizedString(@"Map", nil);
        _mapView.accessibilityTraits = UIAccessibilityTraitUpdatesFrequently | UIAccessibilityTraitImage;
        
        // Location Manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Methods

- (void)loadData {
//    [[[APIController alloc] initWithDelegate:self forcing:YES] eventGetEvents];
}

#pragma mark - Location

- (void)updateLocation:(CLLocation *)location {
   [_mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.011, 0.011))];
}

#pragma mark - Map Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // Handle any custom annotations.
    // Try to dequeue an existing pin view first.
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if (pinView) {
        pinView.annotation = annotation;
        
    } else {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation"];
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.draggable = NO;
        pinView.enabled = YES;
        pinView.annotation = annotation;
        
        // Add a detail disclosure button to the callout
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    }

    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MKPointExpandedAnnotation class]]) {
        [self didSelectCompanyAtRow:[(MKPointExpandedAnnotation *)view.annotation row]];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self didSelectCompanyAtRow:[(MKPointExpandedAnnotation *)view.annotation row]];
}

#pragma mark - User Methods

- (void)didSelectCompanyAtRow:(NSInteger)row {
    
    // We set some essential data
    EventToken *company = [EventToken sharedInstance];
    NSDictionary *dictionary = [self.companies objectAtIndex:row];
    
    // Properties
    NSInteger eventID = [[dictionary objectForKey:@"id"] integerValue];
    NSString *name = [[dictionary objectForKey:@"tradeName"] stringByDecodingHTMLEntities];
    NSInteger carteID = [[dictionary objectForKey:@"mainCarte"] integerValue];
    
    [company setEventID:eventID];
    [company setName:name];
    
    // Notify our tracker about the new event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"event" action:@"getEvent" label:@"iOS" value:[NSNumber numberWithInteger:eventID]] build]];
    
    // Notify our tracker about the new event
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"event/%d", carteID] forKey:@"channels"];
    [currentInstallation saveEventually];

    // Notify about the new company to our views
    [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"menu"}];
}

- (void)reloadMap {
    // First we need to get the map region (size)
//    MKCoordinateRegion region = _mapView.region;

    // Remove all annotations
    [_mapView removeAnnotations:_mapView.annotations];
    
    // Then load the new ones
    for (int i = 0; i < [_companies count]; i++) {
        
        NSDictionary *dictionary = [_companies objectAtIndex:i];
        
        CGFloat latitude = [[dictionary objectForKey:@"latitude"] floatValue];
        CGFloat longitude = [[dictionary objectForKey:@"longitude"] floatValue];
        
//        CGFloat left = region.center.longitude - region.span.longitudeDelta;
//        CGFloat right = region.center.longitude + region.span.longitudeDelta;
//        CGFloat top = region.center.latitude - region.span.latitudeDelta;
//        CGFloat bottom = region.center.latitude + region.span.latitudeDelta;
//        
        // Now we check if the enterprise is inside the map
//        if (left < longitude && longitude < right && top <  latitude && latitude > bottom) {
        
        MKPointExpandedAnnotation *annotation = [[MKPointExpandedAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        annotation.title = [[dictionary objectForKey:@"tradeName"] stringByDecodingHTMLEntities];
        annotation.row = i;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [_mapView addAnnotation:annotation];
        } else {
            // We get the detailController and we push the _mapView controller
            [_mapView addAnnotation:annotation];
        }
    }
}

- (void)removeTable {
    
    // Hide the table
    [UIView animateWithDuration:0.5 animations:^{
        [self.tableView setAlpha:0.0];
    }];
    
    // Empty the search string
    _searchField.text = @"";
    [_searchField resignFirstResponder];
    
    // Right Button
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Load
//    [[[APIController alloc] initWithDelegate:self] companyGetEvents];
    
    // Show the table
    [UIView animateWithDuration:0.5 animations:^{
        [self.tableView setAlpha:1.0];
    }];
    
    // Right Button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeTable)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // Load all the data if the search is empty
    if ([textField.text isEqualToString:@""]) {
//        [[[APIController alloc] initWithDelegate:self] companyGetEvents];
    } else {
        // Load information from the server
//        [[[APIController alloc] initWithDelegate:self forcing:YES] companyGetEventsForQuery:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
//        [[[APIController alloc] initWithDelegate:self] companyGetEvents];
    
    return YES;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [_companies count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CustomCellIdentifier = @"CustomCellIdentifier";
    UITableViewCell * cell = [aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [_companies objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[dictionary objectForKey:@"tradeName"] stringByDecodingHTMLEntities];
    cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@ - %@ - %@", [dictionary objectForKey:@"address"], [dictionary objectForKey:@"city"],[dictionary objectForKey:@"state"]] stringByDecodingHTMLEntities];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self didSelectCompanyAtRow:indexPath.row];
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    self.companies = [dictionary objectForKey:@"data"];
    // Reload the map
    [self reloadMap];
    // Reload all table data
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}

#pragma mark - Location Manager Delegate iOS5

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self updateLocation:newLocation];
    
    [manager stopUpdatingLocation];
}

#pragma mark - Location Manager Delegate iOS6

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self updateLocation:[locations lastObject]];
    
    [manager stopUpdatingLocation];
}

@end
