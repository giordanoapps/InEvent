//
//  MarketplaceViewController.h
//  InEvent
//
//  Created by Pedro Góes on 03/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface MarketplaceViewController : WrapperViewController <UITableViewDelegate, UITableViewDataSource, APIControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
