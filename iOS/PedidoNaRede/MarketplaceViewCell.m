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
    [_name setTextColor:[ColorThemeController tableViewCellTextColor]];
    [_name setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Line
    [_line setBackgroundColor:[ColorThemeController tableViewCellInternalBorderColor]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter Methods

- (void)setApproved:(NSString *)approved {
    _approved = approved;
    
    [self defineStateForApproved:[_approved integerValue] withView:_wrapper];
}


@end
