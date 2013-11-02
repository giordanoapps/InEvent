//
//  StepperView.h
//  InEvent
//
//  Created by Pedro Góes on 16/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepperView : UIView

@property (strong, nonatomic) IBOutlet UIView *borderWrapper;
@property (strong, nonatomic) IBOutlet UIView *shadowWrapper;
@property (strong, nonatomic) IBOutlet UILabel *itemOrderCount;
@property (strong, nonatomic) IBOutlet UIButton *itemOrderMinus;
@property (strong, nonatomic) IBOutlet UIButton *itemOrderPlus;

@property (assign, nonatomic, getter = getAmount, setter = setAmount:) NSInteger amount;

- (void)configureView;

@end
