//
//  FieldView.h
//  InEvent
//
//  Created by Pedro Góes on 04/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldView : UIView

// Setters
- (NSString *)text;
- (void)setText:(NSString *)text;

// Creation
- (UIView *)createField;
- (UIView *)createFieldWithAttributes:(NSArray *)attributes;
- (UIView *)removeField;
- (UIView *)removeFieldBelowView:(UIView *)awningView;
- (BOOL)fieldDidChange;

@end
