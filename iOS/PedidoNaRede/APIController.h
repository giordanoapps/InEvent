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
        #define URL @"http://localhost:8888/PedidoNaRede-dev/Web/"
        //#define URL @"http://agarca.com.br/"
    #else
        //#define URL @"http://192.168.0.106:8888/PedidoNaRede-dev/Web/"
        #define URL @"http://pedrogoes.info/PedidoNaRede-dev/Web/"
    #endif
#else
    #define URL @"http://agarca.com.br/"
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

#pragma mark - Cartes
- (void)carteGetLastChangeDateAtCarte:(NSInteger)carteID;
- (void)carteGetCompleteMainCarteAtCompany:(NSInteger)companyID;
- (void)carteGetMainCarteAtCompany:(NSInteger)companyID;
- (void)carteGetCategoriesAtCarte:(NSInteger)carteID;
- (void)carteGetItemsAtCategory:(NSInteger)categoryID;
- (void)carteGetSingleItem:(NSInteger)itemID;

#pragma mark - Chat
- (void)chatIsAvailableAtCompany:(NSInteger)companyID;
- (void)chatSetCanChat:(NSInteger)canChat withToken:(NSString *)tokenID;
- (void)chatGetPeopleAvailableToChatAtTable:(NSInteger)tableID;
- (void)chatCreateGroupWithPerson:(NSInteger)personID withToken:(NSString *)tokenID;
- (void)chatAddPeople:(NSInteger)personID toGroup:(NSInteger)groupID withToken:(NSString *)tokenID;
- (void)chatGetPeopleAtGroup:(NSInteger)groupID withToken:(NSString *)tokenID;
- (void)chatSendMessage:(NSString *)message toGroup:(NSInteger)groupID withToken:(NSString *)tokenID;
- (void)chatGetUndeliveredMessagesWithToken:(NSString *)tokenID;
- (void)chatGetMessagesSinceMessage:(NSInteger)messageID withToken:(NSString *)tokenID;

#pragma mark - Companies
- (void)companyGetCompaniesCount;
- (void)companyGetCompanies;
- (void)companyGetSingleCompany:(NSInteger)companyID;
- (void)companyGetCompaniesForQuery:(NSString *)searchQuery;

#pragma mark - Delivery
- (void)deliveryIsAvailableAtCompany:(NSInteger)companyID;
- (void)deliverySendOrderWithItems:(NSMutableSet *)items withToken:(NSString *)tokenID;
- (void)deliveryCancelOrder:(NSInteger)deliveryID withToken:(NSString *)tokenID;
- (void)deliveryGetOrdersWithToken:(NSString *)tokenID;
- (void)deliveryGetOrderStates;
// - (void)deliveryChangeOrder:(NSInteger)deliveryID toState:(NSInteger)stateID withToken:(NSString *)tokenID;

#pragma mark - Tables
- (void)tableRequestCheckInAtTable:(NSInteger)tableID withToken:(NSString *)tokenID;
- (void)tableRequestCheckInForPerson:(NSInteger)personID atTable:(NSInteger)tableID withToken:(NSString *)tokenID;
//- (void)tableRequestCheckInForAnonymousAtTable:(NSInteger)tableID withName:(NSString *)name;
- (void)tableApproveCheckIn:(NSInteger)requestID withToken:(NSString *)tokenID;
- (void)tableCheckOutWithToken:(NSString *)tokenID;
- (void)tableGetPeopleRequestsWithToken:(NSString *)tokenID;
- (void)tableCallWaiterWithToken:(NSString *)tokenID;
- (void)tableIsTableOccupied:(NSInteger)tableID;
- (void)tableGetTableMapAtCompany:(NSInteger)companyID;
- (void)tableGetSingleTable:(NSInteger)tableID;
- (void)tableCleanTable:(NSInteger)tableID withToken:(NSString *)tokenID;

#pragma mark - Notifications
- (void)notificationGetNumberOfNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsSinceNotification:(NSInteger)lastNotificationID withTokenID:(NSString *)tokenID;
- (void)notificationGetLastNotificationIDWithTokenID:(NSString *)tokenID;
- (void)notificationGetNotificationsWithinTime:(NSInteger)seconds withTokenID:(NSString *)tokenID;
- (void)notificationGetSingleNotification:(NSInteger)notificationID withTokenID:(NSString *)tokenID;

#pragma mark - Opinion
- (void)opinionSendOpinionWithRating:(NSInteger)rating withMessage:(NSString *)message withToken:(NSString *)tokenID;

#pragma mark - Order
- (void)orderSendOrderForItem:(NSInteger)itemID withAmount:(NSInteger)amount withOptions:(NSMutableSet *)options withToken:(NSString *)tokenID;
- (void)orderSendOrderForPerson:(NSInteger)personID withItem:(NSInteger)itemID withAmount:(NSInteger)amount withOptions:(NSMutableSet *)options withToken:(NSString *)tokenID;
- (void)orderCancelOrder:(NSInteger)orderID withToken:(NSString *)tokenID;
- (void)orderGetOrdersForPerson:(NSInteger)personID withToken:(NSString *)tokenID;
- (void)orderGetOrdersForTable:(NSInteger)tableID withToken:(NSString *)tokenID;
- (void)orderGetOrderStates;
- (void)orderChangeOrder:(NSInteger)orderID toState:(NSInteger)stateID withToken:(NSString *)tokenID;

#pragma mark - Person
- (void)personSignIn:(NSString *)member withPassword:(NSString *)password;
- (void)personSignInWithFacebookToken:(NSString *)fbToken;
- (void)personCreateMember:(NSString *)member withPassword:(NSString *)password withEmail:(NSString *)email;
- (void)personGetCompaniesWithToken:(NSString *)tokenID;

#pragma mark - Setup
- (void)JSONObjectWithNamespace:(NSString *)namespace method:(NSString *)method attributes:(NSDictionary *)attributes;

#pragma mark - Connection Support
- (void)start;

@end
