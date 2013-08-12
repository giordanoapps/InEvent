//
//  HumanLoginViewController.h
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface HumanLoginViewController : WrapperViewController

@property (nonatomic, strong) IBOutlet UIControl *topBox;
@property (nonatomic, strong) IBOutlet UIView *bottomBox;
@property (nonatomic, strong) IBOutlet UIView *bottomInternalBox;
@property (nonatomic, strong) IBOutlet UIView *separator1;
@property (nonatomic, strong) IBOutlet UIView *separator2;

@property (nonatomic, strong) IBOutlet UIButton *facebook;
@property (nonatomic, strong) IBOutlet UIButton *general;
@property (nonatomic, strong) IBOutlet UIButton *waiter;

@property (nonatomic, strong) IBOutlet UIView *waiterFieldWrapper;
@property (nonatomic, strong) IBOutlet UITextField *waiterUsername;
@property (nonatomic, strong) IBOutlet UITextField *waiterPassword;
@property (nonatomic, strong) IBOutlet UIButton *waiterButton;

@end
