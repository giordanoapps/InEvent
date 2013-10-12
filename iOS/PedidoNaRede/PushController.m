//
//  PushController.m
//  Garça
//
//  Created by Pedro Góes on 05/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PushController.h"
#import "AlertView.h"
#import <Parse/Parse.h>

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
        // Get some properties
        NSString *uri = [userInfo objectForKey:@"uri"];
        NSString *value = [userInfo objectForKey:@"value"];
        
        NSRange range = [uri rangeOfString:@"/"];
        NSString *type = [uri substringToIndex:range.location];
        NSString *action = [uri substringFromIndex:range.location];
        
        // Handle UI interaction
        AlertView *alertView = [[AlertView alloc] initWithTitle:NSLocalizedString(@"Update", nil) message:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"] delegate:nil cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"Ok!", nil)];
        [alertView show];
        
        // Propagate push
        NSString *notificationName = nil;
        
        if ([type isEqualToString:@"activity"]) {
            notificationName = @"activityNotification";
        } else if ([type isEqualToString:@"event"]) {
            notificationName = @"eventNotification";
        } else if ([type isEqualToString:@"person"]) {
            notificationName = @"personNotification";
        }
        // Send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"action": action, @"value": value}];
    }
}

@end
