//
//  APIController.m
//  InEvent
//
//  Created by Pedro Góes on 14/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "APIController.h"
#import "NSString+URLEncoding.h"

#define kGlobalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface APIController ()

@property (nonatomic, strong) NSMutableData *JSONData;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation APIController

#pragma mark - Coding

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.force = [[aDecoder decodeObjectForKey:@"force"] boolValue];
        self.saveForLater = [[aDecoder decodeObjectForKey:@"saveForLater"] boolValue];
        self.maxAge = [[aDecoder decodeObjectForKey:@"maxAge"] doubleValue];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.namespace = [aDecoder decodeObjectForKey:@"namespace"];
        self.method = [aDecoder decodeObjectForKey:@"method"];
        self.attributes = [aDecoder decodeObjectForKey:@"attributes"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithBool:self.force] forKey:@"force"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.saveForLater] forKey:@"saveForLater"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.maxAge] forKey:@"maxAge"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:self.namespace forKey:@"namespace"];
    [aCoder encodeObject:self.method forKey:@"method"];
    [aCoder encodeObject:self.attributes forKey:@"attributes"];
}

#pragma mark - Initializers

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate {
    return [self initWithDelegate:aDelegate forcing:NO withMaxAge:604800.0 withUserInfo:nil];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce {
    return [self initWithDelegate:aDelegate forcing:aForce withMaxAge:604800.0 withUserInfo:nil];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withUserInfo:(NSDictionary *)aUserInfo {
    return [self initWithDelegate:aDelegate forcing:aForce withMaxAge:604800.0 withUserInfo:aUserInfo];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withMaxAge:(NSTimeInterval)aMaxAge withUserInfo:(NSDictionary *)aUserInfo {
    
    self = [super init];
    if (self) {
        // Set our properties
        self.delegate = aDelegate;
        self.force = aForce;
        self.saveForLater = YES;
        self.maxAge = aMaxAge;
        self.userInfo = aUserInfo;
    }
    return self;
}

#pragma mark - Ad
- (void)adGetAdsAtEvent:(NSInteger)eventID {
    
    NSDictionary *attributes = @{@"GET" : @{@"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
    
    [self JSONObjectWithNamespace:@"ad" method:@"getAds" attributes:attributes];
}

- (void)adSeenAd:(NSInteger)adID {

    NSDictionary *attributes = @{@"GET" : @{@"adID" : [NSString stringWithFormat:@"%d", adID]}};
    
    [self JSONObjectWithNamespace:@"ad" method:@"seenAd" attributes:attributes];
}

#pragma mark - Activity

- (void)activityCreateActivityAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"create" attributes:attributes];
    }
}

- (void)activityEditField:(NSString *)name withValue:(NSString *)value atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil && name != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"name" : name, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}, @"POST": @{@"value" : value}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"edit" attributes:attributes];
    }
}

- (void)activityRemoveActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"remove" attributes:attributes];
    }
}

- (void)activityRequestEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)activityRequestEnrollmentForPersonWithName:(NSString *)name andEmail:(NSString *)email atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"name" : name, @"email" : email}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)activityDismissEnrollmentAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)activityDismissEnrollmentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)activityConfirmEntranceForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {
   
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"confirmEntrance" attributes:attributes];
    }
}

- (void)activityRevokeEntranceForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"revokeEntrance" attributes:attributes];
    }
}

- (void)activityConfirmPaymentForPerson:(NSInteger)personID atActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"confirmPayment" attributes:attributes];
    }
}

- (void)activityGetPeopleAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"selection" : @"all"}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"getPeople" attributes:attributes];
    }
}

- (void)activityGetQuestionsAtActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID], @"selection" : @"all"}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"getQuestions" attributes:attributes];
    }
}

- (void)activitySendQuestion:(NSString *)question toActivity:(NSInteger)activityID withTokenID:(NSString *)tokenID {

    if (tokenID != nil && question != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}, @"POST" : @{@"question" : question}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"sendQuestion" attributes:attributes];
    }
}

- (void)activityRemoveQuestion:(NSInteger)questionID withTokenID:(NSString *)tokenID {
   
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"questionID" : [NSString stringWithFormat:@"%d", questionID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"removeQuestion" attributes:attributes];
    }
}

- (void)activityUpvoteQuestion:(NSInteger)questionID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"questionID" : [NSString stringWithFormat:@"%d", questionID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"upvoteQuestion" attributes:attributes];
    }
}

- (void)activityGetOpinionFromActivity:(NSInteger)activityID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"getOpinion" attributes:attributes];
    }
}

- (void)activitySendOpinionWithRating:(NSInteger)rating toActivity:(NSInteger)activityID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"activityID" : [NSString stringWithFormat:@"%d", activityID]}, @"POST" : @{@"rating" : [NSString stringWithFormat:@"%d", rating]}};
        
        [self JSONObjectWithNamespace:@"activity" method:@"sendOpinion" attributes:attributes];
    }
}

#pragma mark - Event

- (void)eventEditField:(NSString *)name withValue:(NSString *)value atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil && name != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"name" : name, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}, @"POST": @{@"value" : value}};
        
        [self JSONObjectWithNamespace:@"event" method:@"edit" attributes:attributes];
    }
}

- (void)eventGetEvents {
    [self JSONObjectWithNamespace:@"event" method:@"getEvents" attributes:@{}];
}

- (void)eventGetEventsWithTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getEvents" attributes:attributes];
    }
}

- (void)eventGetSingleEvent:(NSInteger)eventID {
    
    NSDictionary *attributes = @{@"GET" : @{@"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
    
    [self JSONObjectWithNamespace:@"event" method:@"getSingle" attributes:attributes];
}

- (void)eventGetSingleEvent:(NSInteger)eventID WithTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getSingle" attributes:attributes];
    }
}

- (void)eventRequestEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)eventRequestEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)eventDismissEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
 
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)eventDismissEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
  
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)eventApproveEnrollmentAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"approveEnrollment" attributes:attributes];
    }
}

- (void)eventApproveEnrollmentForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"approveEnrollment" attributes:attributes];
    }
}

- (void)eventGrantPermissionForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"grantPermission" attributes:attributes];
    }
}

- (void)eventRevokePermissionForPerson:(NSInteger)personID atEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"revokePermission" attributes:attributes];
    }
}

- (void)eventGetPeopleAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID], @"selection" : @"all"}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getPeople" attributes:attributes];
    }   
}

- (void)eventGetActivitiesAtEvent:(NSInteger)eventID {

    NSDictionary *attributes = @{@"GET" : @{@"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
    
    [self JSONObjectWithNamespace:@"event" method:@"getActivities" attributes:attributes];
}

- (void)eventGetActivitiesAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getActivities" attributes:attributes];
    }
}

- (void)eventGetOpinionFromEvent:(NSInteger)eventID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getOpinion" attributes:attributes];
    }
}

- (void)eventGetGroupsAtEvent:(NSInteger)eventID {
 
    NSDictionary *attributes = @{@"GET" : @{@"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
    
    [self JSONObjectWithNamespace:@"event" method:@"getGroups" attributes:attributes];
}

- (void)eventGetGroupsAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
   
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"getGroups" attributes:attributes];
    }
}

- (void)eventSendOpinionWithRating:(NSInteger)rating withMessage:(NSString *)message toEvent:(NSInteger)eventID withToken:(NSString *)tokenID {
    
    if (tokenID != nil && message != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}, @"POST" : @{@"message" : message, @"rating" : [NSString stringWithFormat:@"%d", rating]}};
        
        [self JSONObjectWithNamespace:@"event" method:@"sendOpinion" attributes:attributes];
    }
}

#pragma mark - Group

- (void)groupCreateGroupAtEvent:(NSInteger)eventID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"eventID" : [NSString stringWithFormat:@"%d", eventID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"create" attributes:attributes];
    }
}

- (void)groupEditField:(NSString *)name withValue:(NSString *)value atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil && name != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"name" : name, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}, @"POST": @{@"value" : value}};
        
        [self JSONObjectWithNamespace:@"group" method:@"edit" attributes:attributes];
    }
}

- (void)groupRemoveGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"remove" attributes:attributes];
    }
}

- (void)groupRequestEnrollmentAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)groupRequestEnrollmentForPersonWithName:(NSString *)name andEmail:(NSString *)email atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID], @"name" : name, @"email" : email}};
        
        [self JSONObjectWithNamespace:@"group" method:@"requestEnrollment" attributes:attributes];
    }
}

- (void)groupDismissEnrollmentAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)groupDismissEnrollmentForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"dismissEnrollment" attributes:attributes];
    }
}

- (void)groupConfirmEntranceForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {
   
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"confirmEntrance" attributes:attributes];
    }
}

- (void)groupRevokeEntranceForPerson:(NSInteger)personID atGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"group" method:@"revokeEntrance" attributes:attributes];
    }
}

- (void)groupGetPeopleAtGroup:(NSInteger)groupID withTokenID:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID], @"selection" : @"all"}};
        
        [self JSONObjectWithNamespace:@"group" method:@"getPeople" attributes:attributes];
    }
}

#pragma mark - Notifications

- (void)notificationGetNumberOfNotificationsWithTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
    
        [self JSONObjectWithNamespace:@"notification" method:@"getNumberOfNotifications" attributes:attributes];
    }
}

- (void)notificationGetNotificationsWithTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
    
        [self JSONObjectWithNamespace:@"notification" method:@"getNotifications" attributes:attributes];
    }
}

- (void)notificationGetNotificationsSinceNotification:(NSInteger)lastNotificationID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"lastNotificationID" : [NSString stringWithFormat:@"%d", lastNotificationID]}};
    
        [self JSONObjectWithNamespace:@"notification" method:@"getNotificationsSinceNotification" attributes:attributes];
    }
}

- (void)notificationGetLastNotificationIDWithTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"notification" method:@"getLastNotificationID" attributes:attributes];
    }
}

- (void)notificationGetNotificationsWithinTime:(NSInteger)seconds withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"seconds" : [NSString stringWithFormat:@"%d", seconds]}};
    
        [self JSONObjectWithNamespace:@"notification" method:@"getLastNotificationID" attributes:attributes];
    }
}

- (void)notificationGetSingleNotification:(NSInteger)notificationID withTokenID:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"notificationID" : [NSString stringWithFormat:@"%d", notificationID]}};
    
        [self JSONObjectWithNamespace:@"notification" method:@"getSingleNotification" attributes:attributes];
    }
}

#pragma mark - Opinion
- (void)opinionSendOpinionWithRating:(NSInteger)rating withMessage:(NSString *)message withToken:(NSString *)tokenID {
    
    if (message != nil && tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"message" : message, @"rating" : [NSString stringWithFormat:@"%d", rating]}};
        
        [self JSONObjectWithNamespace:@"opinion" method:@"sendOpinion" attributes:attributes];
    }
}

#pragma mark - Person
- (void)personSignIn:(NSString *)email withPassword:(NSString *)password {
    
    if (email != nil && password != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"email" : email, @"password" : password}};
        
        [self JSONObjectWithNamespace:@"person" method:@"signIn" attributes:attributes];
    }
}

- (void)personSignInWithFacebookToken:(NSString *)facebookToken {
    
    if (facebookToken != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"facebookToken" : facebookToken}};
        
        [self JSONObjectWithNamespace:@"person" method:@"signInWithFacebook" attributes:attributes];
    }
}

- (void)personEnroll:(NSString *)name withPassword:(NSString *)password withEmail:(NSString *)email {

    if (name != nil && password != nil && email != nil) {
        NSDictionary *attributes = @{@"POST" : @{@"name" : name, @"password" : password, @"email" : email}};
        
        [self JSONObjectWithNamespace:@"person" method:@"enroll" attributes:attributes];
    }
}

- (void)personGetWorkingEventsWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"person" method:@"getWorkingEvents" attributes:attributes];
    }
}

#pragma mark - Setters

- (NSString *)path {
    return [self generatePath];
}

#pragma mark - Setup Methods

- (void)JSONObjectWithNamespace:(NSString *)namespace method:(NSString *)method attributes:(NSDictionary *)attributes {
    
    // Set our properties
    self.namespace = namespace;
    self.method = method;
    self.attributes = attributes;

    [self start];
}

- (NSString *)generatePath {
    
    NSString *description = [[[_attributes description] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *filename = [NSString stringWithFormat:@"%@_%@_%@.json", _namespace, _method, description];
    
    NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    NSString *cleanFilename = [[filename componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:cleanFilename];
    
    return path;
}

- (BOOL)cacheFileForLaterSync {
    NSString *filename = [NSString stringWithFormat:@"%f.bin", [[NSDate date] timeIntervalSince1970]];
    
    NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"queue"];
    
    // Create directory if necessary
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    if (!isDir) [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *path = [directory stringByAppendingPathComponent:filename];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

#pragma mark - Connection Support

- (void)start {
    
    NSString *path = [self generatePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the data file is available inside the filesystem
    BOOL existance = [fileManager fileExistsAtPath:path];

    // Check if the maximum cache age has been surpassed
    NSError *attributesRetrievalError = nil;
    NSTimeInterval fileDate = [[[fileManager attributesOfItemAtPath:path error:&attributesRetrievalError] fileModificationDate] timeIntervalSince1970];
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970];
    
    // In case it has, we set the controller to the forced state
    if (currentDate - fileDate > self.maxAge) {
        self.force = YES;
    }
    
    // If the data shouldn't be download again (a.k.a. forced), we just retrieve it from the filesystem
    if (existance && !_force) {
        // Load it from the filesystem
        if ([self.delegate respondsToSelector:@selector(apiController:didLoadDictionaryFromServer:)]) {
            [self.delegate apiController:self didLoadDictionaryFromServer: [NSDictionary dictionaryWithContentsOfFile:path]];
        }
    } else {
        // Define our API url
        NSMutableString *url = [NSMutableString stringWithFormat:@"%@developer/api/?method=%@.%@", URL, _namespace, _method];
        
        // Concatenate all the GET attributes inside the URL
        for (NSString *param in [[_attributes objectForKey:@"GET"] allKeys]) {
            [url appendFormat:@"&%@=%@", param, [[[_attributes objectForKey:@"GET"] objectForKey:param] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        }
        
#ifdef DEBUG
        NSLog(@"%@", url);
#endif
    
        // Concatenate all the POST attributes inside the URL
        NSMutableString *postAttributes = [NSMutableString string];
        
        for (NSString *param in [[_attributes objectForKey:@"POST"] allKeys]) {
            [postAttributes appendFormat:@"&%@=%@", param, [[[_attributes objectForKey:@"POST"] objectForKey:param] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        }
        
        // Create a requisition
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        
        if ([_attributes objectForKey:@"POST"] != nil) {
            [request setHTTPBody:[[postAttributes substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPMethod:@"POST"];
        }
        
        // Create a connection
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        // Alloc object if true
        if (connection) {
            self.JSONData = [NSMutableData data];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([((NSHTTPURLResponse *)response) statusCode] == 200) {
        [self.JSONData setLength:0];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        // Kill the connection
        [connection cancel];
        
        // Send a notification to the delegate
        if ([self.delegate respondsToSelector:@selector(apiController:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"HTTP Code Error" code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil];
            [self.delegate apiController:self didFailWithError:error];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append data
    [self.JSONData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Save the file for later
    if (self.saveForLater) [self cacheFileForLaterSync];
    
    // Notify the delegate about the error
    if ([self.delegate respondsToSelector:@selector(apiController:didSaveForLaterWithError:)]) {
        [self.delegate apiController:self didSaveForLaterWithError:error];
        
    } else if ([self.delegate respondsToSelector:@selector(apiController:didFailWithError:)]) {
        [self.delegate apiController:self didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 
#ifdef DEBUG
    NSLog(@"%@", [[NSString alloc] initWithData:self.JSONData encoding:NSUTF8StringEncoding]);
#endif
    
    // Check for integrity
    if (self.JSONData) {
        dispatch_async(kGlobalQueue, ^{
            NSError *error = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:self.JSONData options:0 error:&error];
            [self performSelectorOnMainThread:@selector(end:) withObject:JSON waitUntilDone:YES];
        });
    }
}

- (void)end:(NSDictionary *)JSON {

    // Some typo checking
    if (!JSON || !([JSON isKindOfClass:[NSDictionary class]])) {
        // Notify the delegate about the error
        if ([self.delegate respondsToSelector:@selector(apiController:didFailWithError:)]) {
            [self.delegate apiController:self didFailWithError:[NSError errorWithDomain:@"self" code:3840 userInfo:nil]];
        }
    } else {
        
        // Let's also save our JSON object inside a file
        [JSON writeToFile:[self generatePath] atomically:YES];
        
        // Return our parsed object
        if ([self.delegate respondsToSelector:@selector(apiController:didLoadDictionaryFromServer:)]) {
            [self.delegate apiController:self didLoadDictionaryFromServer:JSON];
        }
    }
    
    // Try to send older cached files still on the queue
    NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"queue"];
    
    NSDirectoryEnumerator *queueFiles = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    
    NSString *path;
    while (path = [queueFiles nextObject]) {
        if ([[path pathExtension] isEqualToString:@"bin"]) {
            // Load the object from the file system
            APIController *apiController = [NSKeyedUnarchiver unarchiveObjectWithFile:[directory stringByAppendingPathComponent:path]];
            // Remove the reference
            [[NSFileManager defaultManager] removeItemAtPath:[directory stringByAppendingPathComponent:path] error:nil];
            // Define a new delegate and launch it
            [apiController setDelegate:nil];
            [apiController start];
            // Finish loop
            break;
        }
    }
}


@end
