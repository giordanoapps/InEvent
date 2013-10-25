//
//  ScheduleItemViewController.m
//  InEvent
//
//  Created by Pedro Góes on 14/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Social/Social.h>
#import "ScheduleItemViewController.h"
#import "ReaderViewController.h"
#import "QuestionViewController.h"
#import "FeedbackViewController.h"
#import "MaterialViewController.h"
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "APIController.h"
#import "CoolBarButtonItem.h"
#import "NSString+HTML.h"
#import "NSObject+Triangle.h"
#import "UIPlaceHolderTextView.h"

@interface ScheduleItemViewController () {
    BOOL editingMode;
    CLLocationManager *locationManager;
}

@end

@implementation ScheduleItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanData) name:@"scheduleCurrentState" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Wrapper
    [_wrapper.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [_wrapper.layer setBorderWidth:0.4f];
    [_wrapper.layer setCornerRadius:4.0f];
    [_wrapper.layer setMasksToBounds:YES];
    
    // Title
//    [((UIButton *)_name).titleLabel setNumberOfLines:2];
    [_name setTextColor:[ColorThemeController tableViewCellTextColor]];
    
    // Description
//    [((UIButton *)_description).titleLabel setNumberOfLines:0];
    [_description setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    
    // Line
    [_line setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    [self createBottomIdentation];
    
    // Map
    [_map setShowsUserLocation:YES];
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
//    _map = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//    _map.myLocationEnabled = YES;
//    _map.settings.myLocationButton = YES;
    
    // Location Manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self cleanData];
        [self loadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self cleanData];
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Upper triangle
    [self defineStateForApproved:[[_activityData objectForKey:@"approved"] integerValue] withView:_wrapper];
}

#pragma mark - Setter Methods

- (void)setActivityData:(NSDictionary *)activityData {
    _activityData = activityData;
    
    [self loadData];
}

#pragma mark - Private Methods

- (void)loadData {
    
    if (_activityData) {

        // Actions
        if ([[HumanToken sharedInstance] isMemberAuthenticated]) [self loadMenuButton];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_activityData objectForKey:@"dateBegin"] integerValue]];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        
        [self defineStateForApproved:[[_activityData objectForKey:@"approved"] integerValue] withView:_wrapper];
        
        [_hour setText:[NSString stringWithFormat:@"%.2d", [components hour]]];
        [_minute setText:[NSString stringWithFormat:@"%.2d", [components minute]]];
        [_name setText:[[_activityData objectForKey:@"name"] stringByDecodingHTMLEntities]];
        [_description setText:[[_activityData objectForKey:@"description"] stringByDecodingHTMLEntities]];
        
        if ([[HumanToken sharedInstance] isMemberWorking]) {
            if ([[_activityData objectForKey:@"approved"] integerValue] == ScheduleStateApproved) {
                _quickFeedback.hidden = NO;
                _quickQuestion.hidden = NO;
                _quickPeople.hidden = NO;
                
            } else {
                _quickFeedback.hidden = YES;
                _quickQuestion.hidden = NO;
                _quickPeople.hidden = NO;
            }
        } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
            if ([[_activityData objectForKey:@"approved"] integerValue] == ScheduleStateApproved) {
                _quickFeedback.hidden = NO;
                _quickQuestion.hidden = NO;
                _quickPeople.hidden = YES;
            } else {
                _quickFeedback.hidden = YES;
                _quickQuestion.hidden = NO;
                _quickPeople.hidden = YES;
            }
        } else {
            _quickFeedback.hidden = YES;
            _quickQuestion.hidden = YES;
            _quickPeople.hidden = YES;
        }
        
        [self reloadMap];
    }
}

- (void)cleanData {
    self.navigationItem.rightBarButtonItem = nil;
    [self defineStateForApproved:ScheduleStateUnknown withView:_wrapper];
    [_hour setText:@"00"];
    [_minute setText:@"00"];
    [_name setText:NSLocalizedString(@"Activity", nil)];
    [_description setText:@""];
}

- (void)loadMenuButton {
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
    self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)loadDoneButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing)];
}

#pragma mark - Twitter

- (IBAction)sendTweet:(id)sender {

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ %@!", NSLocalizedString(@"Attending", nil), [[EventToken sharedInstance] name]]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

#pragma mark - Facebook

- (IBAction)postTimeline:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPost setInitialText:[NSString stringWithFormat:@"%@ %@!", NSLocalizedString(@"Attending", nil), [[EventToken sharedInstance] name]]];
        [self presentViewController:facebookPost animated:YES completion:nil];
    }
}

#pragma mark - Editing

- (void)startEditing {
    
    // Set the placeholders
    [_hour setPlaceholder:_hour.text];
    [_minute setPlaceholder:_minute.text];
    [_name setPlaceholder:_name.text];
    [_description setPlaceholder:_description.text];
    
    // Start editing
    [_description setEditable:YES];
    editingMode = YES;
    
    [self loadDoneButton];
}

- (void)saveEditing:(UIView *)field forName:(NSString *)name {
    
    // Save the fields
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
    
    // Field will always have a placeholder, so we can cast it as a UITextField
    if (![((UITextField *)field).placeholder isEqualToString:((UITextField *)field).text]) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] activityEditField:name withValue:((UITextField *)field).text atActivity:activityID withTokenID:tokenID];
    }
    
    // Change text view editable mode
    if ([field isKindOfClass:[UIPlaceHolderTextView class]]) {
        [((UIPlaceHolderTextView *)field) setEditable:NO];
    }
}

- (void)endEditing {
    
    // Save the fields
    [self saveEditing:_hour forName:@"hourBegin"];
    [self saveEditing:_minute forName:@"minuteBegin"];
    [self saveEditing:_name forName:@"name"];
    [self saveEditing:_description forName:@"description"];
    
    // End editing
    [self.description setEditable:NO];
    [self.view endEditing:YES];
    editingMode = NO;
    
    [self loadMenuButton];
}

#pragma mark - Location

- (void)updateLocation:(CLLocation *)location {
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];
//    [_map setCamera:camera];
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
//    [_map clear];
    
    // Then load the new ones
    CGFloat latitude = [[_activityData objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[_activityData objectForKey:@"longitude"] floatValue];
    
    if (latitude == 0 && longitude == 0) {
        // Search using Apple API
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
        request.region = _map.region;
        
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            
            NSMutableArray *annotations = [NSMutableArray array];
            
            [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = [[_activityData objectForKey:@"name"] stringByDecodingHTMLEntities];
                [annotations addObject:annotation];
            }];
            
            [_map addAnnotations:annotations];
        }];
    } else {
        // Place using InEvent API
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        annotation.title = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
        [_map addAnnotation:annotation];
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
//        marker.title = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
//        marker.snippet = [[_activityData objectForKey:@"location"] stringByDecodingHTMLEntities];
//        marker.map = _map;
    }
}

#pragma mark - Draw Methods

- (void)createBottomIdentation {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, _line.frame.size.width * 0.12, _line.frame.origin.y + 1);
    CGPathAddLineToPoint(path, NULL, _line.frame.size.width * 0.14, _line.frame.origin.y * 0.92);
    CGPathAddLineToPoint(path, NULL, _line.frame.size.width * 0.16, _line.frame.origin.y + 1);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[ColorThemeController tableViewCellBackgroundColor] CGColor]];
    [shapeLayer setStrokeColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [shapeLayer setLineWidth:1.0f];
    [_wrapper.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
}

#pragma mark - Gesture Recognizer Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet;
    
    if ([[HumanToken sharedInstance] isMemberWorking]) {
        if ([[_activityData objectForKey:@"approved"] integerValue] == ScheduleStateApproved) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit fields", nil), NSLocalizedString(@"See people", nil), NSLocalizedString(@"See questions", nil), NSLocalizedString(@"Send feedback", nil), nil];
            
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit fields", nil), NSLocalizedString(@"See people", nil), NSLocalizedString(@"See questions", nil), nil];
        }
    } else if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        if ([[_activityData objectForKey:@"approved"] integerValue] == ScheduleStateApproved) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"See questions", nil), NSLocalizedString(@"Send feedback", nil), nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"See questions", nil), nil];
        }
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:NSLocalizedString(@"Edit fields", nil)]) {
        [self startEditing];
        
    } else if ([title isEqualToString:NSLocalizedString(@"See people", nil)]) {
        // Load our reader
        [self loadReaderController];
        
    } else if ([title isEqualToString:NSLocalizedString(@"See questions", nil)]) {
        // Load questions
        [self loadQuestionController];

    } else if ([title isEqualToString:NSLocalizedString(@"Send feedback", nil)]) {
        // Load feedback
        [self loadFeedbackController];

    } else if ([title isEqualToString:NSLocalizedString(@"Exit event", nil)]) {
        // Remove the tokenID and enterprise
        [[EventToken sharedInstance] removeEvent];
        
        // Check for it again
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }
}

#pragma mark - Quick Controllers

- (IBAction)loadReaderController {
    ReaderViewController *rvc = [[ReaderViewController alloc] initWithNibName:@"ReaderViewController" bundle:nil];
    
    [rvc setActivityData:_activityData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:rvc animated:YES];
    } else {
        rvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        rvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:rvc animated:YES completion:nil];
    }
}

- (IBAction)loadQuestionController {
    QuestionViewController *qvc = [[QuestionViewController alloc] initWithNibName:@"QuestionViewController" bundle:nil];
    
    [qvc setActivityData:_activityData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:qvc animated:YES];
    } else {
        qvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        qvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:qvc animated:YES completion:nil];
    }
}

- (IBAction)loadFeedbackController {
    FeedbackViewController *fvc = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    UINavigationController *nfvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    
    [fvc setFeedbackType:FeedbackTypeActivity withReference:[[_activityData objectForKey:@"id"] integerValue]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nfvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nfvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        nfvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nfvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nfvc animated:YES completion:nil];
}

- (IBAction)loadMaterialController {
    MaterialViewController *mvc = [[MaterialViewController alloc] initWithNibName:@"MaterialViewController" bundle:nil];
    UINavigationController *nmvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nmvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nmvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        nmvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        nmvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nmvc animated:YES completion:nil];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (editingMode) {
        return [super textFieldShouldBeginEditing:textField];
    } else {
        return NO;
    }
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

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"edit"]) {
            
    }
}

@end
