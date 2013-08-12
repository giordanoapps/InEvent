//
//  APIController.m
//  PedidoNaRede
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

#pragma mark - Initializers

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate {
    return [self initWithDelegate:aDelegate forcing:NO withMaxAge:3600.0 withUserInfo:nil];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce {
    return [self initWithDelegate:aDelegate forcing:aForce withMaxAge:3600.0 withUserInfo:nil];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withUserInfo:(NSDictionary *)aUserInfo {
    return [self initWithDelegate:aDelegate forcing:aForce withMaxAge:3600.0 withUserInfo:aUserInfo];
}

- (id)initWithDelegate:(id<APIControllerDelegate>)aDelegate forcing:(BOOL)aForce withMaxAge:(NSTimeInterval)aMaxAge withUserInfo:(NSDictionary *)aUserInfo {
    
    self = [super init];
    if (self) {
        // Set our properties
        self.delegate = aDelegate;
        self.force = aForce;
        self.maxAge = aMaxAge;
        self.userInfo = aUserInfo;
    }
    return self;
}

#pragma mark - Cartes
- (void)carteGetLastChangeDateAtCarte:(NSInteger)carteID {
    
    NSDictionary *attributes = @{@"GET" : @{@"carteID" : [NSString stringWithFormat:@"%d", carteID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getCarteLastChangeDate" attributes:attributes];
}

- (void)carteGetCompleteMainCarteAtCompany:(NSInteger)companyID {
    
    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getCompleteMainCarte" attributes:attributes];
}

- (void)carteGetMainCarteAtCompany:(NSInteger)companyID {
    
    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getMainCarte" attributes:attributes];
}

- (void)carteGetCategoriesAtCarte:(NSInteger)carteID {
 
    NSDictionary *attributes = @{@"GET" : @{@"carteID" : [NSString stringWithFormat:@"%d", carteID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getCategories" attributes:attributes];
}

- (void)carteGetItemsAtCategory:(NSInteger)categoryID {
    
    NSDictionary *attributes = @{@"GET" : @{@"categoryID" : [NSString stringWithFormat:@"%d", categoryID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getItems" attributes:attributes];
}

- (void)carteGetSingleItem:(NSInteger)itemID {
    
    NSDictionary *attributes = @{@"GET" : @{@"itemID" : [NSString stringWithFormat:@"%d", itemID]}};
    
    [self JSONObjectWithNamespace:@"carte" method:@"getSingleItem" attributes:attributes];
}

#pragma mark - Chat
- (void)chatIsAvailableAtCompany:(NSInteger)companyID {
    
    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"chat" method:@"isAvailable" attributes:attributes];
}

- (void)chatSetCanChat:(NSInteger)canChat withToken:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"canChat" : [NSString stringWithFormat:@"%d", canChat]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"setCanChat" attributes:attributes];
    }
}

- (void)chatGetPeopleAvailableToChatAtTable:(NSInteger)tableID {

    NSDictionary *attributes = @{@"GET" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
    
    [self JSONObjectWithNamespace:@"chat" method:@"getPeopleAvailableToChat" attributes:attributes];
}

- (void)chatCreateGroupWithPerson:(NSInteger)personID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"createGroup" attributes:attributes];
    }
}

- (void)chatAddPeople:(NSInteger)personID toGroup:(NSInteger)groupID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"personID" : [NSString stringWithFormat:@"%d", personID], @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"addPeopleToGroup" attributes:attributes];
    }
}

- (void)chatGetPeopleAtGroup:(NSInteger)groupID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"getPeopleAtGroup" attributes:attributes];
    }
}

- (void)chatSendMessage:(NSString *)message toGroup:(NSInteger)groupID withToken:(NSString *)tokenID {
    
    if (message != nil && tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"message" : message, @"groupID" : [NSString stringWithFormat:@"%d", groupID]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"sendMessage" attributes:attributes];
    }
}

- (void)chatGetUndeliveredMessagesWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"getUndeliveredMessages" attributes:attributes];
    }
}

- (void)chatGetMessagesSinceMessage:(NSInteger)messageID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"messageID" : [NSString stringWithFormat:@"%d", messageID]}};
        
        [self JSONObjectWithNamespace:@"chat" method:@"getMessagesSinceMessage" attributes:attributes];
    }
}

#pragma mark - Companies
- (void)companyGetCompaniesCount {
    [self JSONObjectWithNamespace:@"company" method:@"getCompaniesCount" attributes:nil];
}

- (void)companyGetCompanies {
    [self JSONObjectWithNamespace:@"company" method:@"getCompanies" attributes:nil];
}

- (void)companyGetSingleCompany:(NSInteger)companyID {
    
    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"company" method:@"getSingleCompany" attributes:attributes];
}

- (void)companyGetCompaniesForQuery:(NSString *)searchQuery {
    
    if (searchQuery != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"searchQuery" : searchQuery}};
        
        [self JSONObjectWithNamespace:@"company" method:@"getCompaniesForQuery" attributes:attributes];
    }
}

#pragma mark - Delivery
- (void)deliveryIsAvailableAtCompany:(NSInteger)companyID {

    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"delivery" method:@"isAvailable" attributes:attributes];
}

- (void)deliverySendOrderWithItems:(NSMutableSet *)items withToken:(NSString *)tokenID {
    
    if (tokenID != nil && items != nil) {
        
        NSData *dataItems = [NSJSONSerialization dataWithJSONObject:[items allObjects] options:0 error:nil];
        NSString *stringItems = [[NSString alloc] initWithData:dataItems encoding:NSUTF8StringEncoding];
        
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"items": stringItems}};
        
        [self JSONObjectWithNamespace:@"delivery" method:@"sendOrderWithOptions" attributes:attributes];
    }
}

- (void)deliveryCancelOrder:(NSInteger)deliveryID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"deliveryID" : [NSString stringWithFormat:@"%d", deliveryID]}};
        
        [self JSONObjectWithNamespace:@"delivery" method:@"cancelOrder" attributes:attributes];
    }
}

- (void)deliveryGetOrdersWithToken:(NSString *)tokenID {

    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"delivery" method:@"getOrders" attributes:attributes];
    }
}

- (void)deliveryGetOrderStates {
    [self JSONObjectWithNamespace:@"delivery" method:@"getOrderStates" attributes:nil];
}

#pragma mark - Table
- (void)tableRequestCheckInAtTable:(NSInteger)tableID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
        
        [self JSONObjectWithNamespace:@"table" method:@"requestCheckIn" attributes:attributes];
    }
}

- (void)tableRequestCheckInForPerson:(NSInteger)personID atTable:(NSInteger)tableID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID], @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"table" method:@"requestCheckIn" attributes:attributes];
    }
}

//- (void)tableRequestCheckInForAnonymousAtTable:(NSInteger)tableID withName:(NSString *)name {
//    
//    if (name != nil) {
//        NSDictionary *attributes = @{@"GET" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID]}, @"POST" : @{@"name" : name}};
//        
//        [self JSONObjectWithNamespace:@"table" method:@"requestCheckInForAnonymous" attributes:attributes];
//    }
//}

- (void)tableApproveCheckIn:(NSInteger)requestID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"requestID" : [NSString stringWithFormat:@"%d", requestID], @"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"table" method:@"approveCheckIn" attributes:attributes];
    }
}

- (void)tableCheckOutWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"table" method:@"checkOut" attributes:attributes];
    }
}

- (void)tableGetPeopleRequestsWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"table" method:@"getPeopleRequests" attributes:attributes];
    }
}

- (void)tableCallWaiterWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"table" method:@"callWaiter" attributes:attributes];
    }
}

- (void)tableIsTableOccupied:(NSInteger)tableID {
    
    NSDictionary *attributes = @{@"GET" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
    
    [self JSONObjectWithNamespace:@"table" method:@"isOccupied" attributes:attributes];
}

- (void)tableGetTableMapAtCompany:(NSInteger)companyID {
    
    NSDictionary *attributes = @{@"GET" : @{@"companyID" : [NSString stringWithFormat:@"%d", companyID]}};
    
    [self JSONObjectWithNamespace:@"table" method:@"getMap" attributes:attributes];
}

- (void)tableGetSingleTable:(NSInteger)tableID {
    
    NSDictionary *attributes = @{@"GET" : @{@"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
    
    [self JSONObjectWithNamespace:@"table" method:@"getSingle" attributes:attributes];
}

- (void)tableCleanTable:(NSInteger)tableID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
        
        [self JSONObjectWithNamespace:@"table" method:@"clean" attributes:attributes];
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

#pragma mark - Order
- (void)orderSendOrderForItem:(NSInteger)itemID withAmount:(NSInteger)amount withOptions:(NSMutableSet *)options withToken:(NSString *)tokenID {
    
    if (tokenID != nil && options != nil) {
        
        NSData *dataOptions = [NSJSONSerialization dataWithJSONObject:[options allObjects] options:0 error:nil];
        NSString *stringOptions = [[NSString alloc] initWithData:dataOptions encoding:NSUTF8StringEncoding];
        
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"itemID" : [NSString stringWithFormat:@"%d", itemID], @"amount" : [NSString stringWithFormat:@"%d", amount], @"options": stringOptions}};
        
        [self JSONObjectWithNamespace:@"order" method:@"sendOrderWithOptions" attributes:attributes];
    }
}
    
- (void)orderSendOrderForPerson:(NSInteger)personID withItem:(NSInteger)itemID withAmount:(NSInteger)amount withOptions:(NSMutableSet *)options withToken:(NSString *)tokenID {
    
    if (tokenID != nil && options != nil) {
        
        NSData *dataOptions = [NSJSONSerialization dataWithJSONObject:[options allObjects] options:0 error:nil];
        NSString *stringOptions = [[NSString alloc] initWithData:dataOptions encoding:NSUTF8StringEncoding];
        
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}, @"POST" : @{@"personID" : [NSString stringWithFormat:@"%d", personID], @"itemID" : [NSString stringWithFormat:@"%d", itemID], @"amount" : [NSString stringWithFormat:@"%d", amount], @"options": stringOptions}};
        
        [self JSONObjectWithNamespace:@"order" method:@"sendOrderWithOptions" attributes:attributes];
    }
}

- (void)orderCancelOrder:(NSInteger)orderID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"orderID" : [NSString stringWithFormat:@"%d", orderID]}};
        
        [self JSONObjectWithNamespace:@"order" method:@"cancelOrder" attributes:attributes];
    }
}

- (void)orderGetOrdersForPerson:(NSInteger)personID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"personID" : [NSString stringWithFormat:@"%d", personID]}};
        
        [self JSONObjectWithNamespace:@"order" method:@"getOrdersForPerson" attributes:attributes];
    }
}

- (void)orderGetOrdersForTable:(NSInteger)tableID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"tableID" : [NSString stringWithFormat:@"%d", tableID]}};
        
        [self JSONObjectWithNamespace:@"order" method:@"getOrdersForTable" attributes:attributes];
    }
}

- (void)orderGetOrderStates {
    [self JSONObjectWithNamespace:@"order" method:@"getOrderStates" attributes:nil];
}

- (void)orderChangeOrder:(NSInteger)orderID toState:(NSInteger)stateID withToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID, @"orderID" : [NSString stringWithFormat:@"%d", orderID], @"stateID" : [NSString stringWithFormat:@"%d", stateID]}};
        
        [self JSONObjectWithNamespace:@"order" method:@"changeOrderState" attributes:attributes];
    }
}

#pragma mark - Person
- (void)personSignIn:(NSString *)member withPassword:(NSString *)password {
    
    if (member != nil && password != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"member" : member, @"password" : password}};
        
        [self JSONObjectWithNamespace:@"person" method:@"signIn" attributes:attributes];
    }
}

- (void)personSignInWithFacebookToken:(NSString *)fbToken {
    
    if (fbToken != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"facebookToken" : fbToken}};
        
        [self JSONObjectWithNamespace:@"person" method:@"signInWithFacebook" attributes:attributes];
    }
}

- (void)personCreateMember:(NSString *)member withPassword:(NSString *)password withEmail:(NSString *)email {

    if (member != nil && password != nil && email != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"member" : member, @"password" : password, @"email" : email}};
        
        [self JSONObjectWithNamespace:@"person" method:@"createMember" attributes:attributes];
    }
}

- (void)personGetCompaniesWithToken:(NSString *)tokenID {
    
    if (tokenID != nil) {
        NSDictionary *attributes = @{@"GET" : @{@"tokenID" : tokenID}};
        
        [self JSONObjectWithNamespace:@"person" method:@"getCompanies" attributes:attributes];
    }
}

#pragma mark - Setup Methods

- (void)JSONObjectWithNamespace:(NSString *)namespace method:(NSString *)method attributes:(NSDictionary *)attributes {
    
    // Set our properties
    self.namespace = namespace;
    self.method = method;
    self.attributes = attributes;

    [self start];
}

#pragma mark - Connection Support

- (void)start {
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.json", _namespace, _method]];
    
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
        
        // Notify the delegate about the error
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
    // Notify the delegate about the error
    if ([self.delegate respondsToSelector:@selector(apiController:didFailWithError:)]) {
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
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"]
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.json", _namespace, _method]];
        [JSON writeToFile:path atomically:YES];
        
        // Return our parsed object
        if ([self.delegate respondsToSelector:@selector(apiController:didLoadDictionaryFromServer:)]) {
            [self.delegate apiController:self didLoadDictionaryFromServer:JSON];
        }
    }
}


@end
