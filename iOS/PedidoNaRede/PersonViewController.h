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
#import "WrapperViewController.h"

@interface PersonViewController : WrapperViewController <InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *view;
@property (nonatomic, strong) IBOutlet UIView *wrapper;
@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *role;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *telephone;
@property (nonatomic, strong) IBOutlet UITextField *location;
@property (nonatomic, strong) IBOutlet UITextField *cpf;
@property (nonatomic, strong) IBOutlet UITextField *rg;
@property (nonatomic, strong) IBOutlet MKMapView *map;

@end
