//
//  PeopleViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleViewCell.h"

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

//- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"initial"];
//    [self removeObserver:self forKeyPath:@"image"];
//}

- (void)configureCell {
//    [self addObserver:self forKeyPath:@"initial" options:NSKeyValueObservingOptionNew context:NULL];
//    [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    if ([keyPath isEqualToString:@"initial"]) {
//        [_image setHidden:YES];
//        [_initial setHidden:NO];
//    } else if ([keyPath isEqualToString:@"image"]) {
//        [_image setHidden:NO];
//        [_initial setHidden:YES];
//    }
//}

@end
