//
//  MapViewController.h
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WrapperViewController.h"

@interface MapViewController : WrapperViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, InEventAPIControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UITextField *searchField;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
