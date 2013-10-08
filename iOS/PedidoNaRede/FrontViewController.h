//
//  FrontViewController.h
//  InEvent
//
//  Created by Pedro Góes on 21/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface FrontViewController : WrapperViewController <APIControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *cover;
@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UIView *name; // UILabel
@property (strong, nonatomic) IBOutlet UIView *dateBegin; // UILabel
@property (strong, nonatomic) IBOutlet UIView *dateEnd; // UILabel
@property (strong, nonatomic) IBOutlet UIView *location; // UILabel
@property (strong, nonatomic) IBOutlet UIView *fugleman; // UILabel
@property (strong, nonatomic) IBOutlet UILabel *enrollmentID;

@end