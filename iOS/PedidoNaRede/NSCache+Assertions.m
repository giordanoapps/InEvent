//
//  NSCache+Assertions.m
//  Garça
//
//  Created by Pedro Góes on 03/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "NSCache+Assertions.h"

@implementation NSCache (Assertions)

- (NSMutableArray *)assertMutableArray:(id)key {
    if ([self objectForKey:key] == NULL) {
        return [NSMutableArray array];
    } else {
        return [self objectForKey:key];
    }
}

@end
