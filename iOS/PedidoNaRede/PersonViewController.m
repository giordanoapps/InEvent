//
//  PersonViewController.m
//  InEvent
//
//  Created by Pedro Góes on 14/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "PersonViewController.h"
#import "SocialLoginViewController.h"
#import "HumanToken.h"
#import "NSString+HTML.h"
#import "CoolBarButtonItem.h"
#import "UIImageView+WebCache.h"
#import "InEventPersonAPIController.h"

@interface PersonViewController () {
    UIRefreshControl *refreshControl;
    BOOL editingMode;
    CLLocationManager *locationManager;
}

@end

@implementation PersonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Me", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-User"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Right Button
    [self loadMenuButton];
    
    // Details
    _socialWrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
     
    // Wrapper
    _wrapper.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
    _wrapper.layer.cornerRadius = 4.0f;
    
    // Scroll View
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, 550.0f);
	[self.view flashScrollIndicators];
    
    // Photo
    [_photo.layer setMasksToBounds:YES];
    
    // Text fields
    _name.textColor = [ColorThemeController tableViewCellTextColor];
    _role.textColor = [ColorThemeController tableViewCellTextHighlightedColor];
    _company.textColor = [ColorThemeController tableViewCellTextHighlightedColor];
    _telephone.textColor = [ColorThemeController tableViewCellTextColor];
    _email.textColor = [ColorThemeController tableViewCellTextColor];
    _location.textColor = [ColorThemeController tableViewCellTextColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self cleanData];
        [self paint];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self cleanData];
        [self paint];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter Methods

- (void)setPersonData:(NSDictionary *)personData {
    _personData = personData;
    
    [self paint];
}

#pragma mark - Painter Methods

- (void)paint {
    
    if (_personData) {
        
        // Photo
        if ([[_personData objectForKey:@"facebookID"] length] > 1) {
            [self.photo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=%d&height=%d", [_personData objectForKey:@"facebookID"], (int)(self.photo.frame.size.width * [[UIScreen mainScreen] scale]), (int)(self.photo.frame.size.height * [[UIScreen mainScreen] scale])]] placeholderImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:_photo.frame.size.width / 2.0f];
        } else if ([[_personData objectForKey:@"image"] length] > 1) {
            [self.photo setImageWithURL:[NSURL URLWithString:[_personData objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:_photo.frame.size.width / 2.0f];
        } else {
            [self.photo setImage:[UIImage imageNamed:@"128-user"]];
            [_photo.layer setCornerRadius:0.0f];
        }
        
        // Social
        [_fbButton setHidden:([[_personData objectForKey:@"facebookID"] length] > 1) ? NO : YES];
        [_inButton setHidden:([[_personData objectForKey:@"linkedInID"] length] > 1) ? NO : YES];
        [_socialWrapper setHidden:(_fbButton.hidden && _inButton.hidden) ? YES : NO];
        
        // Text fields
        self.name.text = [[_personData objectForKey:@"name"] stringByDecodingHTMLEntities];
        self.role.text = [[_personData objectForKey:@"role"] stringByDecodingHTMLEntities];
        self.company.text = [[_personData objectForKey:@"company"] stringByDecodingHTMLEntities];
        self.telephone.text = [[_personData objectForKey:@"telephone"] stringByDecodingHTMLEntities];
        self.email.text = [[_personData objectForKey:@"email"] stringByDecodingHTMLEntities];
        self.location.text = [[_personData objectForKey:@"city"] stringByDecodingHTMLEntities];
        
        // Map
        [self reloadMap];
    }
}

#pragma mark - Private Methods

- (void)cleanData {
    self.navigationItem.rightBarButtonItem = nil;
    [self.name setText:NSLocalizedString(@"Name", nil)];
    [self.role setText:NSLocalizedString(@"Role", nil)];
    [self.company setText:NSLocalizedString(@"Company", nil)];
    [self.telephone setText:NSLocalizedString(@"Telephone", nil)];
    [self.email setText:NSLocalizedString(@"Email", nil)];
    [self.location setText:NSLocalizedString(@"Location", nil)];
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

#pragma mark - Actions

- (IBAction)loadWebView:(id)sender {
    
    NSURL *url;
    
    if (sender == _fbButton) {
        url = [self assembleFacebookURL];
    } else if (sender == _inButton) {
        url = [self assembleLinkedInURL];
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [viewController.view addSubview:webView];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Mail

- (IBAction)openMail:(id)sender {

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"InEvent Quick Meetup"];
        [mailer setToRecipients:@[[_personData objectForKey:@"email"]]];
        [mailer addAttachmentData:UIImagePNGRepresentation([UIImage imageNamed:@"logo@40.png"]) mimeType:@"image/png" fileName:@"InEventImage"];
        NSString *emailBody = NSLocalizedString(@"Hi, can we meet up very quick?", nil);
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:NULL];
        
    } else {
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please create an email account first", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
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
//        [self logoutButtonWasPressed];
    }
}

#pragma mark - LinkedIn Methods

- (NSURL *)assembleLinkedInURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.linkedin.com/profile/view?id=%@", [_personData objectForKey:@"linkedInID"]]];
}

#pragma mark - Facebook Methods

- (NSURL *)assembleFacebookURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", [_personData objectForKey:@"facebookID"]]];
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
    request.naturalLanguageQuery = [[_personData objectForKey:@"city"] stringByDecodingHTMLEntities];
    request.region = _map.region;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        NSMutableArray *annotations = [NSMutableArray array];
        
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [[_personData objectForKey:@"name"] stringByDecodingHTMLEntities];
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

#pragma mark - Mail Composer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getDetails"]) {
        // Assign the data object to the person
        _personData = dictionary;
        
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
