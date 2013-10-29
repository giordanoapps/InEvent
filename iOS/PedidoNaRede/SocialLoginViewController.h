//
//  SocialLoginViewController.h
//  InEvent
//
//  Created by Pedro Góes on 25/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@class HumanViewController;

@interface SocialLoginViewController : WrapperViewController

@property (nonatomic, strong) IBOutlet UILabel *socialLabel;
@property (nonatomic, strong) IBOutlet UIButton *inButton;
@property (nonatomic, strong) IBOutlet UIButton *fbButton;
@property (nonatomic, strong) IBOutlet UIButton *twButton;
@property (nonatomic, strong) IBOutlet UIView *separator1;
@property (nonatomic, strong) IBOutlet UIButton *accountLabel;

@property (nonatomic, weak) HumanViewController *delegate;

@end
