//
//  FrontViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "InEventAPI.h"
#import "FrontViewController.h"
#import "UtilitiesController.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "UIPlaceHolderTextView.h"
#import "CoolBarButtonItem.h"

@interface FrontViewController () {
    UIRefreshControl *refreshControl;
    NSDictionary *eventData;
    BOOL editingMode;
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSArray *activities;

@end

@implementation FrontViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [[EventToken sharedInstance] name];
        self.tabBarItem.image = [UIImage imageNamed:@"16-Map"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"eventCurrentState" object:nil];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Right Button
    [self loadMenuButton];

    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
    
    // Scroll View
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, 794.0f);
	[self.view flashScrollIndicators];

    // Image
    _cover.layer.masksToBounds = YES;
    _cover.layer.cornerRadius = 2.0f;
    
    // Details
    _details.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Wrapper
    _wrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Location Manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    // Event details
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // KVO
    [_name addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [_description addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // KVO
    [_name removeObserver:self forKeyPath:@"contentSize"];
    [_description removeObserver:self forKeyPath:@"contentSize"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGRect frame;
    CGSize size;
    
    if (object == _name) {
        // View
        size = self.view.contentSize;
        size.height += _name.contentSize.height - _name.frame.size.height;
        self.view.contentSize = size;
        
        // Wrapper
        frame = _wrapper.frame;
        frame.origin.y += _name.contentSize.height - _name.frame.size.height ;
        _wrapper.frame = frame;
        
        // Enrollment
        frame = _enrollment.frame;
        frame.origin.y += _name.contentSize.height - _name.frame.size.height ;
        _enrollment.frame = frame;
        
        // EnrollmentID
        frame = _enrollmentID.frame;
        frame.origin.y += _name.contentSize.height - _name.frame.size.height ;
        _enrollmentID.frame = frame;
        
        // Map
        frame = _map.frame;
        frame.origin.y += _name.contentSize.height - _name.frame.size.height ;
        _map.frame = frame;
        
        // Details
        frame = _details.frame;
        frame.size.height += _name.contentSize.height - _name.frame.size.height ;
        _details.frame = frame;
        
        // Name
        frame = _name.frame;
        frame.size.height = _name.contentSize.height;
        _name.frame = frame;
        
    } else if (object == _description) {

        // View
        size = self.view.contentSize;
        size.height += _description.contentSize.height - _description.frame.size.height;
        self.view.contentSize = size;
        
        // Wrapper
        frame = _wrapper.frame;
        frame.size.height += _description.contentSize.height - _description.frame.size.height ;
        _wrapper.frame = frame;
        
        // Description
        frame = _description.frame;
        frame.size.height = _description.contentSize.height;
        _description.frame = frame;
    
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getSingleEvent:[[EventToken sharedInstance] eventID] WithTokenID:[[HumanToken sharedInstance] tokenID]];
    } else {
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:forcing] getSingleEvent:[[EventToken sharedInstance] eventID]];
    }
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (eventData) {
        
        // Title
        self.title = [[EventToken sharedInstance] name];
        
        // Cover
        __weak typeof(self) weakSelf = self;
        [self.cover setImageWithURL:[UtilitiesController urlWithFile:[eventData objectForKey:@"cover"]] completed:
         ^(UIImage *image, NSError *error, SDImageCacheType cacheType ) {
             
            // We crop the view to the its maximum height and adjust its width proportionally
             CGFloat newWidth = (weakSelf.cover.frame.size.height / image.size.height) * image.size.width;
             
             // Pay attention that we get the size of the view to calculate the width so we don't need to wait the view to autoresize
             [weakSelf.cover setFrame: CGRectMake((weakSelf.view.frame.size.width - newWidth) / 2.0f, weakSelf.cover.frame.origin.y, newWidth, weakSelf.cover.frame.size.height)];
        }];
        
        // Name
        self.name.text = [[eventData objectForKey:@"name"] stringByDecodingHTMLEntities];
        
        // Enrollment ID
        self.enrollmentID.text = [NSString stringWithFormat:@"%.3d", [[eventData objectForKey:@"enrollmentID"] integerValue]];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Date begin
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateBegin"] integerValue]];
        NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        self.dateBegin.text = [NSString stringWithFormat:@"%.2d/%.2d/%.2d %.2d:%.2d", [components day], [components month], [components year] % 100, [components hour], [components minute]];
        
        // Date end
        date = [NSDate dateWithTimeIntervalSince1970:[[eventData objectForKey:@"dateEnd"] integerValue]];
        components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        self.dateEnd.text = [NSString stringWithFormat:@"%.2d/%.2d/%.2d %.2d:%.2d", [components day], [components month], [components year] % 100, [components hour], [components minute]];
        
        // Location
        self.location.text = [[NSString stringWithFormat:@"%@ %@", [eventData objectForKey:@"address"], [eventData objectForKey:@"city"]] stringByDecodingHTMLEntities];
        
        // Map
        [self reloadMap];
        
        // Fugleman
        self.fugleman.text = [[eventData objectForKey:@"fugleman"] stringByDecodingHTMLEntities];
        
        // Description
        self.description.text = [[eventData objectForKey:@"description"] stringByDecodingHTMLEntities];
    }
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet;
    
    if ([[HumanToken sharedInstance] isMemberWorking]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit fields", nil), NSLocalizedString(@"Exit event", nil), nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Exit event", nil), nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Edit fields", nil)]) {
        [self startEditing];
        
    } else if ([title isEqualToString:NSLocalizedString(@"Exit event", nil)]) {
        // Remove the tokenID and enterprise
        [[EventToken sharedInstance] removeEvent];
        
        // Check for it again
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }
}


#pragma mark - Twitter

- (IBAction)sendTweet:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ %@!", NSLocalizedString(@"Attending", nil), [[EventToken sharedInstance] name]]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable your Twitter account, through Settings -> Twitter -> Add Account", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

#pragma mark - Facebook

- (IBAction)postTimeline:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPost setInitialText:[NSString stringWithFormat:@"%@ %@!", NSLocalizedString(@"Attending", nil), [[EventToken sharedInstance] name]]];
        [self presentViewController:facebookPost animated:YES completion:nil];
    } else {
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable your Facebook account, through Settings -> Facebook -> Account", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

#pragma mark - Private Methods

- (void)dismiss {
    if (editingMode) [self endEditing];
    
    // Dismiss the controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [[[InEventEventAPIController alloc] initWithDelegate:self forcing:YES] editField:name withValue:((UITextField *)field).text atEvent:eventID withTokenID:tokenID];
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

#pragma mark - Location

- (void)updateLocation:(CLLocation *)location {
    [_map setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.011, 0.011))];
}

#pragma mark - Map

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // Handle any custom annotations.
    // Try to dequeue an existing pin view first.
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if (pinView) {
        // Add a pin
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

- (void)reloadMap {
    
    // Remove all annotations
    [_map removeAnnotations:_map.annotations];
    
    // Then load the new ones
    CGFloat latitude = [[eventData objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[eventData objectForKey:@"longitude"] floatValue];
    
    if (latitude == 0 && longitude == 0) {
        // Search using Apple API
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = [[eventData objectForKey:@"location"] stringByDecodingHTMLEntities];
        request.region = _map.region;
        
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            
            NSMutableArray *annotations = [NSMutableArray array];
            
            [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = [[eventData objectForKey:@"name"] stringByDecodingHTMLEntities];
                [annotations addObject:annotation];
            }];
            
            [_map addAnnotations:annotations];
        }];
    } else {
        // Place using InEvent API
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        annotation.title = [[eventData objectForKey:@"location"] stringByDecodingHTMLEntities];
        [_map addAnnotation:annotation];
        //        GMSMarker *marker = [[GMSMarker alloc] init];
        //        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        //        marker.title = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
        //        marker.snippet = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
        //        marker.map = _map;
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

#pragma mark - Location Manager Delegate iOS6

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self updateLocation:[locations lastObject]];
    
    [manager stopUpdatingLocation];
}


#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getSingle"]) {
        if ([[dictionary objectForKey:@"data"] count] > 0) {
            // Assign the data object to the event
            eventData = [[dictionary objectForKey:@"data"] objectAtIndex:0];
            
            // Paint the UI
            [self paint];
        }
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
