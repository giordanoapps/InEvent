//
//  HumanViewController.m
//  InEvent
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "HumanViewController.h"
#import "SocialLoginViewController.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "CoolBarButtonItem.h"
#import "UIImageView+WebCache.h"
#import "InEventAPI.h"

@interface HumanViewController () {
    UIRefreshControl *refreshControl;
    NSDictionary *personData;
    BOOL editingMode;
    CLLocationManager *locationManager;
}

@end

@implementation HumanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Me", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-User"];
        
        // Register for some updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"personNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Right Button
    [self loadMenuButton];
    
    // Wrapper
    _wrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
    
    // Scroll View
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, 550.0f);
	[self.view flashScrollIndicators];
    
    // Photo
    [_photo.layer setMasksToBounds:YES];
    
    // Text fields
    _name.textColor = [ColorThemeController tableViewCellTextColor];
    _role.textColor = [ColorThemeController tableViewCellTextColor];
    _company.textColor = [ColorThemeController tableViewCellTextColor];
    _telephone.textColor = [ColorThemeController tableViewCellTextColor];
    _email.textColor = [ColorThemeController tableViewCellTextColor];
    _location.textColor = [ColorThemeController tableViewCellTextColor];
    
    // Person details
    [self checkSession];
    
    // Restart Facebook connection
    [self connectWithFacebook];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Session
    [self checkSession];
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
        [[[InEventPersonAPIController alloc] initWithDelegate:self forcing:forcing] getDetailsWithTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (personData) {
        
        // Photo
        if ([[personData objectForKey:@"facebookID"] integerValue] != 0) {
            [self.photo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=%d&height=%d", [personData objectForKey:@"facebookID"], (int)(self.photo.frame.size.width * [[UIScreen mainScreen] scale]), (int)(self.photo.frame.size.height * [[UIScreen mainScreen] scale])]] placeholderImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:_photo.frame.size.width / 2.0f];
        } else if (![[personData objectForKey:@"image"] isEqualToString:@""]) {
            [self.photo setImageWithURL:[NSURL URLWithString:[personData objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:_photo.frame.size.width / 2.0f];
        } else {
            [self.photo setImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:0.0f];
        }
        
        // Text fields
        self.name.text = [[personData objectForKey:@"name"] stringByDecodingHTMLEntities];
        self.role.text = [[personData objectForKey:@"role"] stringByDecodingHTMLEntities];
        self.company.text = [[personData objectForKey:@"company"] stringByDecodingHTMLEntities];
        self.telephone.text = [[personData objectForKey:@"telephone"] stringByDecodingHTMLEntities];
        self.email.text = [[personData objectForKey:@"email"] stringByDecodingHTMLEntities];
        self.location.text = [[personData objectForKey:@"city"] stringByDecodingHTMLEntities];
        self.cpf.text = [[personData objectForKey:@"cpf"] stringByDecodingHTMLEntities];
        self.rg.text = [[personData objectForKey:@"rg"] stringByDecodingHTMLEntities];
        
        // Map
        [self reloadMap];
    }
}


#pragma mark - Public Methods

- (void)checkSession {
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [self loadData];
        
    } else {
        // Alloc login controller
        SocialLoginViewController *lvc = [[SocialLoginViewController alloc] initWithNibName:@"SocialLoginViewController" bundle:nil];
        [lvc setDelegate:self];
        UINavigationController *nlvc = [[UINavigationController alloc] initWithRootViewController:lvc];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nlvc.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            nlvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            nlvc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nlvc animated:YES completion:nil];
    }
}

#pragma mark - Private Methods

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
    [self.role setPlaceholder:self.role.text];
    [self.company setPlaceholder:self.company.text];
    [self.telephone setPlaceholder:self.telephone.text];
    [self.email setPlaceholder:self.email.text];
    [self.location setPlaceholder:self.location.text];
    [self.cpf setPlaceholder:self.cpf.text];
    [self.rg setPlaceholder:self.rg.text];
    
    // Start editing
    editingMode = YES;
    
    [self loadDoneButton];
}

- (void)saveEditing:(UIView *)field forName:(NSString *)name {
    
    // Save the fields
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    // Field will always have a placeholder, so we can cast it as a UITextField
    if (![((UITextField *)field).placeholder isEqualToString:((UITextField *)field).text]) {
        [[[InEventPersonAPIController alloc] initWithDelegate:self forcing:YES] editField:name withValue:((UITextField *)field).text withTokenID:tokenID];
    }
}

- (void)endEditing {
    
    // Save the fields
    [self saveEditing:self.name forName:@"name"];
    [self saveEditing:self.role forName:@"role"];
    [self saveEditing:self.company forName:@"company"];
    [self saveEditing:self.telephone forName:@"telephone"];
    [self saveEditing:self.email forName:@"email"];
    [self saveEditing:self.location forName:@"city"];
    [self saveEditing:self.cpf forName:@"cpf"];
    [self saveEditing:self.rg forName:@"rg"];
    
    // End editing
    [self.view endEditing:YES];
    editingMode = NO;
    
    [self loadMenuButton];
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit fields", nil), NSLocalizedString(@"Logout", nil), nil];

        [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
    }
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Edit fields", nil)]) {
        [self startEditing];
    } else if ([title isEqualToString:NSLocalizedString(@"Logout", nil)]) {
        [self logoutButtonWasPressed];
    }
}

#pragma mark - Facebook Methods

- (void)logoutButtonWasPressed {
    
    // Remove Facebook Login
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    // Remove InEvent Login
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[HumanToken sharedInstance] removeMember];
    }
    
    // Update the current state of the schedule controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleCurrentState" object:nil userInfo:nil];
    
    // Load the login form
    [self checkSession];
}

- (void)connectWithFacebook {
    if (!FBSession.activeSession.isOpen) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {}];
        
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:NO
                                         completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {}];
    }
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
    
    // Search using Apple API
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = [[personData objectForKey:@"city"] stringByDecodingHTMLEntities];
    request.region = _map.region;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        NSMutableArray *annotations = [NSMutableArray array];
        
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [[personData objectForKey:@"name"] stringByDecodingHTMLEntities];
            [annotations addObject:annotation];
        }];
        
        [_map addAnnotations:annotations];
    }];
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

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getDetails"]) {
        // Assign the data object to the person
        personData = dictionary;
        
        // Assign the working events
        [[HumanToken sharedInstance] setWorkingEvents:[dictionary objectForKey:@"events"]];
        
        // Pain the UI
        [self paint];
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
