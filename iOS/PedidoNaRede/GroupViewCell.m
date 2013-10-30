//
//  PeopleViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "GroupViewCell.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GroupViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self configureCell];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureCell];
}

- (void)configureCell {
    
    // We can define the background view and its color
    [self setBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.backgroundView setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
    
    // Then we do the same with it's selected
    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.selectedBackgroundView setBackgroundColor:[ColorThemeController tableViewCellSelectedBackgroundColor]];
    
    // Label
    [self.name setTextColor:[ColorThemeController tableViewCellTextColor]];
    [self.description setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Collection View
    self.collectionView.backgroundColor = [ColorThemeController tableViewCellBackgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
