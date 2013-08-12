//
//  UtilitiesController.m
//  NegocioPresente
//
//  Created by Pedro Góes on 22/11/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "UtilitiesController.h"

@implementation UtilitiesController

#pragma mark - User Methods

+ (NSString *)checkForTokenIDInsideFileSystem {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:@"login_signIn.json"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existance = [fileManager fileExistsAtPath:path];
    
    if (existance) {
        // Load it from the filesystem
        return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"tokenID"];
    } else {
        return nil;
    }
}

+ (BOOL)checkJSONFileInsideFilesystemWithNamespace:(NSString *)namespace andMethod:(NSString *)method {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.json", namespace, method]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:path];
}

+ (BOOL)removeJSONFileFromFilesystemWithNamespace:(NSString *)namespace andMethod:(NSString *)method {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.json", namespace, method]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *removeError;
    
    // From filesystem
    return [fileManager removeItemAtPath:path error:&removeError];
}

+ (NSDictionary *)makeBinarySearchInsideArray:(NSArray *)array lookingForID:(NSString *)queryID insideKey:(NSString *)queryKey {

    int min = 0;
//    int max = [[[array lastObject] objectForKey:@"id"] integerValue];
    int max = [array count];
    int key = [queryID integerValue];

    // Continue searching while [min,max] is not empty
    while (max >= min)
    {
        // Calculate the midpoint for roughly equal partition
        int mid = (min + max) / 2;
        
        // Determine which subarray to search
        if ([[[array objectAtIndex:mid] objectForKey:queryKey] integerValue] <  key) {
            // Change min index to search upper subarray
            min = mid + 1;
        } else if ([[[array objectAtIndex:mid] objectForKey:queryKey] integerValue] > key ) {
            // Change max index to search lower subarray
            max = mid - 1;
        } else {
            // Key found at index mid
            return [array objectAtIndex:mid];
        }
    }

    // Key not found
    return nil;
}

+ (CGRect)horizontallyAlignImageView:(UIImageView *)imageView atParentView:(UIView *)parentView {
    
    CGSize imageDimensions = imageView.image.size;

    CGFloat marginLeft = floorf((parentView.frame.size.width - imageDimensions.width) / 2.0);
    
    return CGRectMake(marginLeft, imageView.frame.origin.y, imageDimensions.width, imageDimensions.height);
}

+ (CGRect)horizontallyAlignView:(UIView *)view atParentView:(UIView *)parentView {
    
    CGFloat marginLeft = floorf((parentView.frame.size.width - view.frame.size.width) / 2.0);
    
    return CGRectMake(marginLeft, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

+ (CGRect)centralizeView:(UIView *)view atParentView:(UIView *)parentView {
    
    CGFloat marginLeft = floorf((parentView.frame.size.width - view.frame.size.width) / 2.0);
    CGFloat marginTop = floorf((parentView.frame.size.height - view.frame.size.height) / 2.0);
    
    return CGRectMake(marginLeft, marginTop, view.frame.size.width, view.frame.size.height);
}

+ (NSURL *)urlWithFile:(NSString *)fileName {
    // Encode it
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                           NULL,
                                                                                           (CFStringRef)fileName,
                                                                                           NULL,
                                                                                           (CFStringRef)@"",
                                                                                           kCFStringEncodingUTF8 );
    // (CFStringRef)@"!*'();:@&=+$,/?%#[]",
    
    // Return the URL
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL, encodedString]];
}


+ (UIImage *)loadImageFromRemoteServer:(NSString *)imageName {
    
    // We are going to check if the image that we want is available on the filesystem; if not, we download and save it.
    NSString *fileName = [imageName lastPathComponent];
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"]
                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existance = [fileManager fileExistsAtPath:path];
    
    if (existance) {
        // Load it from the filesystem
        return [UIImage imageWithContentsOfFile:path];
    } else {
        // Encode it
        NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                               NULL,
                                                                                               (CFStringRef)imageName,
                                                                                               NULL,
                                                                                               (CFStringRef)@"",
                                                                                               kCFStringEncodingUTF8 );
        // (CFStringRef)@"!*'();:@&=+$,/?%#[]",
        
        // Download it
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL, encodedString]]];
        
        // Save it
        [image writeToFile:path atomically:YES];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Present it
        return [UIImage imageWithData:image];
    }
}

+ (NSMutableAttributedString *)putSomeColorIntoAString:(NSString *)word withDictionary:(NSDictionary *)wordWithColors {
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSString *word in wordWithColors) {
        UIColor *color = [wordWithColors objectForKey:word];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
        NSAttributedString *subString = [[NSAttributedString alloc] initWithString:word attributes:attributes];
        [string appendAttributedString:subString];
    }
    
    return string;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    
    if (hexString != nil) {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    } else {
        return [UIColor whiteColor];
    }
}

@end
