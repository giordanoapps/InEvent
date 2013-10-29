//
//  StreamViewController.h
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "InEventAPIController.h"
#import "REComposeViewController.h"
#import "REComposeSheetView.h"

@interface StreamViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate, InEventAPIControllerDelegate, UIImagePickerControllerDelegate, REComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UILabel *hashView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
