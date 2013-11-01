//
//  DemoViewController.m
//  InEvent
//
//  Created by Pedro Góes on 11/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *descriptions;

@end

@implementation DemoViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Enter", nil) style:UIBarButtonItemStyleDone target:self action:@selector(showLogin)];
    
    // We need to setup up our content here
    _images = @[@"256-Earth", @"256-Calendar", @"256-Picture", @"256-Comment", @"256-Tick"];
    _titles = @[NSLocalizedString(@"Welcome!", nil), NSLocalizedString(@"Timeline", nil), NSLocalizedString(@"Photos", nil), NSLocalizedString(@"Groups", nil), NSLocalizedString(@"Ready?", nil)];
    _descriptions = @[NSLocalizedString(@"InEvent brings a whole new experience to your event.", nil), NSLocalizedString(@"A timeline based on your activities!", nil), NSLocalizedString(@"Easily share photos among participants!", nil), NSLocalizedString(@"Join or create a group, a quick way to talk about topics of your choice!", nil), NSLocalizedString(@"Let's go to your first event.", nil)];
    
    _pageControl.numberOfPages = [_titles count];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
   [self setUp];
}

- (void)setUp {

    // Clean up first
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect frame = CGRectZero;
    
    // And then set some content
    for (int i = 0; i < [_titles count]; i++) {
        // Image
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            frame = CGRectMake(self.view.frame.size.width * i + 88.0, 66.0, 144.0, 144.0);
        } else {
            frame = CGRectMake(self.view.frame.size.width * i + 55.0, 44.0, 144.0, 144.0);
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
        [imageView setImage:[UIImage imageNamed:[_images objectAtIndex:i]]];

        // Title
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            frame = CGRectMake(self.view.frame.size.width * (i + 0.0625), 304.0, self.view.frame.size.width * 0.875, 31.0);
        } else {
            frame = CGRectMake(self.view.frame.size.width * (i + 0.48), 20.0, self.view.frame.size.width * 0.48, 63.0);
        }
        
        UILabel *title = [[UILabel alloc] initWithFrame:frame];
        [title setText:[_titles objectAtIndex:i]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [title setNumberOfLines:2];
        [title setBackgroundColor:[UIColor whiteColor]];
        [title setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [title setFont:[UIFont fontWithName:@"Thonburi-Bold" size:24.0]];
        [title setTextColor:[ColorThemeController tableViewCellTextColor]];
        [title setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
        
        // Description
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            frame = CGRectMake(self.view.frame.size.width * (i + 0.0625), 336.0, self.view.frame.size.width * 0.875, 60.0);
        } else {
            frame = CGRectMake(self.view.frame.size.width * (i + 0.48), 91.0, self.view.frame.size.width * 0.48, 145.0);
        }
        
        UILabel *description = [[UILabel alloc] initWithFrame:frame];
        [description setText:[_descriptions objectAtIndex:i]];
        [description setTextAlignment:NSTextAlignmentCenter];
        [description setNumberOfLines:0];
        [description setBackgroundColor:[UIColor whiteColor]];
        [description setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [description setFont:[UIFont fontWithName:@"Thonburi" size:16.0]];
        [description setHighlightedTextColor:[ColorThemeController tableViewCellTextColor]];
        [description setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
        
        [self.scrollView addSubview:imageView];
        [self.scrollView addSubview:title];
        [self.scrollView addSubview:description];
    }
    
    // Update the scroll size
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * [_titles count], self.view.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Reload the content on the right position
    [self setUp];
    
    // Scroll to the beginning
    [self.scrollView scrollRectToVisible:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
}

#pragma mark - User Methods

- (void)showLogin {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"verify" object:nil userInfo:@{@"type": @"person"}];
    }];
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat page = floor(self.scrollView.contentOffset.x / self.view.frame.size.width);
    _pageControl.currentPage = page;
}


@end
