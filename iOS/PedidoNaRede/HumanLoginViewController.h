//
//  HumanLoginViewController.h
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@class HumanViewController;

@interface HumanLoginViewController : WrapperViewController

@property (nonatomic, strong) IBOutlet UIControl *view;
@property (nonatomic, strong) IBOutlet UILabel *accountLabel;
@property (nonatomic, strong) IBOutlet UIControl *bottomBox;
@property (nonatomic, strong) IBOutlet UIControl *bottomInternalBox;
@property (nonatomic, strong) IBOutlet UIView *separator2;
@property (nonatomic, strong) IBOutlet UIView *personFieldWrapper;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UITextField *personName;
@property (nonatomic, strong) IBOutlet UITextField *personPassword;
@property (nonatomic, strong) IBOutlet UITextField *personEmail;
@property (nonatomic, strong) IBOutlet UIButton *personAction;

@property (nonatomic, weak) HumanViewController *delegate;

@end
