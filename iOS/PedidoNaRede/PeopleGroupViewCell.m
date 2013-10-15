//
//  PeopleGroupViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 15/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleGroupViewCell.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PeopleGroupViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    
    // Label
//    [self.initial setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.0f];
}

@end
