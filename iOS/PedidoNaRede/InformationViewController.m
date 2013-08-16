//
//  InformationViewController.m
//  Garça
//
//  Created by Pedro Góes on 17/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "InformationViewController.h"
#import "ColorThemeController.h"
#import "NSString+HTML.h"
#import "UIImage+ResizeAndCrop.h"
#import "UtilitiesController.h"
#import "UIImageView+WebCache.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = NSLocalizedString(@"Ok!", nil);
    self.navigationItem.rightBarButtonItem.accessibilityTraits = UIAccessibilityTraitButton;

    // View
    self.view.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    [self setTitle:[[self.companyData objectForKey:@"tradeName"] stringByDecodingHTMLEntities]];
    
    // Cover
    if ([[self.companyData objectForKey:@"image"] isEqualToString:@""]) {
        CGRect frame = _description.frame;
        frame.origin.y = _cover.frame.origin.y;
        frame.size.height += _cover.frame.size.height;
        [_description setFrame:frame];
        [_cover setFrame:CGRectZero];
    } else {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[UtilitiesController urlWithFile:[self.companyData objectForKey:@"image"]] options:0 progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            
//            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.0, [[self.companyData objectForKey:@"imageTop"] floatValue], image.size.width, image.size.height));
//            image = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
            
            if (image != nil) {
                // Get the float value for the image top offset
                CGFloat imageTop = [[self.companyData objectForKey:@"imageTop"] floatValue];
                // Calculate the ratio
                CGFloat ratioHeight = image.size.width / _cover.frame.size.width;
                // Calculate the new real height
                CGFloat realHeight = image.size.height / ratioHeight;
                // See the difference so we can compensate on his sibling
                CGFloat diffHeight = _cover.frame.size.height - realHeight;
                
                // Apply the height compensation
                [_description setFrame:CGRectMake(_description.frame.origin.x, _description.frame.origin.y - diffHeight, _description.frame.size.width, _description.frame.size.width + diffHeight)];
                
                // Apply the image settings
                [_cover setImage:image];
                [_cover setFrame:CGRectMake(_cover.frame.origin.x, imageTop, _cover.frame.size.width, realHeight)];
            }
        }];
        
        _cover.accessibilityLabel = NSLocalizedString(@"Event Logo", nil);
        _cover.accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitStaticText;
    }

    // Description
    _description.backgroundColor = [ColorThemeController tableViewBackgroundColor];
//    [_description setContentInset:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    [_description setTextColor:[ColorThemeController textColor]];
    [_description setText:[[self.companyData objectForKey:@"description"] stringByDecodingHTMLEntities]];
    
    // Wrapper
    _wrapper.backgroundColor = [ColorThemeController tabBarBackgroundColor];
//    _wrapper.layer.shadowOpacity = 1.0;
//    _wrapper.layer.shadowOffset = CGSizeMake(1.0, 1.0);
//    _wrapper.layer.shadowColor = [[ColorThemeController shadowColor] CGColor];
//    _wrapper.layer.shadowRadius = 5.0;
    
    // Separator 1
    [_separator1 setBackgroundColor:[ColorThemeController shadowColor]];
//    _separator1.layer.shadowOpacity = 1.0;
//    _separator1.layer.shadowOffset = CGSizeMake(1.0, -1.0);
//    _separator1.layer.shadowColor = [[ColorThemeController borderColor] CGColor];
//    _separator1.layer.shadowRadius = 1.0;
    
    // Separator 2
    [_separator2 setBackgroundColor:[ColorThemeController shadowColor]];
//    _separator2.layer.shadowOpacity = 1.0;
//    _separator2.layer.shadowOffset = CGSizeMake(1.0, -1.0);
//    _separator2.layer.shadowColor = [[ColorThemeController borderColor] CGColor];
//    _separator2.layer.shadowRadius = 1.0;
    
    // Working Times
    [_workingTimes setTitleColor:[ColorThemeController navigationBarTextColor] forState:UIControlStateNormal];
    [_workingTimes.titleLabel setNumberOfLines:0];
    [_workingTimes.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_workingTimes setTitle:[[[self.companyData objectForKey:@"workingTimes"] stringByDecodingHTMLEntities] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] forState:UIControlStateNormal];

    // Tools
    [_tools setBackgroundColor:[ColorThemeController tabBarBackgroundColor]];
    [_tools setTitleColor:[ColorThemeController navigationBarTextColor] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    // Call the super method
    [super viewDidAppear:animated];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"egretBlue", @"waiterAvailable", @"egretGreen", @"orderAvailable", @"egretOrange", @"reservationAvailable", @"egretPurple", @"chatAvailable", nil];
    NSArray *allKeys = [parameters allKeys];
    CGFloat lastX = 0.0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, _tools.frame.size.height * 0.85f)];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    for (int i = 0; i < [allKeys count]; i++) {
        if ([[self.companyData objectForKey:[allKeys objectAtIndex:i]] boolValue] == YES) {
            UIButton *imageView = [[UIButton alloc] initWithFrame:CGRectMake(lastX + 14.0, 3.0, 24.0, _tools.frame.size.height * 0.72f)];
            [imageView setImage:[UIImage imageNamed:[[parameters allValues] objectAtIndex:i]] forState:UIControlStateNormal];
            [imageView setAutoresizingMask:0];
            [imageView addTarget:self action:@selector(pushToolController:) forControlEvents:UIControlEventTouchUpInside];
            lastX += 60.0;
            [view addSubview:imageView];
        }
    }
    
    // Centralize the div (vertically and horizontally)
    [view setFrame:CGRectMake((view.frame.size.width - lastX) * 0.5, (_tools.frame.size.height - view.frame.size.height) * 0.5, lastX, view.frame.size.height)];
    [self.tools addSubview:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Methods

- (void)dismiss {
    
    // Dismiss the controller
    [self dismissModalViewControllerAnimated:YES];
}

@end
