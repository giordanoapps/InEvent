//
//  ScheduleItemViewController.m
//  InEvent
//
//  Created by Pedro Góes on 14/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "ScheduleItemViewController.h"
#import "ReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "APIController.h"
#import "CoolBarButtonItem.h"
#import "NSString+HTML.h"
#import "ODRefreshControl.h"
#import "NSObject+Triangle.h"

@interface ScheduleItemViewController () {
    ODRefreshControl *refreshControl;
}


@property (strong, nonatomic) NSMutableArray *questionData;

@end

@implementation ScheduleItemViewController

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
    
    // Wrapper
    [_wrapper.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [_wrapper.layer setBorderWidth:0.4f];
    [_wrapper.layer setCornerRadius:4.0f];
    [_wrapper.layer setMasksToBounds:YES];
    
    // Title
    [_name setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_name setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Description
    [_description setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    
    // Line
    [_line setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    [self createBottomIdentation];

    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(loadQuestions) forControlEvents:UIControlEventValueChanged];
    
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
    
    [self cleanData];
    [self loadData];
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
    [self loadQuestions];
}

#pragma mark - Private Methods

- (void)loadData {
    
    if (_activityData) {
        if ([[HumanToken sharedInstance] isMemberWorking]) {
            self.rightBarButton = [[CoolBarButtonItem alloc] initCustomButtonWithImage:[UIImage imageNamed:@"64-Cog"] frame:CGRectMake(0, 0, 42.0, 30.0) insets:UIEdgeInsetsMake(5.0, 11.0, 5.0, 11.0) target:self action:@selector(alertActionSheet)];
            self.rightBarButton.accessibilityLabel = NSLocalizedString(@"Actions", nil);
            self.rightBarButton.accessibilityTraits = UIAccessibilityTraitSummaryElement;
            self.navigationItem.rightBarButtonItem = self.rightBarButton;
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_activityData objectForKey:@"dateBegin"] integerValue]];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        
        [self defineStateForApproved:[[_activityData objectForKey:@"approved"] integerValue] withView:_wrapper];
        
        _hour.text = [NSString stringWithFormat:@"%.2d", [components hour]];
        _minute.text = [NSString stringWithFormat:@"%.2d", [components minute]];
        _name.text = [[_activityData objectForKey:@"name"] stringByDecodingHTMLEntities];
        _description.text = [[_activityData objectForKey:@"description"] stringByDecodingHTMLEntities];
        
        if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
            _tableView.hidden = NO;
            _questionWrapper.hidden = NO;
        }
    }
}

- (void)cleanData {
    self.navigationItem.rightBarButtonItem = nil;
    [self defineStateForApproved:ScheduleStateUnknown withView:_wrapper];
    _hour.text = @"00";
    _minute.text = @"00";
    _name.text = NSLocalizedString(@"Activity", nil);
    _description.text = @"";
    _tableView.hidden = YES;
    _questionWrapper.hidden = YES;
}

- (void)loadQuestions {
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
    [[[APIController alloc] initWithDelegate:self forcing:YES] activityGetQuestionsAtActivity:activityID withTokenID:tokenID];
}

- (void)didTap {
    // Remove the keyboard
    [_questionInput resignFirstResponder];
}

#pragma - User Methods

- (void)sendMessage {

    // Check if input is not empty
    if (![[_questionInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        // Send the message to our servers
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        NSInteger activityID = [[_activityData objectForKey:@"id"] integerValue];
        [[[APIController alloc] initWithDelegate:self forcing:YES] activitySendQuestion:_questionInput.text toActivity:activityID withTokenID:tokenID];
        
        [self loadQuestions];
        
        // Add the object to the stack and reload it
//        [_questionData addObject:_questionInput.text];
//        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([_questionData count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([_questionData count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [_questionInput setText:@""];
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
    
    if (touch.view != _questionButton) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ActionSheet Methods

- (void)alertActionSheet {
    
    UIActionSheet *actionSheet;
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"See people", nil), nil];
    
    [actionSheet showFromBarButtonItem:self.rightBarButton animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"See people", nil)]) {
        // Load our reader
        ReaderViewController *rvc = [[ReaderViewController alloc] initWithNibName:@"ReaderViewController" bundle:nil];
        
        [rvc setMoveKeyboardRatio:0.0];
        [rvc setActivityData:_activityData];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:rvc animated:YES];
        } else {
            rvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            rvc.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:rvc animated:YES completion:nil];
        }

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
//    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    // Assign the data object to the companies
    self.questionData = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
    
    // Reload all table data
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error {
    [super apiController:apiController didFailWithError:error];
    
    [refreshControl endRefreshing];
}

@end
