//
//  Mp4VideoRecorder.h
//  P2PCamera
//
//  Created by chenchao on 16/6/16.
//  Copyright © 2016年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <sys/time.h>
#include "faac.h"


#define AV_MAX_AUDIO_DATA_SIZE					1280
#define AV_MAX_VIDEO_DATA_SIZE					512 * 1024



//录像文件信息
typedef struct tag_RECORD_INFO
{
    int m_nCurPts;			//当前位置的pts
    double m_dCurTime;		//当前位置的时间（没有使用）
    uint m_nTotalTime;		//总时长
    uint m_nLastTimestamp;	//上一个位置的时间戳
}RecordInfo;

typedef struct
{
    int m_nCodecID;
    unsigned int m_nTimestamp;
    
    int m_nSize;
    char m_pszData[AV_MAX_VIDEO_DATA_SIZE];
}FrameData;

typedef struct
{
    int m_nCodecID;
    unsigned int m_nTimestamp;
    
    int m_nSize;
    char m_pszData[AV_MAX_AUDIO_DATA_SIZE];
}AudioData;

// NALU
typedef struct _MP4ENC_NaluUnit
{
    int type;
    int size;
    unsigned char *data;
    
}MP4ENC_NaluUnit;

typedef struct _MP4AVCC_Box
{
    int     sps_length;
    int     pps_length;
    unsigned char spsBuffer[256];
    unsigned char ppsBuffer[128];
    
}MP4_RecordAvccBox;


typedef struct
{
    unsigned char *data;      /* data bits */
    int numBit;          /* number of bits in buffer */
    int size;            /* buffer size in bytes */
    int currentBit;      /* current bit position in bit stream */
    int numByte;         /* number of bytes read/written (only file) */
} HYBitStream;


typedef struct MP4_AAC_CONFIGURE
{
    faacEncHandle hEncoder;        //音频文件描述符
    unsigned int nSampleRate;     //音频采样数
    unsigned int nChannels;  	      //音频声道数
    unsigned int nPCMBitSize;        //音频采样精度
    unsigned int nInputSamples;      //每次调用编码时所应接收的原始数据长度
    unsigned int nMaxOutputBytes;    //每次调用编码时生成的AAC数据的最大长度
    unsigned char* pcmBuffer;       //pcm数据
    unsigned char* aacBuffer;       //aac数据
    
}AACEncodeConfig;




@interface Mp4VideoRecorder : NSObject
{
    bool m_bRecord;				//录像状态
    
    NSString* m_strRecordFile;	//录像文件存放路径
    
    int m_nFileTotalSize;		//文件总大小
    
    RecordInfo m_stFrameInfo;	//视频信息
    RecordInfo m_stAudioInfo;	//音频信息
    
    
    AVStream            *m_pVideoSt; //视频
    AVStream            *m_pAudioSt; //音频
    AVFormatContext     *m_pFormatCtx;
    
    int                 m_nWidth;
    int                 m_nHeight;
    int                 m_nFrameRate;
    double              startTimeStamp;
    
    int                 firstIFrame_states;
    int                 startRecord_states;

    
    MP4_RecordAvccBox   m_avcCBox;
    
    AACEncodeConfig*            g_aacEncodeConfig;
    
    int                         g_writeRemainSize;
    int                         g_bufferRemainSize;
    
    NSLock*                     videoLock;
    
    
}

+ (Mp4VideoRecorder*)getInstance;
- (void)setVideoWith:(int)aWidth withHeight:(int)aHeight;
- (void)writeListenData:(unsigned char *)pszData withSize: (int)size;
- (void)writeFrameData: (unsigned char *)pszData withSize: (int)size;


@end
