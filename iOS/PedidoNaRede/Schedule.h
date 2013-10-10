//
//  Schedule.h
//  InEvent
//
//  Created by Pedro Góes on 22/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ScheduleStateUnknown = -1,
    ScheduleStateDenied,
    ScheduleStateApproved
} ScheduleState;

typedef enum {
    ScheduleSubscribed = 0,
    ScheduleAll
} ScheduleSelection;

@protocol Schedule <NSObject>

@end
