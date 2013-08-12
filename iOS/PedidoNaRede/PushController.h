//
//  PushController.h
//  Garça
//
//  Created by Pedro Góes on 05/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushController : NSObject

+ (PushController *)sharedInstance;

+ (void)deliverPushNotification:(NSDictionary *)userInfo;

@end
