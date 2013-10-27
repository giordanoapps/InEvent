//
//  APIController.h
//  InEvent
//
//  Created by Pedro Góes on 14/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
    #if TARGET_IPHONE_SIMULATOR
        #define URL @"http://inevent:8888/"
        //#define URL @"http://agarca.com.br/"
    #else
        //#define URL @"http://192.168.0.106:8888/InEvent-dev/Web/"
        //#define URL @"http://pedrogoes.info/InEvent/Web/"
        #define URL @"http://inevent.us/"
    #endif
#else
    #define URL @"http://inevent.us/"
#endif

@class APIController;

@protocol APIControllerDelegate <NSObject>
@optional
- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary;
- (void)apiController:(APIController *)apiController didFailWithError:(NSError *)error;
- (void)apiController:(APIController *)apiController didSaveForLaterWithError:(NSError *)error;

@end

@interface APIController : NSObject <NSURLConnectionDelegate, NSCoding>

@property (strong, nonatomic) id<APIControllerDelegate> delegate;
// Override the maxAge checkpoint
@property (assign, nonatomic) BOOL force;
// Save controller for later syncing
@property (assign, nonatomic) BOOL saveForLater;
// Maximum allowed age of the cache
@property (assign, nonatomic) NSTimeInterval maxAge;
// Dictionary as a reference point
@property (strong, nonatomic) NSDictionary *userInfo;
// The given namespace for the requisition
@property (nonatomic, strong) NSString *namespace;
// The given method for the requisition
@property (nonatomic, strong) NSString *method;
// Path for the current json file
@property (nonatomic, strong, readonly) NSString *path;

#pragma mark - Initializers
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withUserInfo:(NSDictionary *)aUserInfo;
- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withMaxAge:(NSTimeInterval)aMaxAge withUserInfo:(NSDictionary *)aUserInfo;

#pragma mark - Ad
- (void)adGetAdsAtEvent:(NSInteger)eventID;
- (void)adSeenAd:(NSInteger)adID;

#pragma mark - Activity
- (void)activityCreateActivityAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)activityEditField:(NSString *)name withValue:(NSString *)value atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRemoveActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRequestEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRequestEnrollmentForPersonWithName:(NSString *)name andEmail:(NSString *)email atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityDismissEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityDismissEnrollmentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityConfirmEntranceForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRevokeEntranceForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityConfirmPaymentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityGetPeopleAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityGetQuestionsAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activitySendQuestion:(NSString *)question toActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID;
- (void)activityRemoveQuestion:(NSInteger)questionID withTokenID:(NSString *)tokenID;
- (void)activityUpvoteQuestion:(NSInteger)questionID withTokenID:(NSString *)tokenID;
- (void)activityGetOpinionFromActivity:(NSInteger)activityID withToken:(NSString *)tokenID;
- (void)activitySendOpinionWithRating:(NSInteger)rating toActivity:(NSInteger)activityID withToken:(NSString *)tokenID;

#pragma mark - Event
- (void)eventEditField:(NSString *)name withValue:(NSString *)value atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetEvents;
- (void)eventGetEventsWithTokenID:(NSString *)tokenID;
- (void)eventGetSingleEvent:(NSInteger)eventID;
- (void)eventGetSingleEvent:(NSInteger)eventID WithTokenID:(NSString *)tokenID;
- (void)eventRequestEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventRequestEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventDismissEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventDismissEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventApproveEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventApproveEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGrantPermissionForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventRevokePermissionForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetPeopleAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetActivitiesAtEvent:(NSInteger)eventID;
- (void)eventGetActivitiesAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetGroupsAtEvent:(NSInteger)eventID;
- (void)eventGetGroupsAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)eventGetOpinionFromEvent:(NSInteger)eventID withToken:(NSString *)tokenID;
- (void)eventSendOpinionWithRating:(NSInteger)rating withMessage:(NSString *)message toEvent:(NSInteger)eventID withToken:(NSString *)tokenID;

#pragma mark - Group
- (void)groupCreateGroupAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID;
- (void)groupEditField:(NSString *)name withValue:(NSString *)value atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupRemoveGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupRequestEnrollmentAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupRequestEnrollmentForPersonWithName:(NSString *)name andEmail:(NSString *)email atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupDismissEnrollmentAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupDismissEnrollmentForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupConfirmEntranceForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupRevokeEntranceForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;
- (void)groupGetPeopleAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID;

#pragma mark - Notifications
- (void)notificationGetNumberOfNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsSinceNotification:(NSInteger)lastNotificationID withTokenID:(NSString *)tokenID;
- (void)notificationGetLastNotificationIDWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithinTime:(NSInteger)seconds withTokenID:(NSString *)tokenID;
- (void)notificationGetSingleNotification:(NSInteger)notificationID withTokenID:(NSString *)tokenID;

#pragma mark - Person
- (void)personSignIn:(NSString *)email withPassword:(NSString *)password;
- (void)personSignInWithLinkedInToken:(NSString *)linkedInToken;
- (void)personSignInWithFacebookToken:(NSString *)facebookToken;
- (void)personSignInWithTwitterToken:(NSString *)twitterToken;
- (void)personEnroll:(NSString *)name withPassword:(NSString *)password withEmail:(NSString *)email;
- (void)personGetWorkingEventsWithToken:(NSString *)tokenID;

#pragma mark - Photo
- (void)photoPostPhoto:(NSString *)url AtEvent:(NSInteger)eventID WithTokenID:(NSString *)tokenID;
- (void)photoGetPhotosAtEvent:(NSInteger)eventID WithTokenID:(NSString *)tokenID;
- (void)photoGetSinglePhoto:(NSInteger)photoID WithTokenID:(NSString *)tokenID;

#pragma mark - Setup
- (void)JSONObjectWithNamespace:(NSString *)namespace method:(NSString *)method attributes:(NSDictionary *)attributes;

#pragma mark - Connection Support
- (void)start;

@end
