//
//  PeopleViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleViewCell.h"
#import "ColorThemeController.h"

@implementation PeopleViewCell

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

- (void)dealloc {
//    [self.initial removeObserver:self forKeyPath:@"bounds"];
}

- (void)layoutSubviews {
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.2f];
}

- (void)configureCell {
//    [self addObserver:self forKeyPath:@"initial" options:NSKeyValueObservingOptionNew context:NULL];
//    [self addObserver:self forKeyPath:@"bounds" options:0 context:NULL];
    
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.2f];
    [self.initial setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.5f];
//}

@end
