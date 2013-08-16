//
//  InformationViewController.h
//  Garça
//
//  Created by Pedro Góes on 17/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface InformationViewController : WrapperViewController

@property (nonatomic, strong) IBOutlet UIImageView *cover;
@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, strong) IBOutlet UIView *wrapper;
@property (nonatomic, strong) IBOutlet UIView *separator1;
@property (nonatomic, strong) IBOutlet UIButton *workingTimes;
@property (nonatomic, strong) IBOutlet UIView *separator2;
@property (nonatomic, strong) IBOutlet UIButton *tools;

@property (nonatomic, strong) NSDictionary *companyData;

@end
