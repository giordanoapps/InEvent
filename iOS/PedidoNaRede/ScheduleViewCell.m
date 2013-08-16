//
//  OrderItemViewCell.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScheduleViewCell.h"
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "APIController.h"
#import "NSObject+Triangle.h"

@implementation ScheduleViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell {

    // We can define the background view and its color
    [self setBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.backgroundView setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    [self setSelectionStyle:UITableViewCellEditingStyleNone];
    
    // Then we do the same with it's selected
    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.selectedBackgroundView setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];

    // Wrapper
    [_wrapper.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [_wrapper.layer setBorderWidth:0.4f];
    [_wrapper.layer setCornerRadius:4.0f];
    [_wrapper.layer setMasksToBounds:YES];
    
    // Title
    [_name setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_name setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Description
    [_description setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];
    
    // Line
    [_line setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    
    // Status View
//    [_orderStatusView setTag:0];
//    [_orderStatusView.layer setCornerRadius:10.0];
//    [_orderStatusView.layer setMasksToBounds:NO];
//    [_orderStatusView.layer setBorderWidth:1.0];
//    [_orderStatusView.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
//    [_orderStatusView addTarget:self action:@selector(processTap:event:) forControlEvents:UIControlEventTouchUpInside];
//    
//    // Status Hint
//    [_orderStatusHint setTextColor:[ColorThemeController tableViewCellTextColor]];
//    
//    // Quantity Label
//    [_orderAmountLabel setText:NSLocalizedString(@"Quantity:", nil)];
//    [_orderAmountLabel setTextColor:[ColorThemeController tableViewCellTextColor]];
//    
//    // Quantity
//    [_orderAmount setTextColor:[ColorThemeController tableViewCellTextColor]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter Methods

- (void)setApproved:(NSString *)approved {
    _approved = approved;
    
    [self defineState];
}

#pragma mark - User Methods

- (void)defineState {
    
    // Remove all alpha and border views
//    if (_wrapper.layer != nil) {
//        for (CALayer *layer in _wrapper.layer.sublayers) {
//            [layer removeFromSuperlayer];
//        }
//    }
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated]) {
        if ([_approved integerValue] == 1) {
            [self createUpperTriangleAtView:_wrapper withState:ScheduleStateApproved];
        } else {
            [self createUpperTriangleAtView:_wrapper withState:ScheduleStateDenied];
        }
    } else {
        [self createUpperTriangleAtView:_wrapper withState:ScheduleStateUnknown];
    }
}


@end
