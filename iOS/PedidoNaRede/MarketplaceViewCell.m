//
//  OrderItemViewCell.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MarketplaceViewCell.h"
#import "ColorThemeController.h"
#import "HumanToken.h"
#import "APIController.h"
#import "NSObject+Triangle.h"
#import "UIView+Components.h"
#import "Enrollment.h"

@implementation MarketplaceViewCell

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
    [_name setTextColor:[ColorThemeController textColor]];
    [_dateBegin setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    [_timeBegin setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    [_dateEnd setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    [_timeEnd setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Line
    [_line setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
    
    // Button
    [self setUpButtonComponent:_status];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter Methods

- (void)setApproved:(NSInteger)approved {
    _approved = approved;
    
    // Triangle
    [self defineStateForApproved:_approved withView:_wrapper];
}

- (void) setCanEnroll:(NSInteger)canEnroll {
    _canEnroll = canEnroll;
    
    // Button
    if ([[HumanToken sharedInstance] isMemberAuthenticated] && _approved == EnrollmentStateUnknown && _canEnroll == YES) {
        [_status setHidden:NO];
        [_status setBackgroundImage:[[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateNormal];
        [_status setBackgroundImage:[[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateHighlighted];
        [_status setTitle:NSLocalizedString(@"Enroll", nil) forState:UIControlStateNormal];
    } else {
        [_status setHidden:YES];
    }
}

@end
