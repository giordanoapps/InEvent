//
//  NSString+URLEncoding.m
//  Garça
//
//  Created by Pedro Góes on 04/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
