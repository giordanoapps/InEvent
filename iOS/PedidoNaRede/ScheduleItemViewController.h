//
//  ScheduleItemViewController.h
//  InEvent
//
//  Created by Pedro Góes on 14/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WrapperViewController.h"

@class GMSMapView;
@class UIPlaceHolderTextView;

@interface ScheduleItemViewController : WrapperViewController <InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UITextField *hour;
@property (strong, nonatomic) IBOutlet UITextField *minute;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *description;
@property (strong, nonatomic) IBOutlet UIButton *quickFeedback;
@property (strong, nonatomic) IBOutlet UIButton *quickQuestion;
@property (strong, nonatomic) IBOutlet UIButton *quickPeople;
@property (strong, nonatomic) IBOutlet UIButton *quickMaterial;
@property (strong, nonatomic) IBOutlet MKMapView *map;
//@property (strong, nonatomic) IBOutlet GMSMapView *map;

@property (strong, nonatomic) NSDictionary *activityData;

@end
