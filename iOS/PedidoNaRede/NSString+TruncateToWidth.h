//
//  NSString+TruncateToWidth.h
//  InEvent
//
//  Created by Pedro Góes on 21/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TruncateToWidth)

- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font;

@end
