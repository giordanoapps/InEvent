//
//  CompanyToken.h
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIController.h"

@interface CompanyToken : NSObject <APIControllerDelegate>

@property (assign, nonatomic) NSInteger companyID;
@property (strong, nonatomic) NSString *tradeName;
@property (assign, nonatomic) BOOL waiterAvailable;
@property (assign, nonatomic) BOOL orderAvailable;
@property (assign, nonatomic) BOOL reservationAvailable;
@property (assign, nonatomic) BOOL chatAvailable;

+ (CompanyToken *)sharedInstance;

- (void)setEnterpriseStatesWithWaiter:(BOOL)waiterAvailable order:(BOOL)orderAvailable reservation:(BOOL)reservationAvailable chat:(BOOL)chatAvailable;

- (BOOL)isCompanySelected;
- (void)removeEnterprise;

@end
