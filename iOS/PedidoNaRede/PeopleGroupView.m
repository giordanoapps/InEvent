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
    [self changeLayout];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeLayout)]];
}

#pragma mark - Private Methods

- (void)changeLayout {
    
    if (arc4random() % 2 == 0) {
        [self setCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init] animated:YES];
    } else {
        [self setCollectionViewLayout:[[PeopleGroupViewLayout alloc] init] animated:YES];
    }
}



@end
