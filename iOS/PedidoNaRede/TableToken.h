//
//  TableToken.h
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIController.h"

@interface TableToken : NSObject <APIControllerDelegate>

@property (assign, nonatomic) NSInteger tableID;
@property (assign, nonatomic) NSInteger tableNumber;

+ (TableToken *)sharedInstance;

- (BOOL)isMemberAtTable;
- (void)removeMemberFromTable;
- (void)removeInvalidMemberFromTable;

@end
