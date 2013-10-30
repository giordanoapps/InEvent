//
//  GroupViewController.h
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface GroupViewController : WrapperViewController <InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
