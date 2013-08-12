//
//  UIViewController+Present.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 23/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchViewControllerDelegate.h"

@interface UIViewController (Present)

- (BOOL)verifyEnterprise;
- (BOOL)verifyPerson;
- (BOOL)verifyTable;
- (BOOL)verifyTableForType:(TableViewData)type;
- (void)verifyCheck;
- (void)verifyFeedback;
- (void)verifyWaiter;
- (void)animateAlongPathWithImageView:(UIImageView *)fixedImageView withRootTouch:(UITouch *)rootTouch withInternalPosition:(CGPoint)internalPosition;

@end
