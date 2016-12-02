//
//  H264Decoder.m
//  P2PCamera
//
//  Created by chenchao on 16/6/15.
//  Copyright © 2016年 TUTK. All rights reserved.
//
// NALU

#import "H264Decoder.h"
#import "Mp4VideoRecorder.h"




@implementation H264Decoder

@synthesize updateDelegate;

- (id) init
{
    if(self=[super init])
    {
        pCodec      =NULL;
        pCodecCtx   =NULL;
        pVideoFrame =NULL;
        
        pictureWidth=0;
        
        setRecordResolveState=0;
        
        av_register_all();
        avcodec_register_all();
        
        pCodec=avcodec_find_decoder(CODEC_ID_H264);
        if(!pCodec){
            printf("Codec not find\n");
        }
        pCodecCtx=avcodec_alloc_context3(pCodec);
        if(!pCodecCtx){
            printf("allocate codec context error\n");
        }
        
        avcodec_open2(pCodecCtx, pCodec, NULL);
        
        pVideoFrame=avcodec_alloc_frame();
        
    }
    
    return self;
}

- (void)dealloc
{
    if(!pCodecCtx){
        avcodec_close(pCodecCtx);
        pCodecCtx=NULL;
    }
    if(!pVideoFrame){
        avcodec_free_frame(&pVideoFrame);
        pVideoFrame=NULL;
    }
    [super dealloc];
}

- (int)DecodeH264Frames: (unsigned char*)inputBuffer withLength:(int)aLength
{

    
    int gotPicPtr=0;
    int result=0;
    
    av_init_packet(&pAvPackage);
    pAvPackage.data=(unsigned char*)inputBuffer;
    pAvPackage.size=aLength;
    //解码
    result=avcodec_decode_video2(pCodecCtx, pVideoFrame, &gotPicPtr, &pAvPackage);
    
    //如果视频尺寸更改，我们丢掉这个frame
    if((pictureWidth!=0)&&(pictureWidth!=pCodecCtx->width)){
        setRecordResolveState=0;
        pictureWidth=pCodecCtx->width;
        return -1;
    }

    //YUV 420 Y U V  -> RGB
    if(gotPicPtr)
    {

        unsigned int lumaLength= (pCodecCtx->height)*(MIN(pVideoFrame->linesize[0], pCodecCtx->width));
        unsigned int chromBLength=((pCodecCtx->height)/2)*(MIN(pVideoFrame->linesize[1], (pCodecCtx->width)/2));
        unsigned int chromRLength=((pCodecCtx->height)/2)*(MIN(pVideoFrame->linesize[2], (pCodecCtx->width)/2));
        
        H264YUV_Frame    yuvFrame;
        memset(&yuvFrame, 0, sizeof(H264YUV_Frame));
        
        yuvFrame.luma.length = lumaLength;
        yuvFrame.chromaB.length = chromBLength;
        yuvFrame.chromaR.length =chromRLength;
        
        yuvFrame.luma.dataBuffer=(unsigned char*)malloc(lumaLength);
        yuvFrame.chromaB.dataBuffer=(unsigned char*)malloc(chromBLength);
        yuvFrame.chromaR.dataBuffer=(unsigned char*)malloc(chromRLength);
        
        copyDecodedFrame(pVideoFrame->data[0],yuvFrame.luma.dataBuffer,pVideoFrame->linesize[0],
                         pCodecCtx->width,pCodecCtx->height);
        copyDecodedFrame(pVideoFrame->data[1], yuvFrame.chromaB.dataBuffer,pVideoFrame->linesize[1],
                         pCodecCtx->width / 2,pCodecCtx->height / 2);
        copyDecodedFrame(pVideoFrame->data[2], yuvFrame.chromaR.dataBuffer,pVideoFrame->linesize[2],
                         pCodecCtx->width / 2,pCodecCtx->height / 2);
        
        yuvFrame.width=pCodecCtx->width;
        yuvFrame.height=pCodecCtx->height;
        
        if(setRecordResolveState==0){
            [[Mp4VideoRecorder getInstance] setVideoWith:pCodecCtx->width withHeight:pCodecCtx->height];
            setRecordResolveState=1;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self updateYUVFrameOnMainThread:(H264YUV_Frame*)&yuvFrame];
        });
        
        free(yuvFrame.luma.dataBuffer);
        free(yuvFrame.chromaB.dataBuffer);
        free(yuvFrame.chromaR.dataBuffer);
        
    }
    av_free_packet(&pAvPackage);
    
    return 0;
}
void copyDecodedFrame(unsigned char *src, unsigned char *dist,int linesize, int width, int height)
{
    
    width = MIN(linesize, width);
    
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dist, src, width);
        dist += width;
        src += linesize;
    }
    
}
- (void)updateYUVFrameOnMainThread:(H264YUV_Frame*)yuvFrame
{
    if(yuvFrame!=NULL){
        if([self.updateDelegate respondsToSelector:@selector(updateDecodedH264FrameData: )]){
            [self.updateDelegate updateDecodedH264FrameData:yuvFrame];
        }
    }
}



@end
