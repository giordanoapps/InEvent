//
//  OrderItemViewCell.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderItemViewCell.h"
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "APIController.h"

@implementation OrderItemViewCell

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
    
    // Then we do the same with it's selected
    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.selectedBackgroundView setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];
    
    // Title
    [_orderTitle setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_orderTitle setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Status View
    [_orderStatusView setTag:0];
//    CAShapeLayer *shape = [CAShapeLayer layer];
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
//    [shape setPath:[path CGPath]];
//    [shape setBackgroundColor:[[UIColor clearColor] CGColor]];
//    [shape setFrame:self.bounds];
//    [shape setBorderWidth:3.0];
//    [shape setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
//    [_orderStatusView.layer setMask:shape];
    [_orderStatusView.layer setCornerRadius:10.0];
    [_orderStatusView.layer setMasksToBounds:NO];
    [_orderStatusView.layer setBorderWidth:1.0];
    [_orderStatusView.layer setBorderColor:[[ColorThemeController tableViewCellInternalBorderColor] CGColor]];
    [_orderStatusView addTarget:self action:@selector(processTap:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // Status Hint
    [_orderStatusHint setTextColor:[ColorThemeController tableViewCellTextColor]];
    
    // Quantity Label
    [_orderAmountLabel setText:NSLocalizedString(@"Quantity:", nil)];
    [_orderAmountLabel setTextColor:[ColorThemeController tableViewCellTextColor]];
    
    // Quantity
    [_orderAmount setTextColor:[ColorThemeController tableViewCellTextColor]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - User Methods

- (IBAction)processTap:(id)sender event:(id)event {
    
    // If the title is black, it's on default mode
    // Go to ORDER
    if (_orderStatusView.tag == 0) {
        
        CGRect frame = _orderStatusView.frame;
        frame.origin.x -= frame.size.width * 4.0;
        frame.size.width *= 5.0;
        
        // Set the new state on the control
        [_orderStatusView setTag:1];
        
        // Set a copy so we can retrieve it later
        NSString *temp = _orderStatusHint.text;
        [_orderStatusHint setText:_orderStatusBuffer];
        _orderStatusBuffer = temp;
        
        [UIView animateWithDuration:0.3 animations:^{
            [_orderStatusView setFrame:frame];
        } completion:^(BOOL finished){
            [self performSelector:@selector(resetButton) withObject:nil afterDelay:1.5];
        }];
        
    // Go to PRICE
    } else {
        
        // Animate at the same we reset the button transition
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(resetButton) withObject:nil afterDelay:0];
    }
}

- (void)resetButton {
    CGRect frame = _orderStatusView.frame;
    frame.origin.x += frame.size.width / 5.0 * 4.0;
    frame.size.width /= 5.0;
    
    [_orderStatusView setTag:0];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_orderStatusView setFrame:frame];
    } completion:^(BOOL finished){
        NSString *temp = _orderStatusHint.text;
        [_orderStatusHint setText:_orderStatusBuffer];
        _orderStatusBuffer = temp;
    }];
}

@end
