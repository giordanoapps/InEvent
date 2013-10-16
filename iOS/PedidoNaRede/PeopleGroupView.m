//
//  PeopleGroupView.m
//  InEvent
//
//  Created by Pedro Góes on 15/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleGroupView.h"
#import "PeopleGroupViewCell.h"
#import "PeopleGroupViewLayout.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PeopleGroupView

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
    // Collection
    self.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    self.collectionViewLayout = [[PeopleGroupViewLayout alloc] init];
}


@end
