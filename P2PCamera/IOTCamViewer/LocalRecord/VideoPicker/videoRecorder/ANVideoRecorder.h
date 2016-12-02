//
//  ANVideoRecorder.h
//
//  IpCamera
//  Created by chenchao on 13-5-23.
//  Copyright (c) 2013年 aoni. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ANVideoRecorder : NSObject
{
    volatile bool                                    isRecordingVideo;
    NSUInteger                              fps;
    double                                     currentSeconds;
    
    AVAssetWriterInputPixelBufferAdaptor*   videoInputPixelBufAdaptor;
    AVAssetWriterInput*                     videoWriterInput;
    AVAssetWriter *                         videoWriter;
    

}
@property (nonatomic,readwrite)bool                                    isRecordingVideo;

@property (nonatomic,readwrite)NSUInteger                              fps;

+ (ANVideoRecorder* )getInstance;
- (void)initVideoAssertWriter;
- (void)stopWrittingVideo;
- (void)writeVideoWithImageframe: (CGImageRef)frameImage;


@end
