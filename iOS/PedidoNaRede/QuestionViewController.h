//
//  QuestionViewController.h
//  InEvent
//
//  Created by Pedro Góes on 14/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface QuestionViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *questionWrapper;
@property (strong, nonatomic) IBOutlet UITextField *questionInput;
@property (strong, nonatomic) IBOutlet UIButton *questionButton;

@property (strong, nonatomic) NSDictionary *activityData;

@end
