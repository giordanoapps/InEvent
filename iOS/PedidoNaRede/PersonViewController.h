//
//  PersonViewController.h
//  InEvent
//
//  Created by Pedro Góes on 14/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "WrapperViewController.h"

@class UIPlaceHolderTextView;

@interface PersonViewController : WrapperViewController <InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *view;
@property (nonatomic, strong) IBOutlet UIView *wrapper;
@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *role;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UIView *socialWrapper;
@property (nonatomic, strong) IBOutlet UIButton *inButton;
@property (nonatomic, strong) IBOutlet UIButton *fbButton;
@property (nonatomic, strong) IBOutlet UIPlaceHolderTextView *telephone;
@property (nonatomic, strong) IBOutlet UIPlaceHolderTextView *email;
@property (nonatomic, strong) IBOutlet UITextField *location;
@property (nonatomic, strong) IBOutlet MKMapView *map;

@property (strong, nonatomic) NSDictionary *personData;

@end
