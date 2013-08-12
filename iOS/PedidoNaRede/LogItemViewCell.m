//
//  LogItemViewCell.m
//  Garça
//
//  Created by Pedro Góes on 11/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "LogItemViewCell.h"
#import "ColorThemeController.h"
#import "BenchView.h"

@implementation LogItemViewCell

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
    
    // We make sure the cell will not be highlighted on touch down
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
    [self.selectedBackgroundView setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setters

- (void)setTable:(BenchView *)table {
    [_table removeFromSuperview];
    _table = table;
    [self addSubview:table];
}

@end
