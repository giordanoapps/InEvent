//
//  ScheduleViewController.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "StreamViewController.h"
#import "StreamViewCell.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "GAI.h"
#import "CoolBarButtonItem.h"
#import "InEventAPI.h"

@interface StreamViewController () {
    UIRefreshControl *refreshControl;
    NSArray *posts;
    NSCache *imagesCache;
}

@end

@implementation StreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Photos", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"16-Image-2"];
        
        // Alloc variables
        imagesCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Delegate
    self.navigationController.delegate = self;
    
    // Navigation Bar
    [self loadPhotoButton];
    
    // Hash View
    _hashView.textColor = [ColorThemeController tableViewCellTextHighlightedColor];
    
    // Text Field
    [_searchField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [_searchField setFrame:CGRectMake(_searchField.frame.origin.x, _searchField.frame.origin.y, _searchField.frame.size.width, _searchField.frame.size.height * 1.5f)];
    _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _hashView.frame.size.width * 1.8f, _searchField.frame.size.height)];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    [_searchField setText:[[EventToken sharedInstance] nick]];
    
    // Table View
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loader

- (void)loadData {
    [self forceDataReload:NO];
}

- (void)reloadData {
    [self forceDataReload:YES];
}

- (void)forceDataReload:(BOOL)forcing {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        [[[InEventPhotoAPIController alloc] initWithDelegate:self forcing:forcing] getPhotosAtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
    }
}
#pragma mark - Text Field Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _searchField) {
        [self reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Facebook Methods

- (void)sendRequests {
    
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error) {
            // error contains details about why the request failed
            NSLog(@"%@", error.localizedDescription);
        } else {
            // Assign all the results
            posts = [(NSDictionary *)result objectForKey:@"data"];
            
            // Reload the table
            [self.tableView reloadData];
            
            // Stop refreshing
            [refreshControl endRefreshing];
        }
    };

    // Load Facebook hashtags
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/search?q=%@&type=post", _searchField.text] parameters:nil HTTPMethod:@"GET" completionHandler:handler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - Bar Methods

- (void)loadPhotoButton {
    // Right Button
    self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"32-Image"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
    self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Send photo", nil);
    self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)loadDoneButton {
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removePersonView)];
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    // Restart Facebook connection
    [self connectWithFacebook];
    
    UIActionSheet *actionSheet;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // Both
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Pick from camera roll", nil), NSLocalizedString(@"Take picture", nil), nil];

    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // Camera
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take picture", nil), nil];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // Library
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Pick from camera roll", nil), nil];
    }
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Pick from camera roll", nil)]) {
        [viewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if ([title isEqualToString:NSLocalizedString(@"Take picture", nil)]) {
        [viewController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    [viewController setDelegate:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else {
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 
//    NSDictionary *dictionary = [[posts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadWithURL:[UtilitiesController urlWithFile:[dictionary objectForKey:@"image"]] options:0 progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//
//        if (image != nil) {
//            return image.size.height;
//        }
//    }];

    if ([imagesCache objectForKey:indexPath] != NULL) {
        CGSize size = ((UIImage *)[imagesCache objectForKey:indexPath]).size;
        return (self.view.frame.size.width / size.width) * size.height;
    } else {
        return 0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    StreamViewCell *cell = (StreamViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"StreamViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell = (StreamViewCell *)[aTableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [posts objectAtIndex:indexPath.row];
    
    [cell.picture setImageWithURL:[NSURL URLWithString:[[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"_s." withString:@"_n."]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        // Save the image
        [imagesCache setObject:image forKey:indexPath];
        
        // Reload it
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    return cell;
}

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    ScheduleItemViewController *sivc;
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        sivc = [[ScheduleItemViewController alloc] initWithNibName:@"ScheduleItemViewController" bundle:nil];
//        [sivc setMoveKeyboardRatio:0.0f];
//    } else {
//        // Find the sibling navigation controller first child and send the appropriate data
//        sivc = (ScheduleItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
//        [sivc setMoveKeyboardRatio:0.5f];
//    }
//    
//    NSDictionary *dictionary = [[posts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    [sivc setTitle:[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities]];
//    [sivc setActivityData:dictionary];
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController pushViewController:sivc animated:YES];
//        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Reload all table data
    [self.tableView reloadData];
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
        composeViewController.title = @"Facebook";
        composeViewController.text = [NSString stringWithFormat:@"#InEvent #%@", [[EventToken sharedInstance] nick]];
        composeViewController.hasAttachment = YES;
        composeViewController.attachmentImage = image;
        composeViewController.delegate = self;
        [composeViewController presentFromRootViewController];
    }];
}

#pragma mark - Compose View Controller Delegate

- (void)composeViewController:(REComposeViewController *)composeViewController didFinishWithResult:(REComposeResult)result {
    
    // Dismiss controller
    [composeViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Send the request if necessary
    if (result == REComposeResultPosted) {
    
        // Create the request
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:composeViewController.text forKey:@"message"];
        [params setObject:composeViewController.attachmentImage forKey:@"source"];
        NSDictionary *privacy = [NSDictionary dictionaryWithObjectsAndKeys:@"EVERYONE", @"value", nil];
        NSData *dataOptions = [NSJSONSerialization dataWithJSONObject:privacy options:0 error:nil];
        [params setObject:[[NSString alloc] initWithData:dataOptions encoding:NSUTF8StringEncoding] forKey:@"privacy"];
        
        FBRequestHandler postHandler = ^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                
                FBRequestHandler detailsHandler = ^(FBRequestConnection *connection, id result, NSError *error) {
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    if (!error) {
                        [[[InEventPhotoAPIController alloc] initWithDelegate:self forcing:YES] postPhoto:[(NSDictionary *)result objectForKey:@"source"] AtEvent:[[EventToken sharedInstance] eventID] withTokenID:[[HumanToken sharedInstance] tokenID]];
                    } else {
                        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Your photo wasn't posted publicly!", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
                        [alertView show];
                    }
    
                };
                
                // Get details about the facebook photo
                [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@", [(NSDictionary *)result objectForKey:@"id"]] completionHandler:detailsHandler];

            } else {
                AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Your photo couldn't be posted to Facebook!", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok", nil)];
                [alertView show];
            }
        };
        
        // Post Facebook photo
        [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST" completionHandler:postHandler];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(InEventAPIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getPhotos"]) {
        // Assign the data object to the groups
        posts = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];

        // Reload all table data
        [self.tableView reloadData];
        
    } else if ([apiController.method isEqualToString:@"post"]) {
        
        // Reload all table data
        [self.tableView reloadData];
    }
    
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
