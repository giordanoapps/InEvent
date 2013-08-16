//
//  HumanToken.m
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "HumanToken.h"
#import "EventToken.h"

@implementation HumanToken

#pragma mark - Singleton

+ (HumanToken *)sharedInstance
{
    static HumanToken *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HumanToken alloc] init];
        // Load the data that is already stored
        [sharedInstance loadEssentialData];
    });
    return sharedInstance;
}

#pragma mark - Setters

- (void)setTokenID:(NSString *)tokenID {
    _tokenID = tokenID;
    
    [self storeEssentialData];
}

- (void)setWorkingEvents:(NSArray *)workingEvents {
    _workingEvents = workingEvents;
    
    [self storeEssentialData];
}

- (void)setMemberID:(NSInteger)memberID {
    _memberID = memberID;
    
    [self storeEssentialData];
}

- (void)setName:(NSString *)name {
    _name = name;
    
    [self storeEssentialData];
}


#pragma mark - Data

- (NSString *)essentialDataPath {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:@"essentialHumanData.bin"];
    
    return path;
}

- (void)storeEssentialData {
    
    // Only store data if its is meaningful
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:_tokenID forKey:@"tokenID"];
    [dictionary setValue:_workingEvents forKey:@"workingEvents"];
    [dictionary setValue:[NSNumber numberWithInteger:_memberID] forKey:@"memberID"];
    [dictionary setValue:_name forKey:@"name"];
    
    // Save it
    [dictionary writeToFile:[self essentialDataPath] atomically:YES];
}

- (void)loadEssentialData {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[self essentialDataPath]];
    
    if (dictionary != nil) {
        _tokenID = [dictionary valueForKey:@"tokenID"];
        _workingEvents = [dictionary valueForKey:@"workingEvents"];
        _memberID = [[dictionary objectForKey:@"memberID"] integerValue];
        _name = [dictionary valueForKey:@"name"];
    } else {
        [self resetData];
    }
}

- (void)resetData {
    _tokenID = nil;
    _workingEvents = nil;
    _memberID = 0;
    _name = nil;
}

- (void)dealloc {
    [self storeEssentialData];
}

#pragma mark - User Methods

- (BOOL)isMemberAuthenticated {
    if (_tokenID != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isMemberWorking {
    EventToken *event = [EventToken sharedInstance];
    
    if ([event isEventSelected]) {
        return [self worksAtEvent:event.eventID];
    } else {
        return NO;
    }
}

- (BOOL)worksAtEvent:(NSInteger)eventID {
    if (_workingEvents != nil) {
        for (int i = 0; i < [_workingEvents count]; i++) {
            if ([[[_workingEvents objectAtIndex:i] objectForKey:@"id"] integerValue] == eventID) {
                return YES;
            }
        }
    }
    
    // Deny if not found
    return NO;
}

- (void)removeMember {
    // Remove all the data
    [self resetData];
    
    [self storeEssentialData];
}

@end
