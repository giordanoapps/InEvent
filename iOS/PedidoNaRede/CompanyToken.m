//
//  CompanyToken.m
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "CompanyToken.h"

@implementation CompanyToken

#pragma mark - Singleton

+ (CompanyToken *)sharedInstance
{
    static CompanyToken *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CompanyToken alloc] init];
        // Load the data that is already stored
        [sharedInstance loadEssentialData];
    });
    return sharedInstance;
}

#pragma mark - Setters

- (void)setWaiterAvailable:(BOOL)waiterAvailable {
    
    _waiterAvailable = waiterAvailable;
    
    [self storeEssentialData];
    
    // Check if the chat is enabled on this company
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantCurrentState" object:nil userInfo:nil];
}

- (void)setChatAvailable:(BOOL)chatAvailable {
    
    _chatAvailable = chatAvailable;
    
    [self storeEssentialData];
    
    // Check if the chat is enabled on this company
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantCurrentState" object:nil userInfo:nil];
}

- (void)setOrderAvailable:(BOOL)orderAvailable {
    
    _orderAvailable = orderAvailable;
    
    [self storeEssentialData];
    
    // Check if the chat is enabled on this company
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantCurrentState" object:nil userInfo:nil];
}

- (void)setCompanyID:(NSInteger)companyID {
    _companyID = companyID;
    
    [self storeEssentialData];
}

#pragma mark - User Methods

- (void)setEnterpriseStatesWithWaiter:(BOOL)waiterAvailable order:(BOOL)orderAvailable reservation:(BOOL)reservationAvailable chat:(BOOL)chatAvailable {
    
    _waiterAvailable = waiterAvailable;
    _chatAvailable = chatAvailable;
    _reservationAvailable = reservationAvailable;
    _orderAvailable = orderAvailable;
    
    [self storeEssentialData];
    
    // Update the current state of the restaurant controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantCurrentState" object:nil userInfo:nil];
}

- (BOOL)isCompanySelected {
    if (_companyID != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)removeEnterprise {
    // Remove all the data
    [self resetData];
    
    // Save the data
    [self storeEssentialData];
    
    // Notify about the enterprise removal
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectFirstController" object:nil];
    
    // And delete it from the filesystem
    [[NSFileManager defaultManager] removeItemAtPath:[self essentialDataPath] error:nil];
}

#pragma mark - Data

- (NSString *)essentialDataPath {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:@"essentialCompanyData.bin"];
    
    return path;
}

- (void)storeEssentialData {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // Set the values on the dictionary
    [dictionary setValue:[NSNumber numberWithInteger:_companyID] forKey:@"companyID"];
    [dictionary setValue:_tradeName forKey:@"tradeName"];
    [dictionary setValue:[NSNumber numberWithBool:_waiterAvailable] forKey:@"waiterAvailable"];
    [dictionary setValue:[NSNumber numberWithBool:_orderAvailable] forKey:@"orderAvailable"];
    [dictionary setValue:[NSNumber numberWithBool:_reservationAvailable] forKey:@"reservationAvailable"];
    [dictionary setValue:[NSNumber numberWithBool:_chatAvailable] forKey:@"chatAvailable"];
    
    // Save it
    [dictionary writeToFile:[self essentialDataPath] atomically:YES];
}

- (void)loadEssentialData {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[self essentialDataPath]];
    
    if (dictionary != nil) {
        _companyID = [[dictionary objectForKey:@"companyID"] integerValue];
        _tradeName = [dictionary objectForKey:@"tradeName"];
        _waiterAvailable = [[dictionary objectForKey:@"waiterAvailable"] boolValue];
        _orderAvailable = [[dictionary objectForKey:@"orderAvailable"] boolValue];
        _reservationAvailable = [[dictionary objectForKey:@"reservationAvailable"] boolValue];
        _chatAvailable = [[dictionary objectForKey:@"chatAvailable"] boolValue];
    } else {
        [self resetData];
    }
}

- (void)resetData {
    _companyID = 0;
    _tradeName = nil;
    _waiterAvailable = 0;
    _orderAvailable = 0;
    _reservationAvailable = 0;
    _chatAvailable = 0;
}

- (void)dealloc {
    [self storeEssentialData];
}

@end
