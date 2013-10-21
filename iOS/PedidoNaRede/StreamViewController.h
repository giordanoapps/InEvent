//
//  StreamViewController.h
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface StreamViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate, APIControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UILabel *hashView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
