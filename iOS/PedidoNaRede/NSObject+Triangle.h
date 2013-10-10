//
//  UIView+Triangle.h
//  InEvent
//
//  Created by Pedro Góes on 16/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"

@interface NSObject (Triangle)

- (void)createUpperTriangleAtView:(UIView *)view withState:(ScheduleState)state;
- (void)defineStateForApproved:(NSInteger)approved withView:(UIView *)view;

@end
