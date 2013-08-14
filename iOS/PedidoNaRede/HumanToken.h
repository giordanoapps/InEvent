//
//  HumanToken.h
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HumanToken : NSObject

@property (strong, nonatomic) NSString *tokenID;
@property (strong, nonatomic) NSArray *events;
@property (assign, nonatomic) NSInteger memberID;
@property (strong, nonatomic) NSString *name;

+ (HumanToken *)sharedInstance;

- (BOOL)isMemberAuthenticated;
//- (BOOL)isMemberWorking;
//- (BOOL)worksAtCompany:(NSInteger)companyID;
- (void)removeMember;

@end
