//
//  FeedbackViewController.m
//  PedidoNaRede
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

@interface FeedbackViewController ()

@property (strong, nonatomic) NSArray *stars;
@property (assign, nonatomic) NSInteger rating;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendForm:)];
    
    // View
    [((UIControl *)self.view) addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    // Box
    CGRect frame = self.view.frame;
    _box.frame = CGRectMake((frame.size.width - _box.frame.size.width) / 2.0f, (frame.size.height - _box.frame.size.height) / 2.0, _box.frame.size.width, _box.frame.size.height);
    [_box setBackgroundColor:[ColorThemeController borderColor]];
    [_box.layer setCornerRadius:10.0];
    [_box.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [_box.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [_box.layer setShadowOpacity:1.0];
    [_box.layer setShadowRadius:5.0];
    [_box.layer setMasksToBounds:NO];
    [_box.layer setBorderWidth:6.0];
    [_box.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
    
    // Title
    [_titleLabel setText:NSLocalizedString(@"Feedback", nil)];
    
    // Message Box
    [_messageBox setBackgroundColor:[ColorThemeController backgroundColor]];
    [_messageBox.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [_messageBox.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [_messageBox.layer setShadowOpacity:1.0];
    [_messageBox.layer setShadowRadius:0.0];
    [_messageBox.layer setMasksToBounds:NO];
    
    // Message
    [_message.titleLabel setTextAlignment: UITextAlignmentCenter];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Methods

- (IBAction)processStarTap:(id)sender {
    
    NSString *imageName = @"32-Favorite";
    
    // Loop through all the stars until we find the tapped one
    for (int i = 0; i < [_stars count]; i++) {
        
        [[_stars objectAtIndex:i] setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [[_stars objectAtIndex:i] setAccessibilityLabel:[NSString stringWithFormat:@"%d", i + 1]];
        
        if ([_stars objectAtIndex:i] == sender) {
            imageName = @"32-Unfavorite";
            _rating = i + 1;
        }
    }
}

- (IBAction)sendForm:(id)sender {
    
    if ([_textView.text length] < 1) {
        [_textView setText:@"0"];
    }
    
    // Send the information to the server
//    NSString *tokenID = [[HumanToken sharedInstance] tokenID];
//    [[[APIController alloc] initWithDelegate:self forcing:YES] opinionSendOpinionWithRating:_rating withMessage:_textView.text withToken:tokenID];
    
    // Remove the tokenID and enterprise
    [[EventToken sharedInstance] removeEvent];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"enterprise"}];
    }];
}

 - (void)dismissKeyboard {
     [_textView resignFirstResponder];
}

@end
