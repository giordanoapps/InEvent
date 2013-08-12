//
//  HumanToken.m
//  Garça
//
//  Created by Pedro Góes on 06/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "HumanToken.h"
#import "CompanyToken.h"

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

- (void)setCompanies:(NSArray *)companies {
    _companies = companies;
    
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

- (void)setPhoto:(NSString *)photo {
    _photo = photo;
    
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
    [dictionary setValue:_companies forKey:@"companies"];
    [dictionary setValue:[NSNumber numberWithInteger:_memberID] forKey:@"memberID"];
    [dictionary setValue:_name forKey:@"name"];
    [dictionary setValue:_photo forKey:@"photo"];
    
    // Save it
    [dictionary writeToFile:[self essentialDataPath] atomically:YES];
}

- (void)loadEssentialData {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[self essentialDataPath]];
    
    if (dictionary != nil) {
        _tokenID = [dictionary valueForKey:@"tokenID"];
        _companies = [dictionary valueForKey:@"companies"];
        _memberID = [[dictionary objectForKey:@"memberID"] integerValue];
        _name = [dictionary valueForKey:@"name"];
        _photo = [dictionary valueForKey:@"photo"];
    } else {
        [self resetData];
    }
}

- (void)resetData {
    _tokenID = nil;
    _companies = nil;
    _memberID = 0;
    _name = nil;
    _photo = nil;
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
    CompanyToken *company = [CompanyToken sharedInstance];
    
    if ([company isCompanySelected]) {
        return [self worksAtCompany:company.companyID];
    } else {
        return NO;
    }
}

- (BOOL)worksAtCompany:(NSInteger)companyID {
    if (_companies != nil) {
        for (int i = 0; i < [_companies count]; i++) {
            if ([[[_companies objectAtIndex:i] objectForKey:@"id"] integerValue] == companyID) {
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
