//
//  UtilitiesController.h
//  NegocioPresente
//
//  Created by Pedro Góes on 22/11/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InEventAPIController.h"

@interface UtilitiesController : NSObject

+ (NSString *)checkForTokenIDInsideFileSystem;
+ (BOOL)checkJSONFileInsideFilesystemWithNamespace:(NSString *)namespace andMethod:(NSString *)method;
+ (BOOL)removeJSONFileFromFilesystemWithNamespace:(NSString *)namespace andMethod:(NSString *)method;
+ (NSDictionary *)makeBinarySearchInsideArray:(NSArray *)array lookingForID:(NSString *)queryID insideKey:(NSString *)queryKey;
+ (CGRect)horizontallyAlignImageView:(UIImageView *)imageView atParentView:(UIView *)parentView;
+ (CGRect)horizontallyAlignView:(UIView *)view atParentView:(UIView *)parentView;
+ (CGRect)centralizeView:(UIView *)view atParentView:(UIView *)parentView;
+ (NSURL *)urlWithFile:(NSString *)fileName;
+ (UIImage *)loadImageFromRemoteServer:(NSString *)imageName;
+ (NSMutableAttributedString *)putSomeColorIntoAString:(NSString *)word withDictionary:(NSDictionary *)wordWithColors;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)weekNameFromIndex:(NSInteger)index;

@end
