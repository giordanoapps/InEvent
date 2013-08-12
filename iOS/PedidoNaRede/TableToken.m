//
//  TableToken.m
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "TableToken.h"
#import "HumanToken.h"
#import "APIController.h"

@implementation TableToken

#pragma mark - Singleton

+ (TableToken *)sharedInstance
{
    static TableToken *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TableToken alloc] init];
        // Load the data that is already stored
        [sharedInstance loadEssentialData];
    });
    return sharedInstance;
}

#pragma mark - Setters

- (void)setTableID:(NSInteger)tableID {
    _tableID = tableID;
    
    [self storeEssentialData];
}

- (void)setTableNumber:(NSInteger)tableNumber {
    _tableNumber = tableNumber;
    
    [self storeEssentialData];
}

#pragma mark - Data

- (NSString *)essentialDataPath {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:@"essentialTableData.bin"];
    
    return path;
}

- (void)storeEssentialData {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    // Set the values on the dictionary
    [dictionary setValue:[NSNumber numberWithInteger:_tableID] forKey:@"tableID"];
    [dictionary setValue:[NSNumber numberWithInteger:_tableNumber] forKey:@"tableNumber"];

    // Save it
    [dictionary writeToFile:[self essentialDataPath] atomically:YES];
}

- (void)loadEssentialData {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[self essentialDataPath]];
    
    if (dictionary != nil) {
        _tableID = [[dictionary objectForKey:@"tableID"] integerValue];
        _tableNumber = [[dictionary objectForKey:@"tableNumber"] integerValue];
    } else {
        [self resetData];
    }
}

- (void)resetData {
    _tableID = 0;
    _tableNumber = 0;
}

- (void)dealloc {
    [self storeEssentialData];
}

#pragma mark - User Methods

- (BOOL)isMemberAtTable {
    return (_tableID != 0 && _tableNumber != 0) ? YES : NO;
}

- (void)removeMemberFromTable {
    // Notify the server that the member is checking out from the current table
    [[[APIController alloc] initWithDelegate:self forcing:YES] tableCheckOutWithToken:[[HumanToken sharedInstance] tokenID]];
    
    // Reset the data
    [self resetData];
    
    // Save the data
    [self storeEssentialData];
}

- (void)removeInvalidMemberFromTable {
    // Call this method only when the api returned a 401 error
    [self resetData];
}

@end
