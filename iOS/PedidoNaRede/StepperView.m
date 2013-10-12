//
//  StepperView.m
//  InEvent
//
//  Created by Pedro Góes on 16/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StepperView.h"
#import "ColorThemeController.h"

@implementation StepperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

#pragma mark - User Methods

- (void)configureView {
    [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"StepperView" owner:self options:nil] objectAtIndex:0]];
    
    // Wrappers
    [_shadowWrapper.layer setShadowColor:[[ColorThemeController shadowColor] CGColor]];
    [_shadowWrapper.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [_shadowWrapper.layer setShadowOpacity:1.0];
    [_shadowWrapper.layer setShadowRadius:0.0];
    
    [_borderWrapper setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    [_borderWrapper.layer setCornerRadius:4.0];
    [_borderWrapper.layer setMasksToBounds:YES];
    [_borderWrapper.layer setBorderWidth:1.0];
    [_borderWrapper.layer setBorderColor:[[ColorThemeController borderColor] CGColor]];
    // Add the fake line
    [_borderWrapper.layer setShadowOpacity:1.0];
    [_borderWrapper.layer setShadowOffset:CGSizeMake(0, 1)];
    [_borderWrapper.layer setShadowColor:[[ColorThemeController tableViewCellShadowColor] CGColor]];
    [_borderWrapper.layer setShadowRadius:1];
    
    // Count Label
    [_itemOrderCount setTextColor:[ColorThemeController textColor]];
    
    // Order Minus
    [_itemOrderMinus addTarget:self action:@selector(changeCount:) forControlEvents:UIControlEventTouchUpInside];
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(_itemOrderMinus.frame.size.width - 1.0f, 0.0f, 1.0f, _itemOrderMinus.frame.size.height);
    rightBorder.backgroundColor = [[ColorThemeController borderColor] CGColor];
    [_itemOrderMinus.layer addSublayer:rightBorder];
    _itemOrderMinus.accessibilityLabel = NSLocalizedString(@"Minus", nil);
    
    // Order Plus
    [_itemOrderPlus addTarget:self action:@selector(changeCount:) forControlEvents:UIControlEventTouchUpInside];
    _itemOrderPlus.accessibilityLabel = NSLocalizedString(@"Plus", nil);
}

- (void)changeCount:(id)sender {
    
    NSInteger number = [_itemOrderCount.text integerValue];
    
    // If is the first one, that's the minus ( - )
    if ((UIButton *)sender == _itemOrderMinus) {
        if (number > 1) {
            [_itemOrderCount setText:[NSString stringWithFormat:@"%d", (number  - 1)]];
        }
        // If is the second one, that's the plus ( + )
    } else if ((UIButton *)sender == _itemOrderPlus) {
        [_itemOrderCount setText:[NSString stringWithFormat:@"%d", (number + 1)]];
    }
}

- (void)setAmount:(NSInteger)amount {
    [_itemOrderCount setText:[NSString stringWithFormat:@"%d", amount]];
}

- (NSInteger)getAmount {
    return [_itemOrderCount.text integerValue];
}

@end
