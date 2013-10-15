//
//  QuizViewController.h
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface QuizViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, APIControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
