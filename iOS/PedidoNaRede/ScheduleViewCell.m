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
    
    // Then we do the same with it's selected
    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.selectedBackgroundView setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];
    
    // Title
//    [_orderTitle setTextColor:[ColorThemeController tableViewCellTextColor]];
//    [_orderTitle setHighlightedTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
//    
//    // Status View
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

#pragma mark - User Methods

- (void)createBottomIdentation {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,0.0);
    CGPathAddLineToPoint(path, NULL, 160.0f, 0.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 100.0f);
    CGPathAddLineToPoint(path, NULL, 110.0f, 150.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 200.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 480.0f);
    CGPathAddLineToPoint(path, NULL, 0.0f, 480.0f);
    CGPathAddLineToPoint(path, NULL, 0.0f, 0.0f);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[UIColor redColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, 160.0f, 480)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [self.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
}

- (void)createUpperTriangle {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,0.0);
    CGPathAddLineToPoint(path, NULL, 160.0f, 0.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 100.0f);
    CGPathAddLineToPoint(path, NULL, 110.0f, 150.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 200.0f);
    CGPathAddLineToPoint(path, NULL, 160.0f, 480.0f);
    CGPathAddLineToPoint(path, NULL, 0.0f, 480.0f);
    CGPathAddLineToPoint(path, NULL, 0.0f, 0.0f);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[UIColor redColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setBounds:CGRectMake(0.0f, 0.0f, 160.0f, 480)];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [self.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
}



@end
