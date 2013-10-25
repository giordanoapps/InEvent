//
//  QuestionViewController.m
//  InEvent
//
//  Created by Pedro Góes on 14/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "QuestionViewController.h"
#import "ReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "APIController.h"
#import "CoolBarButtonItem.h"
#import "NSString+HTML.h"
#import "NSObject+Triangle.h"

@interface QuestionViewController () {
    UIRefreshControl *refreshControl;
    NSString *dataPath;
}


@property (strong, nonatomic) NSMutableArray *questionData;

@end

@implementation QuestionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.questionData = [NSMutableArray array];
        
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanData) name:@"scheduleCurrentState" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // View
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [tapGesture setDelegate:self];
    [self.view addGestureRecognizer:tapGesture];
    
    // Table
    _tableView.allowsSelection = NO;
    
    // Wrapper
    [_wrapper.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [_wrapper.layer setBorderWidth:0.4f];
    [_wrapper.layer setCornerRadius:4.0f];
    [_wrapper.layer setMasksToBounds:YES];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

    // Question Wrapper
    [_questionWrapper setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];

    // Create the view for the search field
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
    UIImageView *searchTool = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"64-Speech-Bubbles"]];
    [searchTool setFrame:CGRectMake(10.0, 3.0, 24.0, 24.0)];
    [leftView addSubview:searchTool];

    // Text field
    [_questionInput setPlaceholder:NSLocalizedString(@"What's the question?", nil)];
    [_questionInput setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_questionInput setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [_questionInput setLeftView:leftView];
    [_questionInput setLeftViewMode:UITextFieldViewModeAlways];
    [_questionInput.layer setCornerRadius:0.0];
    [_questionInput.layer setMasksToBounds:NO];
    [_questionInput.layer setBorderWidth:0.0];
    [_questionInput.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];

    // Message Button
    [_questionButton setTitle:NSLocalizedString(@"Send", @"Send message from chat") forState:UIControlStateNormal];
    [_questionButton setTitleColor:[ColorThemeController textColor] forState:UIControlStateNormal];
    [_questionButton setTitleColor:[ColorThemeController textColor] forState:UIControlStateHighlighted];
    [_questionButton setBackgroundImage:[[UIImage imageNamed:@"greyButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateNormal];
    [_questionButton setBackgroundImage:[[UIImage imageNamed:@"greyButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateHighlighted];
    [_questionButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [_questionButton.layer setMasksToBounds:YES];
    [_questionButton.layer setCornerRadius:4.0];
    [_questionButton.layer setBorderWidth:0.6];
    [_questionButton.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
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
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self allocTapBehind];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self cleanData];
        [self loadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self deallocTapBehind];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter Methods

- (void)setActivityData:(NSDictionary *)activityData {
    _activityData = activityData;
    
    [self loadData];
    [self loadQuestions];
}

#pragma mark - Private Methods

- (void)loadData {
    
    if (_activityData && [[HumanToken sharedInstance] isMemberAuthenticated]) {
        _questionWrapper.hidden = NO;
    }
}

- (void)cleanData {
    _questionWrapper.hidden = YES;
}

- (void)loadQuestions {
    NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    [[[APIController alloc] initWithDelegate:self forcing:YES] activityGetQuestionsAtActivity:activityID withTokenID:tokenID];
}

- (void)didTap {
    // Remove the keyboard
    [_questionInput resignFirstResponder];
}

- (void)sendMessage {
    
    // Check if input is not empty
    if (![[_questionInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        // Send the message to our servers
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
        [[[APIController alloc] initWithDelegate:self forcing:YES] activitySendQuestion:_questionInput.text toActivity:activityID withTokenID:tokenID];
        
        // Load these questions
        [self loadQuestions];
        
        [_questionInput setText:@""];
    }
}

#pragma mark - Gesture Recognizer Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view != _questionButton) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet;
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"See people", nil), NSLocalizedString(@"Exit event", nil), nil];
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"See people", nil)]) {
        // Load our reader
        ReaderViewController *rvc = [[ReaderViewController alloc] initWithNibName:@"ReaderViewController" bundle:nil];
        
        [rvc setActivityData:_activityData];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:rvc animated:YES];
        } else {
            rvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            rvc.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:rvc animated:YES completion:nil];
        }

    } else if ([title isEqualToString:NSLocalizedString(@"Exit event", nil)]) {
        // Remove the tokenID and enterprise
        [[EventToken sharedInstance] removeEvent];
        
        // Check for it again
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.questionData count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier];
    }
    
    NSDictionary *dictionary = [self.questionData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[dictionary objectForKey:@"text"] stringByDecodingHTMLEntities];
    
    UILabel *votes = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, 8.0f, 12.0f, 32.0f)];
    [votes setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
    [votes setText:[dictionary objectForKey:@"votes"]];
    UIButton *facebookLike = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 6.0f, 32.0f, 32.0f)];
    [facebookLike setImage:[UIImage imageNamed:@"32-Facebook-Like-2"] forState:UIControlStateNormal];
    [facebookLike setUserInteractionEnabled:YES];
    [facebookLike addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, 44.0f)];
    [accessory addSubview:votes];
    [accessory addSubview:facebookLike];
    
    cell.accessoryView = accessory;
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    // Apple does not allow that we use the accessory custom view with the stock tableview's delegate method, so have to simulate it
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    
    if (indexPath != nil) [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    NSInteger questionID = [[[_questionData objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];

    [[[APIController alloc] initWithDelegate:self forcing:YES] activityUpvoteQuestion:questionID withTokenID:tokenID];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dictionary = [self.questionData objectAtIndex:indexPath.row];
    
    if ([[dictionary objectForKey:@"memberID"] integerValue] == [[HumanToken sharedInstance] memberID]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        NSInteger questionID = [[[_questionData objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
        
        [[[APIController alloc] initWithDelegate:self forcing:YES] activityRemoveQuestion:questionID withTokenID:tokenID];
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getQuestions"]) {
        // Assign the data object
        self.questionData = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        // Save the path of the current file object
        dataPath = apiController.path;
        
        // Reload all table data
        [self.tableView reloadData];
        
        [refreshControl endRefreshing];
        
    } else if ([apiController.method isEqualToString:@"upvoteQuestion"]) {
        // Reload all table data
        [self.tableView reloadData];
    }
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didSaveForLaterWithError:(NSError *)error {
    
    if ([apiController.method isEqualToString:@"getQuestions"]) {
        // Save the path of the current file object
        dataPath = apiController.path;
    } else {
        if ([apiController.method isEqualToString:@"sendQuestion"]) {
            // Save the current object
            [[NSDictionary dictionaryWithObject:self.questionData forKey:@"data"] writeToFile:dataPath atomically:YES];
        }
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
}

@end
