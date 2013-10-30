//
//  PeopleGroupViewLayout.h
//  InEvent
//
//  Created by Pedro Góes on 15/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCirclePeopleViewLayout : UICollectionViewLayout

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger cellCount;

@end
