//
//  UIImage+Common.m
//  HLMagic
//
//  Created by marujun on 13-12-8.
//  Copyright (c) 2013年 chen ying. All rights reserved.
//

#import "UIImage+Common.h"
#import <Accelerate/Accelerate.h>
#import "ZKGlobalHeader.h"

#if __has_include("YYKitMacro.h")
#elif __has_include(<YYKit/YYKitMacro.h>)
#else
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
#endif

const UICornerInset UICornerInsetZero = {0.0f, 0.0f, 0.0f, 0.0f};

@implementation UIImage (Common)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGSizeMake(4, 4)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    return [self imageWithColor:color size:size cornerInset:UICornerInsetZero];
}

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    CGFloat minEdgeSize = cornerRadius * 2 + 1;
    
    return [self imageWithColor:color size:CGSizeMake(minEdgeSize, minEdgeSize) cornerInset:UICornerInsetMakeWithRadius(cornerRadius)];
}

+ (UIImage *)imageWithColor:(UIColor*)color size:(CGSize)size cornerInset:(UICornerInset)cornerInset
{
    if (!color)
        return nil;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect rect = CGRectMake(0.0f, 0.0f, scale*size.width, scale*size.height);
    
    cornerInset.topRight *= scale;
    cornerInset.topLeft *= scale;
    cornerInset.bottomLeft *= scale;
    cornerInset.bottomRight *= scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
        return nil;
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 1.0, 0.0); // <-- Alpha color in background
    CGContextAddRect(context, rect);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextSetFillColorWithColor(context, [color CGColor]); // <-- Color to fill
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, cornerInset.bottomLeft);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, cornerInset.bottomRight);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, cornerInset.topRight);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, cornerInset.topLeft);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(bitmapContext);
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(MAX(cornerInset.topLeft/scale, cornerInset.topRight/scale),
                                              MAX(cornerInset.topLeft/scale, cornerInset.bottomLeft/scale),
                                              MAX(cornerInset.bottomLeft/scale, cornerInset.bottomRight/scale),
                                              MAX(cornerInset.topRight/scale, cornerInset.bottomRight/scale));
    if (UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
        return theImage;
    }
    
    return [theImage resizableImageWithCapInsets:capInsets];
}

@end
