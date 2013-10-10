//
//  ReaderViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 08/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "ReaderViewCell.h"
#import "ColorThemeController.h"

@implementation ReaderViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    
    // Enrollment
    [_enrollmentID setTextColor:[ColorThemeController tableViewCellTextHighlightedColor]];
    
    // Title
    [_name setTextColor:[ColorThemeController tableViewCellTextColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
