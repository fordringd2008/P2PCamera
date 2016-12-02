//
//  Mp4VideoRecorder.m
//  P2PCamera
//
//  Created by chenchao on 16/6/16.
//  Copyright © 2016年 TUTK. All rights reserved.
//

#import "Mp4VideoRecorder.h"

static Mp4VideoRecorder* instance=nil;

static unsigned char avcCBytes[512]={0};

@implementation Mp4VideoRecorder


+ (Mp4VideoRecorder*)getInstance
{
    @synchronized (self) {
        if(instance==nil){
            instance=[[Mp4VideoRecorder alloc] init];
        }
    }
    return instance;
}
- (id)init{
    
    if (self = [super init]){
        
        m_bRecord = false;
        m_pVideoSt = NULL;
        m_pAudioSt = NULL;
        m_pFormatCtx = NULL;
        
        m_nWidth = -1;
        m_nHeight = -1;
        m_nFrameRate = -1;
        m_nFileTotalSize = 0;
        startTimeStamp=0;
        
        firstIFrame_states=0;
        startRecord_states=0;
        
        
        g_aacEncodeConfig=NULL;
        
        
        videoLock=[[NSLock alloc] init];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StartRecord) name:@"startRecordingVideo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecord) name:@"stopRecordingVideo" object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startRecordingVideo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopRecordingVideo" object:nil];
    
    [videoLock release];
    
    
    [instance release];
    instance=nil;
    
    [super dealloc];
}





- (bool) startRecordFileWithPath
{
    //每次开始时，根据设置的录像路径+时间，生成一个新的文件名。
    
    
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* path = [paths objectAtIndex:0];
    NSLog(@"MP4 PATH: %@",path);
    
    NSDateFormatter *dateFormatter0 = [[NSDateFormatter alloc] init];
    [dateFormatter0 setDateFormat:@"yyMMddHHmmssAA"];
    NSString *currentDateStr = [dateFormatter0 stringFromDate:[NSDate date]];
    //NSLog(@"Current DateFormat MP4 %@\n",currentDateStr);

    
    NSString* outputVideoName=[NSString stringWithFormat:@"%@.mp4",currentDateStr];
    NSString *videoOutputPath=[path stringByAppendingPathComponent:outputVideoName];
    
    m_strRecordFile=videoOutputPath;
    
    [dateFormatter0 release];
 

    
    return true;
}



- (void)setVideoWith:(int)aWidth withHeight:(int)aHeight
{
    
    m_nWidth = aWidth;
    m_nHeight = aHeight;
    m_nFrameRate = 30;
    
}

- (void)startRecordWithPath: (NSString*)path;
{
    
}

- (void)StartRecord
{
    printf("Start Record------------->>>>>\n");
    startTimeStamp=[self _GetTickCount];
    
    firstIFrame_states=0;
    startRecord_states=0;
    
    g_aacEncodeConfig=NULL;
    
    g_aacEncodeConfig=[self initAudioEncodeConfiguration];
    if(g_aacEncodeConfig==NULL){
        return;
    }
    
    m_bRecord = true;
}

- (void)stopRecord
{
    printf("Stop Record------------->>>>>\n");
    m_bRecord = false;
    
    
    int ret = -1;
    
    if (m_pFormatCtx != NULL && m_nFileTotalSize > 0)
    {
        if ((ret = av_write_trailer(m_pFormatCtx)) != 0)
        {
            NSLog(@"Call av_write_trailer function failed, return:%d.", ret);
        }
    }
    
    if (m_pVideoSt != NULL && m_pVideoSt->codec != NULL)
    {
        if ((ret = avcodec_close(m_pVideoSt->codec)) != 0)
        {
            NSLog(@"Call avcodec_close function failed, return:%d.", ret);
        }
        m_pVideoSt->codec->extradata=NULL;
        m_pVideoSt = NULL;
    }
    
    if (m_pAudioSt != NULL && m_pAudioSt->codec != NULL)
    {
        if(m_pAudioSt->codec->extradata!=NULL){
            free(m_pAudioSt->codec->extradata);
            m_pAudioSt->codec->extradata=NULL;
        }
        
        if ((ret = avcodec_close(m_pAudioSt->codec)) != 0)
        {
            NSLog(@"Call avcodec_close function failed, return:%d.", ret);
        }
        
        m_pAudioSt = NULL;
    }
    
    if (m_pFormatCtx != NULL && m_pFormatCtx->pb != NULL && !(m_pFormatCtx->oformat->flags & AVFMT_NOFILE))
    {
        if ((ret = avio_close(m_pFormatCtx->pb)) != 0)
        {
            NSLog(@"Call avio_close function failed, return:%d.", ret);
        }
        
        m_pFormatCtx->pb = NULL;
    }
    
    if (m_pFormatCtx != NULL)
    {
        avformat_free_context(m_pFormatCtx);
        
        m_pFormatCtx = NULL;
    }
    
    if(g_aacEncodeConfig!=NULL)
    {
        
        if(g_aacEncodeConfig->pcmBuffer!=NULL)
        {
            free(g_aacEncodeConfig->pcmBuffer);
            g_aacEncodeConfig->pcmBuffer = NULL;
        }
        
        if(g_aacEncodeConfig->aacBuffer!=NULL)
        {
            free(g_aacEncodeConfig->aacBuffer);
            g_aacEncodeConfig->aacBuffer = NULL;
        }
        
        if(g_aacEncodeConfig->hEncoder!=NULL)
        {
            faacEncClose(g_aacEncodeConfig->hEncoder);
            g_aacEncodeConfig->hEncoder = NULL;
        }
        
        free(g_aacEncodeConfig);
        g_aacEncodeConfig = NULL;
    }
    
    [self ResetRecordInfo];
    
    
}




// 初始化音频.

-(AACEncodeConfig*)initAudioEncodeConfiguration
{
    AACEncodeConfig* aacConfig = NULL;
    
    faacEncConfigurationPtr pConfiguration;
    
    int nRet = 0;
    int pcmBufferSize = 0;
    
    aacConfig = (AACEncodeConfig*)malloc(sizeof(AACEncodeConfig));
    
    aacConfig->nSampleRate = 8000;
    aacConfig->nChannels = 1;
    aacConfig->nPCMBitSize = 16;
    aacConfig->nInputSamples = 0;
    aacConfig->nMaxOutputBytes = 0;
    
    aacConfig->hEncoder = faacEncOpen(aacConfig->nSampleRate, aacConfig->nChannels,  (unsigned long *)&aacConfig->nInputSamples, (unsigned long *)&aacConfig->nMaxOutputBytes);
    if(aacConfig->hEncoder == NULL)
    {
        printf("failed to call faacEncOpen()\n");
        return NULL;
    }
    
    pcmBufferSize = (int)(aacConfig->nInputSamples*(aacConfig->nPCMBitSize/8));
    
    aacConfig->pcmBuffer=(unsigned char*)malloc(pcmBufferSize*sizeof(unsigned char));
    memset(aacConfig->pcmBuffer, 0, pcmBufferSize);
    
    aacConfig->aacBuffer=(unsigned char*)malloc(aacConfig->nMaxOutputBytes*sizeof(unsigned char));
    memset(aacConfig->aacBuffer, 0, aacConfig->nMaxOutputBytes);
    
    
    pConfiguration = faacEncGetCurrentConfiguration(aacConfig->hEncoder);
    
    pConfiguration->inputFormat = FAAC_INPUT_16BIT;
    pConfiguration->outputFormat = 0;
    pConfiguration->aacObjectType = LOW;
    
    
    
    
    nRet = faacEncSetConfiguration(aacConfig->hEncoder, pConfiguration);
    
    return aacConfig;
}


-(AVStream*) initVideoContextInfo
{
    
    AVStream* pOutputStream = avformat_new_stream(m_pFormatCtx,0);
    if (pOutputStream == NULL)
    {
        return NULL;
    }
    
    pOutputStream->id = m_pFormatCtx->nb_streams - 1;
    
    AVCodecContext *pCodecContext = pOutputStream->codec;
    
    
    
    pCodecContext->codec_id = CODEC_ID_H264;
    
    pCodecContext->codec_type = AVMEDIA_TYPE_VIDEO;
    
    
    if((m_avcCBox.pps_length>0)&&(m_avcCBox.sps_length>0))
    {
        
        int spsLen=m_avcCBox.sps_length;
        int ppsLen=m_avcCBox.pps_length;
        
        // 这里拼接  AVCC  拼进去  sps  pps
        
        unsigned char avccHeader[7]={0x01,0x64,0x00,0x28,0xFF,0xE1,0x00};
        int hLen=sizeof(avccHeader);
        memcpy(avcCBytes, avccHeader, hLen);
        
        avcCBytes[hLen]=spsLen;
        
        memcpy(avcCBytes+hLen+1, m_avcCBox.spsBuffer, spsLen);   //
        avcCBytes[spsLen+hLen+1]=0x01;
        avcCBytes[spsLen+hLen+2]=0x00;
        avcCBytes[spsLen+hLen+3]=ppsLen;
        memcpy(avcCBytes+spsLen+hLen+4, m_avcCBox.ppsBuffer, ppsLen);
        
        int avccLen=spsLen+ppsLen+hLen+4;
        
        pCodecContext->extradata=avcCBytes;
        pCodecContext->extradata_size=avccLen;
        
    }
    
    
    
    //pCodecContext->bit_rate=400000;
    pCodecContext->time_base.num = 1;
    pCodecContext->time_base.den = m_nFrameRate;
    
    pCodecContext->width = m_nWidth;
    pCodecContext->height = m_nHeight;
    
    //pCodecContext->bit_rate = 4 * m_nWidth * m_nHeight;
    
    pCodecContext->gop_size = 12;
    
    pCodecContext->pix_fmt = PIX_FMT_YUV420P;
    
    if (pCodecContext->codec_id == CODEC_ID_MPEG2VIDEO)
    {
        pCodecContext->max_b_frames = 2;
    }
    else if (pCodecContext->codec_id == CODEC_ID_MPEG1VIDEO)
    {
        pCodecContext->mb_decision = 2;
    }
    
    if (m_pFormatCtx->oformat->flags & AVFMT_GLOBALHEADER)
    {
        pCodecContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
    }
    
    return pOutputStream;
}


-(AVStream*) initAudioContextInfo
{
    
    AVStream* pOutputStream = avformat_new_stream(m_pFormatCtx,0);
    if (pOutputStream == NULL)
    {
        return NULL;
    }
    
    //PTS：Presentation Time Stamp。PTS主要用于度量解码后的音频帧什么时候被显示出来
    pOutputStream->id = m_pFormatCtx->nb_streams - 1;
    pOutputStream->pts.val = 0;
    pOutputStream->pts.num = 1;
    pOutputStream->pts.den = 1000;
    
    //time_base的意思就是时间的刻度：如（1,25），那么时间刻度就是1/25
    pOutputStream->time_base.num = 1;
    pOutputStream->time_base.den = 1000;
    
    //sample_aspect_ratio视频的宽高比
    //pOutputStream->sample_aspect_ratio.num = 1;
    //pOutputStream->sample_aspect_ratio.den = 1;
    
    pOutputStream->discard = AVDISCARD_NONE;
    
    AVCodecContext *pCodecContext = pOutputStream->codec;
    pCodecContext->codec_id = CODEC_ID_AAC;
    pCodecContext->codec_type = AVMEDIA_TYPE_AUDIO;
    pCodecContext->bit_rate    = 8000;
    pCodecContext->sample_rate = 8000;
    pCodecContext->channels    = 1;
    pCodecContext->sample_fmt  = AV_SAMPLE_FMT_S16;
    pCodecContext->profile=FF_PROFILE_AAC_LOW;
    pCodecContext->channel_layout=AV_CH_LAYOUT_MONO; // 立体声
    pCodecContext->block_align  = 1;
    pCodecContext->time_base.num = 1;
    pCodecContext->time_base.den = 1000;
    //
    pCodecContext->frame_size=(int)(g_aacEncodeConfig->nInputSamples*(g_aacEncodeConfig->nPCMBitSize/8));
    
    unsigned char indexBuffer[2]={0};
    
    unsigned int sampleIndex=[self getSampleIndex:8000];
    
    [self getIndexConfigure:sampleIndex channels:(unsigned int)1 withEsdsBuff:indexBuffer];
    
    pCodecContext->extradata_size = sizeof(indexBuffer);  // 大小
    pCodecContext->extradata = (uint8_t*)malloc(2);  // 申请内存
    memcpy(pCodecContext->extradata, indexBuffer,2); // 拷贝    这里要多写两个字节
    
    if (m_pFormatCtx->oformat->flags & AVFMT_GLOBALHEADER)
    {
        pCodecContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
    }
    
    return pOutputStream;
}
-(void)getIndexConfigure:(unsigned int)aSample channels:(unsigned int)aChannels withEsdsBuff: (unsigned char*)indexBuff
{
    unsigned int object_type = 2;
    
    indexBuff[0] = (object_type<<3) | (aSample>>1);
    
    indexBuff[1] = ((aChannels&1)<<7) | (aChannels<<3);
    
}
-(int)getSampleIndex:(unsigned int)aSamples
{
    switch(aSamples){
        case 96000: return 0;
        case 88200: return 1;
        case 64000: return 2;
        case 48000: return 3;
        case 44100: return 4;
        case 32000: return 5;
        case 24000: return 6;
        case 22050: return 7;
        case 16000: return 8;
        case 12000: return 9;
        case 11025: return 10;
        case 8000:  return 11;
        case 7350:  return 12;
        default:    return 0;
    }
    
}

- (bool)initRecordInfo
{
    if (m_pFormatCtx == NULL)
    {
        m_pFormatCtx = avformat_alloc_context();
        
        m_pFormatCtx->oformat = av_guess_format("mov", NULL, NULL);
    }
    
    //初始化视频
    if (m_pVideoSt != NULL)
    {
        return true;
    }
    m_pVideoSt = [self initVideoContextInfo];
    
    
    //初始化音频，仅支持MEDIA_CODEC_AUDIO_PCM.
    if (m_pAudioSt != NULL)
    {
        return true;
    }
    
    m_pAudioSt = [self initAudioContextInfo];
    
    return [self initVideoHeader];
}

- (bool)initVideoHeader
{
    [self ResetRecordInfo];
    
    if (![self startRecordFileWithPath])
    {
        m_bRecord = false;
        
        NSLog(@"Call update record file function failed.");
        
        return false;
    }
    const char* movieUrl=[m_strRecordFile cStringUsingEncoding:NSUTF8StringEncoding];
    if (avio_open(&m_pFormatCtx->pb, movieUrl, AVIO_FLAG_WRITE) != 0)
    {
        m_bRecord = false;
        
        NSLog(@"Call avio_open function failed.");
        
        return false;
    }
    
    if (avformat_write_header(m_pFormatCtx, NULL) != 0)
    {
        m_bRecord = false;
        
        NSLog(@"Call avformat_write_header function failed.");
        
        return false;
    }
    
    return true;
}

-(void)ResetRecordInfo
{
    m_nFileTotalSize = 0;
    memset(&m_stFrameInfo, 0, sizeof(m_stFrameInfo));
    memset(&m_stAudioInfo, 0, sizeof(m_stAudioInfo));
}





- (void)writeFrameData: (unsigned char *)pszData withSize: (int)aSize
{
    if (!m_bRecord)
    {
        return;
    }
    if(aSize<=4){
        return;
    }
    
    
    MP4ENC_NaluUnit nalu;
    memset(&nalu, 0, sizeof(nalu));
    
    int  len = 0;
    int pos = 0;
    
    
    memset(&m_avcCBox, 0, sizeof(m_avcCBox));
    memset(m_avcCBox.ppsBuffer, 0, sizeof(m_avcCBox.ppsBuffer));
    memset(m_avcCBox.spsBuffer, 0, sizeof(m_avcCBox.spsBuffer));
    
    
    while ((len = [self readOneNaluFromBuffer:pszData withSize:aSize withOffSet:pos nalUnit: &nalu]))
    {
        if(nalu.type==0x07)//SPS
        {
            if(nalu.size>0){
                memcpy(m_avcCBox.spsBuffer, nalu.data, nalu.size);
                m_avcCBox.sps_length=nalu.size;
            }
            firstIFrame_states = 1;
        }
        
        if(nalu.type==0x08)//PPS
        {
            if(nalu.size>0){
                memcpy(m_avcCBox.ppsBuffer, nalu.data, nalu.size);
                m_avcCBox.pps_length=nalu.size;
            }
        }
        
        if(firstIFrame_states!=1){
            printf("NO_SPS_RETURN: \n");//获取第一个I帧. 否则就直接返回.
            startTimeStamp=[self _GetTickCount];
            pos += len;
            continue ;
        }
        
        if(nalu.type == 0x05) //i帧    读取第一个I帧，否则会有1秒的时间是花屏的
        {
            FrameData *pFrameData=(FrameData *)malloc(sizeof(FrameData));
            memset(pFrameData, 0, sizeof(FrameData));
            
            int datalen = nalu.size+4;
            unsigned char *pData =(unsigned char *) malloc( datalen * sizeof(unsigned char));
            // MP4 Nalu前四个字节表示Nalu长度
            pData[0] = nalu.size>>24;
            pData[1] = nalu.size>>16;
            pData[2] = nalu.size>>8;
            pData[3] = nalu.size&0xff;
            memcpy(pData+4,nalu.data,nalu.size);
            
            
            
            
            pFrameData->m_nSize = datalen;
            memcpy(pFrameData->m_pszData, pData, datalen);
            
            
            
            pFrameData->m_nCodecID = CODEC_ID_H264;
            pFrameData->m_nTimestamp = [self _GetTickCount]-startTimeStamp;
            
            
            [self WriteVideoSt:pFrameData withKeyFlags:1];   // 1是关键帧  I帧
            
            free(pFrameData);
            
            free(pData);
            
        }
        else if(nalu.type == 0x01)//  P帧，或者 B帧
        {
            FrameData *pFrameData=(FrameData *)malloc(sizeof(FrameData));
            memset(pFrameData, 0, sizeof(FrameData));
            
            int datalen = nalu.size+4;
            unsigned char *pData =(unsigned char *) malloc( datalen * sizeof(unsigned char));
            // MP4 Nalu前四个字节表示Nalu长度
            pData[0] = nalu.size>>24;
            pData[1] = nalu.size>>16;
            pData[2] = nalu.size>>8;
            pData[3] = nalu.size&0xff;
            memcpy(pData+4,nalu.data,nalu.size);
            
            
            
            
            pFrameData->m_nSize = datalen;
            memcpy(pFrameData->m_pszData, pData, datalen);
            
            
            
            pFrameData->m_nCodecID = CODEC_ID_H264;
            pFrameData->m_nTimestamp = [self _GetTickCount]-startTimeStamp;
            
            
            [self WriteVideoSt:pFrameData withKeyFlags:0];    // 1是关键帧  I帧  0是非关键帧 BP帧
            
            free(pFrameData);
            
            free(pData);
            
        }
        pos += len;
        
    }
    
    
}

- (void)writeListenData: (unsigned char *)pszData withSize: (int)aSize
{
    if (!m_bRecord)
    {
        return;
    }
    if(startRecord_states==1)
    {//视频开始，才开始录制音频
        [self linearPCM2AAC:pszData withSize:aSize];
    }
}


- (int)readOneNaluFromBuffer: (const unsigned char*)buffer withSize: (unsigned int)nBufferSize withOffSet :(unsigned int)aOffSet nalUnit: (MP4ENC_NaluUnit *)nalu
{
    
    int i = aOffSet;
    while(i<nBufferSize)
    {
        if(buffer[i++] == 0x00 &&buffer[i++] == 0x00 &&buffer[i++] == 0x00 &&buffer[i++] == 0x01)
        {
            int pos = i;
            while (pos<nBufferSize)
            {
                if(buffer[pos++] == 0x00 &&buffer[pos++] == 0x00 &&buffer[pos++] == 0x00 &&buffer[pos++] == 0x01)
                {
                    break;
                }
            }
            if(pos == nBufferSize)
            {
                nalu->size = pos-i;
            }
            else
            {
                nalu->size = (pos-4)-i;
            }
            
            nalu->type = buffer[i]&0x1f;
            nalu->data =(unsigned char*)&buffer[i];
            return (nalu->size+i-aOffSet);
        }
    }
    return 0;
}


- (bool)WriteVideoSt : (FrameData*)pData withKeyFlags: (int)keyFlags
{
    
    if (!m_bRecord)
    {
        return false;
    }
    
    if(![self initRecordInfo])
    {
        return false;
    }
    startRecord_states=1;
    //printf("write video st------------->>>>>\n");
    
    AVPacket packet;
    av_init_packet(&packet);
    
    AVRational time_base;
    time_base.num = 1;
    time_base.den = 1000;
    
    if (m_stFrameInfo.m_nLastTimestamp == 0)
    {
        m_stFrameInfo.m_nLastTimestamp = pData->m_nTimestamp;
    }
    
    packet.stream_index = m_pVideoSt->index;
    
    packet.duration = pData->m_nTimestamp - m_stFrameInfo.m_nLastTimestamp;
    
    if(packet.duration<=0){
        printf("vudio duration<=0:::::: %d\n",packet.duration);
        packet.duration=1;
    }
    
    m_stFrameInfo.m_nTotalTime += packet.duration;
    
    m_stFrameInfo.m_nLastTimestamp = pData->m_nTimestamp;
    
    int curPts = av_rescale_q(m_stFrameInfo.m_nTotalTime, time_base, m_pVideoSt->time_base);
    if (m_stFrameInfo.m_nCurPts >= curPts && curPts != 0)
    {
        return true;
    }
    
    m_stFrameInfo.m_nCurPts = curPts;
    
    m_stFrameInfo.m_dCurTime = ((double)m_pVideoSt->pts.val * m_pVideoSt->time_base.num) / m_pVideoSt->time_base.den;
    
    packet.size = pData->m_nSize;
    
    packet.data = (uint8_t *)pData->m_pszData;
    
    packet.dts = packet.pts = m_stFrameInfo.m_nCurPts;
    packet.flags |=(keyFlags>0)?AV_PKT_FLAG_KEY:0;    // 关键帧  I帧，   0是 非关键  BP帧
    
    
    [videoLock lock];
    int ret = av_interleaved_write_frame(m_pFormatCtx, &packet);
    [videoLock unlock];
    if (ret < 0)
    {
        NSLog(@"Call av_write_frame function failed, codecid:%d, size:%d, dts:%lld, duration:%d, return:%d.",
              pData->m_nCodecID, packet.size, packet.dts, packet.duration, ret);
        
        av_free_packet(&packet);
        
        return false;
    }
    
    m_nFileTotalSize += packet.size;
    
    av_free_packet(&packet);
    
    return true;
    
    
    
}

- (bool)WriteAudioSt: (AudioData*)pData
{
    
    if (!m_bRecord)  // 视频优先于音频录制，早1，2秒
    {
        return false;
    }
    
    if (m_pAudioSt == NULL || pData == NULL)
    {
        return false;
    }
    //printf("write audio st------------->>>>>\n");
    AVPacket packet;
    av_init_packet(&packet);
    
    AVRational time_base;
    time_base.num = 1;
    time_base.den = 1000;
    
    if (m_stAudioInfo.m_nLastTimestamp == 0)
    {
        m_stAudioInfo.m_nLastTimestamp = pData->m_nTimestamp;
        
    }
    
    
    packet.stream_index = m_pAudioSt->index;
    
    // 视频当前时间  减去 上一帧时间
    packet.duration = pData->m_nTimestamp - m_stAudioInfo.m_nLastTimestamp;
    if(packet.duration<=0){
        printf("audio duration<=0:::::: %d\n",packet.duration);
        packet.duration=1;
    }
    m_stAudioInfo.m_nTotalTime += packet.duration;
    
    m_stAudioInfo.m_nLastTimestamp = pData->m_nTimestamp;
    
    int curPts = av_rescale_q(m_stAudioInfo.m_nTotalTime, time_base, m_pAudioSt->time_base);
    if (m_stAudioInfo.m_nCurPts >= curPts && curPts != 0)
    {
        return true;
    }
    
    m_stAudioInfo.m_nCurPts = curPts;
    m_stAudioInfo.m_dCurTime = ((double)m_pAudioSt->pts.val * m_pAudioSt->time_base.num) / m_pAudioSt->time_base.den;
    
    packet.size = pData->m_nSize;
    
    packet.data = (uint8_t *)pData->m_pszData;
    
    // dts 解密时间   pts 显示时间
    packet.dts = packet.pts = m_stAudioInfo.m_nCurPts;
    
    [videoLock lock];
    int ret = av_interleaved_write_frame(m_pFormatCtx, &packet);
    [videoLock unlock];
    
    if (ret < 0)
    {
        NSLog(@"Call av_write_frame function failed, codecid:%d, size:%d, dts:%lld, duration:%d, return:%d.",
              pData->m_nCodecID, packet.size, packet.dts, packet.duration, ret);
        
        av_free_packet(&packet);
        
        return false;
    }
    
    m_nFileTotalSize += packet.size;
    
    av_free_packet(&packet);
    
    return true;
    
}




-(int)linearPCM2AAC: (unsigned char *)pData withSize: (int)aSize
{
    int aacBuffSize = (int)(g_aacEncodeConfig->nInputSamples*(g_aacEncodeConfig->nPCMBitSize/8));
    
    if(pData==NULL){
        return -1;
    }
    if((aSize>aacBuffSize)||(aSize<=0)){
        return -1;
    }
    
    int nRet = 0;
    int copyLength = 0;
    
    if(g_bufferRemainSize > aSize){
        copyLength = aSize;
    }
    else{
        copyLength = g_bufferRemainSize;
    }
    
    memcpy((&g_aacEncodeConfig->pcmBuffer[0]) + g_writeRemainSize, pData, copyLength);
    g_bufferRemainSize -= copyLength;
    g_writeRemainSize += copyLength;
    
    if(g_bufferRemainSize > 0){
        return 0;
    }
    
    
    nRet = faacEncEncode(g_aacEncodeConfig->hEncoder,(int*)(g_aacEncodeConfig->pcmBuffer),g_aacEncodeConfig->nInputSamples,g_aacEncodeConfig->aacBuffer,g_aacEncodeConfig->nMaxOutputBytes);
    
    memset(g_aacEncodeConfig->pcmBuffer, 0, aacBuffSize);
    g_writeRemainSize = 0;
    g_bufferRemainSize = aacBuffSize;
    
    
    AudioData *pAudioData=(AudioData *)malloc(sizeof(AudioData));
    memset(pAudioData, 0, sizeof(AudioData));
    
    pAudioData->m_nSize = nRet;
    memcpy(pAudioData->m_pszData, g_aacEncodeConfig->aacBuffer, nRet);
    
    pAudioData->m_nCodecID = CODEC_ID_AAC;
    pAudioData->m_nTimestamp = [self _GetTickCount]-startTimeStamp;;
    
    [self WriteAudioSt:pAudioData];
    
    free(pAudioData);
    
    memset(g_aacEncodeConfig->pcmBuffer, 0, aacBuffSize);
    if((aSize - copyLength) > 0 ){
        memcpy((&g_aacEncodeConfig->pcmBuffer[0]), pData+copyLength, aSize - copyLength);
        g_writeRemainSize = aSize - copyLength;
        g_bufferRemainSize = aacBuffSize - (aSize - copyLength);
    }
    
    return nRet;
    
}


-( unsigned long) _GetTickCount
{
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec*1000  + tv.tv_usec / 1000);
}



@end
