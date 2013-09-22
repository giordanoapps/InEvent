//
//  Enrollment.h
//  InEvent
//
//  Created by Pedro Góes on 22/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EnrollmentStateUnknown = 0,
    EnrollmentStateApproved,
    EnrollmentStateDenied
} EnrollmentState;

@protocol Enrollment <NSObject>

@end
