//
//  PeopleGroupView.m
//  InEvent
//
//  Created by Pedro Góes on 15/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "GroupCirclePeopleView.h"
#import "GroupCirclePeopleViewCell.h"
#import "GroupCirclePeopleViewLayout.h"
#import "ColorThemeController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GroupCirclePeopleView

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
    self.collectionViewLayout = [[GroupCirclePeopleViewLayout alloc] init];
}


@end
