//
//  CustomPopoverBackgroundView.h
//  Garça
//
//  Created by Pedro Góes on 17/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIPopoverBackgroundView.h>

@interface CustomPopoverBackgroundView : UIPopoverBackgroundView {
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@end
