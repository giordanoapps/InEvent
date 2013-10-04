//
//  NSObject+Field.h
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Field)

- (UIView *)createField:(UIView *)field;
- (UIView *)createField:(UIView *)field withAttributes:(NSArray *)attributes;
- (UIView *)removeField:(UIView *)field;

@end
