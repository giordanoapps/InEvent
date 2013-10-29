//
//  ReaderViewController.h
//  InEvent
//
//  Created by Pedro Góes on 12/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface ReaderViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, InEventAPIControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSDictionary *activityData;

@property (strong, nonatomic) IBOutlet UITextField *numberInput;
@property (strong, nonatomic) IBOutlet UIButton *numberButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *addPersonView;
@property (strong, nonatomic) IBOutlet UITextField *nameInput;
@property (strong, nonatomic) IBOutlet UITextField *emailInput;
@property (strong, nonatomic) IBOutlet UIButton *addPersonButton;

@end
