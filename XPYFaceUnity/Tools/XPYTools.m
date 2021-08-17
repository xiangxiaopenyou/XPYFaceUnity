//
//  XPYTools.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/15.
//

#import "XPYTools.h"

@implementation XPYTools

+ (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef {
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBufferRef);
    CVPixelBufferLockBaseAddress(imageBufferRef, 0);
    
    // 影像的细部基本信息
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBufferRef);
    size_t width = CVPixelBufferGetWidth(imageBufferRef);
    size_t height = CVPixelBufferGetHeight(imageBufferRef);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBufferRef);
    
    // 格式化CGContextRef
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contentRef = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // 根据CGContextRef获得UIImage
    CGImageRef imageRef = CGBitmapContextCreateImage(contentRef);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(contentRef);
    
    CVPixelBufferUnlockBaseAddress(imageBufferRef, 0);
    
    return image;
    
}

@end
