//
//  UIImage+ResizeAndCrop.h
//  Garça
//
//  Created by Pedro Góes on 28/05/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeAndCrop)

- (UIImage *)resizeToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect;

@end
