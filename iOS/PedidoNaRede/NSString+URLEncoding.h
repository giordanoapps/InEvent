//
//  NSString+URLEncoding.h
//  Garça
//
//  Created by Pedro Góes on 04/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end
