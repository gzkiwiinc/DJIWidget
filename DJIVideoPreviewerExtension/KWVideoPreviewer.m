//
//  KWVideoPreviewer.m
//  DJISdkDemo
//
//  Created by Pandara on 2018/9/14.
//  Copyright © 2018 DJI. All rights reserved.
//

#import "KWVideoPreviewer.h"

@implementation KWVideoPreviewer

- (void)videoProcessFrame:(VideoFrameYUV *)frame {
    if ([self.delegate respondsToSelector:@selector(kwVideoPreviewer:willProcessImageBuffer:)]) {
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CFRetain((CFTypeRef)[self convertToImageBufferFromYUVFrame:frame]);
        [self.delegate kwVideoPreviewer:self willProcessImageBuffer:imageBuffer];
        CFRelease(imageBuffer);
    }
    [super videoProcessFrame:frame];
}

- (CVImageBufferRef)convertToImageBufferFromYUVFrame:(VideoFrameYUV *)yuvFrame {
    // TODO: 是否有必要加锁
    OSType pixelFormatType = 0;
    
    // 这里的格式选取逻辑不确定，可能会有问题，需要注意
    if (yuvFrame->frameType == VPFrameTypeYUV420Planer) {
        pixelFormatType = kCVPixelFormatType_420YpCbCr8Planar;
    } else if (yuvFrame->frameType == VPFrameTypeYUV420SemiPlaner) {
        pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    } else {
        return nil;
    }
    
    NSDictionary *options = @{(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    
    CVPixelBufferRef pixelBuffer = nil;
    
    CVReturn createStatus = CVPixelBufferCreate(kCFAllocatorDefault,
                                                yuvFrame->width,
                                                yuvFrame->height,
                                                pixelFormatType,
                                                (__bridge CFDictionaryRef) options,
                                                &pixelBuffer);
    
    if (createStatus != kCVReturnSuccess) {
        return nil;
    }
    
    if (CVPixelBufferLockBaseAddress(pixelBuffer, 0) != kCVReturnSuccess) {
        CFRelease(pixelBuffer);
        return nil;
    }
    
    [self copyDataFromYUVFrame:yuvFrame toPixelBuffer:pixelBuffer];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return (CVImageBufferRef)CFAutorelease(pixelBuffer);
}

- (void)copyDataFromYUVFrame:(VideoFrameYUV *)yuvFrame
               toPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    uint8_t *luma = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    uint8_t *chromaB = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    uint8_t *chromaR = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);
    
    if (!luma && !chromaB && !chromaR) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return;
    }
    
    int width = yuvFrame->width;
    int height = yuvFrame->height;
    int semiWidth = width / 2;
    int semiHeight = height / 2;
    
    //copy bytes
    if (yuvFrame->luma != NULL && luma != NULL){
        int copyLen = 0;
        switch (yuvFrame->frameType){
            case VPFrameTypeRGBA:
                copyLen = width * height * 4;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = width * height;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = width * height;
                break;
            default:
                break;
        }
        memcpy(luma, yuvFrame->luma, copyLen);
    }
    if (yuvFrame->chromaB != NULL && chromaB != NULL){
        int copyLen = 0;
        switch (yuvFrame->frameType){
            case VPFrameTypeRGBA:
                copyLen = 0;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = semiWidth * semiHeight;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = semiWidth * semiHeight * 2;
                break;
            default:
                break;
        }
        memcpy(chromaB, yuvFrame->chromaB, copyLen);
    }
    if (yuvFrame->chromaR != NULL && chromaR != NULL){
        int copyLen = 0;
        switch (yuvFrame->frameType){
            case VPFrameTypeRGBA:
                copyLen = 0;
                break;
            case VPFrameTypeYUV420Planer:
                copyLen = semiWidth * semiHeight;
                break;
            case VPFrameTypeYUV420SemiPlaner:
                copyLen = 0;
                break;
            default:
                break;
        }
        memcpy(chromaR, yuvFrame->chromaR,copyLen);
    }
}

@end
