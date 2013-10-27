//
//  HumanViewController.h
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface HumanViewController : WrapperViewController <APIControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *view;
@property (nonatomic, strong) IBOutlet UIView *wrapper;
@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *description;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *telephone;
@property (nonatomic, strong) IBOutlet UITextField *location;
@property (nonatomic, strong) IBOutlet UITextField *cpf;
@property (nonatomic, strong) IBOutlet UITextField *rg;
@property (nonatomic, strong) IBOutlet MKMapView *map;

- (void)checkSession;

@end
