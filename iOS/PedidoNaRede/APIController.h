//
//  APIController.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 14/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
    #if TARGET_IPHONE_SIMULATOR
        #define URL @"http://localhost:8888/InEvent/Web/"
        //#define URL @"http://agarca.com.br/"
    #else
        #define URL @"http://192.168.0.106:8888/InEvent/Web/"
        //#define URL @"http://pedrogoes.info/InEvent/Web/"
    #endif
#else
    #define URL @"http://inevent.us/"
#endif

@class APIController;

@protocol APIControllerDelegate <NSObject>
@optional
- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary;
- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error;

@end

@interface APIController : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic) id<APIControllerDelegate> delegate;
// Override the maxAge checkpoint
@property (assign, nonatomic) BOOL force;
// Maximum allowed age of the cache
@property (assign, nonatomic) NSTimeInterval maxAge;
// Dictionary as a reference point
@property (strong, nonatomic) NSDictionary *userInfo;
// The given namespace for the requisition
@property (nonatomic, strong) NSString *namespace;
// The given method for the requisition
@property (nonatomic, strong) NSString *method;

#pragma mark - Initializers
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withUserInfo:(NSDictionary *)aUserInfo;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withMaxAge:(NSTimeInterval)aMaxAge withUserInfo:(NSDictionary *)aUserInfo;

#pragma mark - Activity
- (void)activityRequestEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRequestEnrollmentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityDismissEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityDismissEnrollmentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityConfirmEntranceForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityGetPeopleAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityGetQuestionsAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activitySendQuestion:(NSString *)question toActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityUpvoteQuestion:(NSInteger)questionID withTokenID:(NSString *)tokenID;

#pragma mark - Event
- (void)eventGetPeopleAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetActivitiesAtEvent:(NSInteger)eventID;
- (void)eventGetScheduleAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;

#pragma mark - Notifications
- (void)notificationGetNumberOfNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsSinceNotification:(NSInteger)lastNotificationID withTokenID:(NSString *)tokenID;
- (void)notificationGetLastNotificationIDWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithinTime:(NSInteger)seconds withTokenID:(NSString *)tokenID;
- (void)notificationGetSingleNotification:(NSInteger)notificationID withTokenID:(NSString *)tokenID;

#pragma mark - Person
- (void)personSignIn:(NSString *)name withPassword:(NSString *)password;
- (void)personSignInWithFacebookToken:(NSString *)facebookToken;
- (void)personRegister:(NSString *)name withPassword:(NSString *)password withEmail:(NSString *)email;
- (void)personGetEventsWithToken:(NSString *)tokenID;

#pragma mark - Setup
- (void)JSONObjectWithNamespace:(NSString *)namespace method:(NSString *)method attributes:(NSDictionary *)attributes;

#pragma mark - Connection Support
- (void)start;

@end
