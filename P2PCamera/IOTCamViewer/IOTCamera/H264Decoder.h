//
//  H264Decoder.h
//  P2PCamera
//
//  Created by chenchao on 16/6/15.
//  Copyright © 2016年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#import "DecodeH264Data_YUV.h"


@protocol updateDecodedH264FrameDelegate <NSObject>

@optional
- (void)updateDecodedH264FrameData: (H264YUV_Frame*)yuvFrame;
@end

@interface H264Decoder : NSObject
{
    int         pictureWidth;
    
    AVCodec*    pCodec;
    AVCodecContext* pCodecCtx;
    AVFrame*        pVideoFrame;
    
    AVPacket       pAvPackage;
    
    int                         setRecordResolveState;
}

@property (nonatomic,assign)id<updateDecodedH264FrameDelegate> updateDelegate;

- (id)init;
- (int)DecodeH264Frames: (unsigned char*)inputBuffer withLength:(int)aLength;

@end
