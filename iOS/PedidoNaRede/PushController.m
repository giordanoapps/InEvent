//
//  PushController.m
//  Garça
//
//  Created by Pedro Góes on 05/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PushController.h"

@implementation PushController

#pragma mark - Singleton

+ (PushController *)sharedInstance
{
    static PushController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PushController alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (void)deliverPushNotification:(NSDictionary *)userInfo {
    
    if (userInfo != nil) {
        NSString *uri = [userInfo objectForKey:@"uri"];
        NSString *value = [userInfo objectForKey:@"value"];
        
        NSRange range = [uri rangeOfString:@"/"];
        NSString *type = [uri substringToIndex:range.location];
        NSString *action = [uri substringFromIndex:range.location];
        
        NSString *notificationName = nil;
        
        if ([type isEqualToString:@"table"]) {
            notificationName = @"tableNotification";
        } else if ([type isEqualToString:@"order"]) {
            notificationName = @"orderNotification";
        } else if ([type isEqualToString:@"carte"]) {
            notificationName = @"carteNotification";
        }
        
        // Send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"action": action, @"value": value}];
    }
    
}

@end
