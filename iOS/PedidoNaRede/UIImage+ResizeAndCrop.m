//
//  UIImage+ResizeAndCrop.m
//  Garça
//
//  Created by par on 28/05/13.
//  http://stackoverflow.com/questions/3955189/resize-and-crop-image-centered
//

#import "UIImage+ResizeAndCrop.h"

@implementation UIImage (ResizeAndCrop)

- (UIImage *)resizeToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect {
    CGContextRef                context;
    CGImageRef                  imageRef;
    CGSize                      inputSize;
    UIImage                     *outputImage = nil;
    CGFloat                     scaleFactor, width;
    
    // resize, maintaining aspect ratio:
    
    inputSize = self.size;
    scaleFactor = newSize.height / inputSize.height;
    width = roundf( inputSize.width * scaleFactor );
    
    if ( width > newSize.width ) {
        scaleFactor = newSize.width / inputSize.width;
        newSize.height = roundf( inputSize.height * scaleFactor );
    } else {
        newSize.width = width;
    }
    
    UIGraphicsBeginImageContext( newSize );
    
    context = UIGraphicsGetCurrentContext();
    CGContextDrawImage( context, CGRectMake( 0, 0, newSize.width, newSize.height ), self.CGImage );
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    inputSize = newSize;
    
    // constrain crop rect to legitimate bounds
    if ( cropRect.origin.x >= inputSize.width || cropRect.origin.y >= inputSize.height ) return outputImage;
    if ( cropRect.origin.x + cropRect.size.width >= inputSize.width ) cropRect.size.width = inputSize.width - cropRect.origin.x;
    if ( cropRect.origin.y + cropRect.size.height >= inputSize.height ) cropRect.size.height = inputSize.height - cropRect.origin.y;
    
    // crop
    if ( ( imageRef = CGImageCreateWithImageInRect( outputImage.CGImage, cropRect ) ) ) {
        outputImage = [[UIImage alloc] initWithCGImage: imageRef];
        CGImageRelease( imageRef );
    }
    
    return outputImage;
}

@end

