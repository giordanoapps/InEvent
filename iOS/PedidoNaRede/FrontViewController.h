//
//  FrontViewController.h
//  InEvent
//
//  Created by Pedro Góes on 21/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WrapperViewController.h"
#import "APIController.h"

@class UIPlaceHolderTextView;

@interface FrontViewController : WrapperViewController <APIControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *view;
@property (strong, nonatomic) IBOutlet UIImageView *cover;
@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *name;
@property (strong, nonatomic) IBOutlet UILabel *enrollmentID;
@property (strong, nonatomic) IBOutlet UITextField *dateBegin;
@property (strong, nonatomic) IBOutlet UITextField *dateEnd;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *fugleman;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *description;
@property (strong, nonatomic) IBOutlet MKMapView *map;

@end
