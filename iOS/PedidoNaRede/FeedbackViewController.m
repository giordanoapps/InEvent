//
//  FeedbackViewController.m
//  InEvent
//
//  Created by Pedro Góes on 24/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FeedbackViewController.h"
#import "ColorThemeController.h"
#import "UIPlaceHolderTextView.h"
#import "HumanToken.h"
#import "EventToken.h"
#import "NSString+HTML.h"

@interface FeedbackViewController () {
    UIRefreshControl *refreshControl;
    BOOL hideCommentBox;
    NSString *dataPath;
}

@property (strong, nonatomic) NSArray *stars;
@property (assign, nonatomic) FeedbackType type;
@property (assign, nonatomic) NSInteger referenceID;
@property (assign, nonatomic) NSInteger rating;

- (IBAction)processStarTap:(id)sender;
- (IBAction)sendForm;

@end

@implementation FeedbackViewController

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
    
    // Right Button
    self.rightBarButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendForm)];
    
    // View
    [((UIControl *)self.view) addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    // Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];
    
    // Box
    CGRect frame = self.view.frame;
    _box.frame = CGRectMake((frame.size.width - _box.frame.size.width) / 2.0f, (frame.size.height - _box.frame.size.height) / 2.0, _box.frame.size.width, _box.frame.size.height);
    [_box setBackgroundColor:[ColorThemeController borderColor]];
    [_box.layer setCornerRadius:10.0];
    [_box.layer setMasksToBounds:YES];
    [_box.layer setBorderWidth:6.0];
    [_box.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
    
    // Title
    [_titleLabel setText:NSLocalizedString(@"Feedback", nil)];
    
    // Message Box
    [_messageBox setBackgroundColor:[ColorThemeController backgroundColor]];
    [_messageBox.layer setMasksToBounds:NO];
    
    // Message
    [_message.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_message setTitle:NSLocalizedString(@"Do you wanna rate me?", nil) forState:UIControlStateNormal];
    [_message setTitleColor:[ColorThemeController textColor]  forState:UIControlStateHighlighted];
    
    // Stars
    _stars = @[_star1, _star2, _star3, _star4, _star5];
    
    // Comment Box
    [_textView setPlaceholder:NSLocalizedString(@"Any comments?", nil)];
    [_textView setAccessibilityLabel:NSLocalizedString(@"Any comments?", nil)];
    [_textView setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Send button
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    if (hideCommentBox) [self hideCommentBox];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Scroll view
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 1.01)];
    
    // Window
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self allocTapBehind];
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

#pragma mark - Setters

- (void)setRating:(NSInteger)rating {
    _rating = rating;
    
    NSString *imageName = @"32-Favorite";
    
    // Loop through all the stars until we find the tapped one
    for (int i = 0; i < [_stars count]; i++) {
        
        [[_stars objectAtIndex:i] setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [[_stars objectAtIndex:i] setAccessibilityLabel:[NSString stringWithFormat:@"%d", i + 1]];
        
        if (rating == (i+1)) {
            imageName = @"32-Unfavorite";
        }
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
    // Send the information to the server
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    if (_type == FeedbackTypeEvent) {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] eventGetOpinionFromEvent:_referenceID withToken:tokenID];
    } else if (_type == FeedbackTypeActivity) {
        [[[APIController alloc] initWithDelegate:self forcing:forcing] activityGetOpinionFromActivity:_referenceID withToken:tokenID];
    }
}

#pragma mark - Public Methods

- (void)setFeedbackType:(FeedbackType)type withReference:(NSInteger)referenceID {
    _type = type;
    _referenceID = referenceID;
    
    // Hide the comments if we have an activity
    if (_type == FeedbackTypeActivity) [self hideCommentBox];
}

#pragma mark - Private Methods

- (void)hideCommentBox {
    
    if (self.isViewLoaded) {
        [_box setFrame:CGRectMake(_box.frame.origin.x, _box.frame.origin.y, _box.frame.size.width, _box.frame.size.height - _textView.frame.size.height)];
        [_sendButton setFrame:CGRectMake(_sendButton.frame.origin.x, _sendButton.frame.origin.y - _textView.frame.size.height, _sendButton.frame.size.width, _sendButton.frame.size.height)];
        [_textView setHidden:YES];
    } else {
        hideCommentBox = YES;
    }
}

- (IBAction)processStarTap:(id)sender {
    // Loop through all the stars until we find the tapped one
    for (int i = 0; i < [_stars count]; i++) {
        if ([_stars objectAtIndex:i] == sender) {
            [self setRating:(i+1)];
        }
    }
}

- (IBAction)sendForm {
    
    if ([_textView.text length] < 1) {
        [_textView setText:@"0"];
    }
    
    // Send the information to the server
    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
    
    if (_type == FeedbackTypeEvent) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] eventSendOpinionWithRating:_rating withMessage:_textView.text toEvent:_referenceID withToken:tokenID];
    } else if (_type == FeedbackTypeActivity) {
        [[[APIController alloc] initWithDelegate:self forcing:YES] activitySendOpinionWithRating:_rating toActivity:_referenceID withToken:tokenID];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }];
}

- (void)dismissKeyboard {
    [_textView resignFirstResponder];
}


#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 160;
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"getOpinion"]) {
        NSArray *answers = [dictionary objectForKey:@"data"];
        if ([answers count] > 0) {
            // Get the rating
            NSInteger rating = [[[answers objectAtIndex:0] objectForKey:@"rating"] integerValue];
            
            // Save the path of the current file object
            dataPath = apiController.path;
            
            // Make sure that the rating has been set
            if (rating != 0) [self setRating:rating];
            
            // Set some text if available
            if (_type == FeedbackTypeEvent) {
                [_textView setText:[[[answers objectAtIndex:0] objectForKey:@"message"] stringByDecodingHTMLEntities]];
            }
        }
    } else if ([apiController.method isEqualToString:@"sendOpinion"]) {
        // Create the object
        NSArray *opinion;
        if (_type == FeedbackTypeEvent) {
            opinion = @[@{@"rating": [NSNumber numberWithInteger:_rating], @"message": _textView.text}];
        } else {
            opinion = @[@{@"rating": [NSNumber numberWithInteger:_rating]}];
        }
        
        // Save the current object
        [[NSDictionary dictionaryWithObject:opinion forKey:@"data"] writeToFile:dataPath atomically:YES];
    }

    
    [refreshControl endRefreshing];
}

- (void)apiController:(APIController *)apiController didSaveForLaterWithError:(NSError *)error {

    if ([apiController.method isEqualToString:@"getOpinion"]) {
        // Save the path of the current file object
        dataPath = apiController.path;
    } else {
        if ([apiController.method isEqualToString:@"sendOpinion"]) {
            // Create the object
            NSArray *opinion;
            if (_type == FeedbackTypeEvent) {
                opinion = @[@{@"rating": [NSNumber numberWithInteger:_rating], @"message": _textView.text}];
            } else {
                opinion = @[@{@"rating": [NSNumber numberWithInteger:_rating]}];
            }
            
            // Save the current object
            [[NSDictionary dictionaryWithObject:opinion forKey:@"data"] writeToFile:dataPath atomically:YES];
        }
        
        // Load the UI controls
        [super apiController:apiController didSaveForLaterWithError:error];
    }
}

@end
