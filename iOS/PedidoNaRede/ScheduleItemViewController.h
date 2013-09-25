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

@interface ScheduleItemViewController : WrapperViewController <APIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UILabel *hour;
@property (strong, nonatomic) IBOutlet UILabel *minute;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UITextView *description;
@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) NSDictionary *activityData;

@end
