//
//  Camera.m
//  IOTCamViewer
//
//  Created by chenchao on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <sys/time.h>
#import <pthread.h>
#import "IOTCAPIs.h"
#import "Camera.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "adpcm.h"



#import "AVFrameInfo.h"


#import "OpenALPlayer.h"
#import "Mp4VideoRecorder.h"
#import "sys/utsname.h"
#include "g711.h"


pthread_mutex_t  iotc_locker=PTHREAD_MUTEX_INITIALIZER;

@implementation Camera



@synthesize             name;
@synthesize             uid;
@synthesize             viewAcc;
@synthesize             viewPwd;

@synthesize             connectionState;

@synthesize             sessionState;
@synthesize             remoteNotifications;
@synthesize             bIsSupportTimeZone;
@synthesize             nGMTDiff;

@synthesize             updatingYUVFrame;
@synthesize             isRunningRecvAudioThread;
@synthesize             isRunningRecvVideoThread;
@synthesize             isRunningSendIOCtrlThread;
@synthesize             isRunningRecvIOCtrlThread;

@synthesize             isRunningCheckingThread;

//回放通道
@synthesize             isRunningRecvAudioThread_P;
@synthesize             isRunningRecvVideoThread_P;



@synthesize             cameraDelegate;




- (id)initWithUID:(NSString*)uid_ camName:(NSString *)name_ viewAccount:(NSString *)viewAcc_ viewPassword:(NSString *)viewPwd_;
{
    
    if (self= [super init])
    {
        self.uid=uid_;
        self.name = name_;
        self.viewAcc=viewAcc_;
        self.viewPwd=viewPwd_;
        
        sessionID               =-1;
        sessionMode             =-1;
        sessionState            =-1;
        sessionID4ConnStop      =-1;
        
        audioCodec              =-1;
        nAvResend               =-1;
        avIndex                 =-1;
        
        avChannel               =0;
        
        connFailErrCode         =0;
        connectionState         =0; //连接状态.
        chIndexForSendAudio     =0; //发送Audio通道。
        avIndexForSendAudio     =0; //sendAudio index
        
        
        isRunningRecvVideoThread        =FALSE;
        isRunningSendIOCtrlThread       =FALSE;
        isRunningRecvIOCtrlThread       =FALSE;
        isConnectingServer              =FALSE;
        isRunningSendAudio              =FALSE;
        
        
        
        ioCtrlMsgQueue=[[SendIOCtrlMsgQueue alloc] init];
        
        
        //回放通道
        
        avChannel_P             =-1;
        nAvResend_P             =-1;
        avIndex_P               =-1;
        
        connectionState_P       =-1;
        
        isRunningRecvAudioThread_P      =FALSE;
        isRunningRecvVideoThread_P      =FALSE;
        
        
        recorder=nil;
        
        
        avIndex_Locker=[[NSLock alloc] init];
        
        NSLog(@"INIT::::: %@ %@ %@ %@",self.uid,self.name,self.viewAcc,self.viewPwd);
 
    }
    
    return self;
}



- (void)dealloc
{

    printf("CAMERAL DEALLOC: \n\n");
    
    cameraDelegate = nil;
    
    [self.uid release];
    [self.name release];
    [self.viewAcc release];
    [self.viewPwd release];
    
    [ioCtrlMsgQueue release];
    [avIndex_Locker release];

    
    [super dealloc];
}


#pragma mark - Common method
unsigned int _getTickCount() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

unsigned int _getTickCount_() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000000 + tv.tv_usec);
}

- (int)_getSampleRate:(unsigned char)flag {
        
    switch(flag >> 2) {
            
        case AUDIO_SAMPLE_8K:
            return 8000;
            break;
            
        case AUDIO_SAMPLE_11K:
            return 11025;
            break;
            
        case AUDIO_SAMPLE_12K:
            return 12000;
            break;
            
        case AUDIO_SAMPLE_16K:
            return 16000;
            break;
            
        case AUDIO_SAMPLE_22K:
            return 22050;
            break;
            
        case AUDIO_SAMPLE_24K:
            return 24000;
            break;
            
        case AUDIO_SAMPLE_32K:
            return 32000;
            break;
            
        case AUDIO_SAMPLE_44K:
            return 44100;
            break;
            
        case AUDIO_SAMPLE_48K:
            return 48000;
            break;
            
        default:
            return 8000;
    }
}

- (NSString *) _getHexString:(char *)buff Size:(int)size 
{    
    int i = 0;
    char *ptr = buff;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    while(i++ < size) [str appendFormat:@"%02X ", *ptr++ & 0x00FF];
    
    return [str autorelease];
}

-(BOOL)dataIsValidJPEG:(NSData *)data
{
    if (!data || data.length < 2) return NO;
    
    NSInteger totalBytes = data.length;
    const char *bytes = (const char*)[data bytes];
    
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8 &&
            bytes[totalBytes-2] == (char)0xff &&
            bytes[totalBytes-1] == (char)0xd9);
}



- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0];
    }
    
    return [[documentsPath stringByAppendingPathComponent:relativePath] retain];
}

- (NSString *) parseIOTCAPIsVerion:(long)version
{
    char cIOTCVer[4];
    
    cIOTCVer[3] = (char)version;
    cIOTCVer[2] = (char)(version >> 8);
    cIOTCVer[1] = (char)(version >> 16);
    cIOTCVer[0] = (char)(version >> 24);
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cIOTCVer[0], cIOTCVer[1], cIOTCVer[2], cIOTCVer[3]];
}

#pragma mark - Public methods


- (NSString *)getViewAccount
{
    return nil;
}

- (NSString *)getViewPassword
{

    return nil;
}

- (unsigned long)getServiceType
{

    return 0xFFFFFFFF;
}

- (NSInteger)getConnectionState
{
    return connectionState;
}
- (void)setConnectionState:(NSInteger)state_
{
    connectionState=state_;
}
#pragma mark - IOTCApis Methods
	
+ (void)initIOTC 
{


    pthread_mutex_lock(&iotc_locker);
    unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
    int ret = -1;
    
    //ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
    //ret = IOTC_Initialize2(0);
    ret=IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "46.137.188.54", "122.226.84.253");
    
    if (ret < 0)
    {
        NSLog(@"IOTC_Initialize2() failed -> %d", ret);
    }
    
    avInitialize(160);
    NSLog(@"\n\n=======avInitialize=====================\n\n");
    pthread_mutex_unlock(&iotc_locker);

}

+ (void)uninitIOTC 
{

    pthread_mutex_lock(&iotc_locker);
    avDeInitialize();
    NSLog(@"\n\n===============avDeInitialize===========");
    IOTC_DeInitialize();
    NSLog(@"=======IOTC_DeInitialize=====================\n\n");
    pthread_mutex_unlock(&iotc_locker);



}

+ (NSString *) getIOTCAPIsVerion
{    
    unsigned long ulIOTCVer;            
    char cIOTCVer[4];
    
    IOTC_Get_Version(&ulIOTCVer);
    cIOTCVer[3] = (char)ulIOTCVer;
    cIOTCVer[2] = (char)(ulIOTCVer >> 8);
    cIOTCVer[1] = (char)(ulIOTCVer >> 16);
    cIOTCVer[0] = (char)(ulIOTCVer >> 24);
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cIOTCVer[0], cIOTCVer[1], cIOTCVer[2], cIOTCVer[3]];
}

+ (NSString *) getAVAPIsVersion 
{    
    int nAVAPIVer;
    char cAVAPIVer[4];
    
    nAVAPIVer = avGetAVApiVer();
    cAVAPIVer[3] = (char)nAVAPIVer;
    cAVAPIVer[2] = (char)(nAVAPIVer >> 8);
    cAVAPIVer[1] = (char)(nAVAPIVer >> 16);
    cAVAPIVer[0] = (char)(nAVAPIVer >> 24);
	    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cAVAPIVer[0], cAVAPIVer[1], cAVAPIVer[2], cAVAPIVer[3]];
}



- (void)setRemoteNotification:(NSInteger)type EventTime:(long)time
{
    self.remoteNotifications++;
    if(self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:updateRemoteNotifications:EventTime:)])
    {
        [self.cameraDelegate camera:self updateRemoteNotifications:type EventTime:time];
        NSLog(@"remoteNotifications:%d", self.remoteNotifications);
    }

}

- (NSString*)getOverAllQualityString
{
	NSString* result = nil;
	
	return result;
}

+ (NSString*) getConnModeString:(NSInteger)connMode
{
	NSString* result = nil;
	
	switch(connMode) {
		case CONNECTION_MODE_P2P:
			result = @"P2P";
			break;
		case CONNECTION_MODE_RELAY:
			result = @"Relay";
			break;
		case CONNECTION_MODE_LAN:
			result = @"Lan";
			break;
		default:
			result = @"None";
			break;
	}
	return result;
}

+ (LanSearch_t *)LanSearch:(int *)num timeout:(int)timeoutVal
{

	int nMaxCount = 32;
	LanSearch_t* pResult = malloc(sizeof(LanSearch_t)*nMaxCount);
	
	memset( pResult, 0, sizeof(LanSearch_t)*nMaxCount );
	
	*num = IOTC_Lan_Search( pResult, nMaxCount, timeoutVal );
	
	return pResult;
}


- (void)connect
{
    
    [NSThread detachNewThreadSelector:@selector(doStartThread) toTarget:self withObject:nil];
}

//关闭Session下通道.
- (void)stopConnectedSession
{
    
    
    isRunningSendIOCtrlThread=FALSE;
    isRunningRecvIOCtrlThread=FALSE;
    
    sessionState = CONNECTION_STATE_CONNECT_FAILED;
    
    if(avIndex>=0)
    {
        avClientStop(avIndex);
        avIndex=-1;
    }
    
    if (sessionID4ConnStop >= 0)
    {
        IOTC_Connect_Stop_BySID(sessionID4ConnStop);
        sessionID4ConnStop=-1;
    }
    
    if (sessionID >= 0)
    {
        
        IOTC_Session_Close(sessionID);
        sessionID = -1;
    }
    
    
    
}
//退出Session下通道,断开通道连接.
- (void)exitConnectedSession
{
    
    
    isRunningSendIOCtrlThread=FALSE;
    isRunningRecvIOCtrlThread=FALSE;
    
    sessionState = CONNECTION_STATE_CONNECT_FAILED;
    
    if(avIndex>=0)
    {
        avSendIOCtrlExit(avIndex);
        
        avClientStop(avIndex);
        
        avClientExit(sessionID, avChannel);
        
        avChannel=-1;
        avIndex=-1;
    }
    
    if (sessionID4ConnStop >= 0)
    {
        IOTC_Connect_Stop_BySID(sessionID4ConnStop);
        sessionID4ConnStop=-1;
    }
    
    if (sessionID >= 0)
    {
        
        IOTC_Session_Close(sessionID);
        sessionID = -1;
    }
    
    
}




- (Boolean)isConnecting
{

    return (isConnectingServer);
}

- (void)startShow
{    	
    int camIndex = 0;
    
    [self sendIOCtrl:IOTYPE_INNER_SND_DATA_DELAY Data:(char *)&camIndex DataSize:4];
    
    [self sendIOCtrl:IOTYPE_USER_IPCAM_START Data:(char *)&camIndex DataSize:4];
    

    isRunningRecvVideoThread=TRUE;
    updatingYUVFrame=TRUE;
    [NSThread detachNewThreadSelector:@selector(doRecvVideo) toTarget:self withObject:nil];
    
    
}


- (void)stopShow
{
    isRunningRecvVideoThread=FALSE;
    updatingYUVFrame=FALSE;

    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_STOP Data:(char *)&camIndex DataSize:4];

}

- (void)startSoundToPhone
{
        
    
    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_AUDIOSTART Data:(char *)&camIndex DataSize:4];
    
    isRunningRecvAudioThread = TRUE;
    
    [NSThread detachNewThreadSelector:@selector(doRecvAudio) toTarget:self withObject:nil];

    
}

- (void)stopSoundToPhone{
    
    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_AUDIOSTOP Data:(char *)&camIndex DataSize:4];
    isRunningRecvAudioThread = FALSE;
  
}

- (void)startSoundToDevice
{
    if(!isRunningSendAudio)
    {
        [NSThread detachNewThreadSelector:@selector(doSendAudio) toTarget:self withObject:nil];
    }
}

- (void)stopSoundToDevice
{


    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_SPEAKERSTOP Data:(char *)&camIndex DataSize:4];
    
    
    if(isRunningSendAudio)
    {
        if(recorder!=nil)
        {
            [recorder stop];
            [recorder release];
            recorder = nil;
        }
        
        if (avIndexForSendAudio >= 0)
        {
            avServStop(avIndexForSendAudio);
        }
        
        if (chIndexForSendAudio >= 0)
        {
            IOTC_Session_Channel_OFF(sessionID, chIndexForSendAudio);
        }
        
        chIndexForSendAudio = -1;
        avIndexForSendAudio = -1;
        isRunningSendAudio=FALSE;
    }


 


}

#pragma mark - Threading

- (void)doStartThread
{

    int reConnectCount=0;
    
RECONNECT_POINT:
    
    isConnectingServer=TRUE;
    
    int serverType = 0;
    NSInteger sid = -1;
    

    if(sessionID < 0)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sessionState = CONNECTION_STATE_CONNECTING;
            connectionState = CONNECTION_STATE_CONNECTING;
            if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectSessionStates:)])
                [self.cameraDelegate camera:self connect_updateConnectSessionStates:CONNECTION_STATE_CONNECTING];
            
        });
        

		sessionID4ConnStop = IOTC_Get_SessionID();

        

        char* buffer=(char*)malloc(sizeof(char)*20);
        memcpy(buffer, [self.uid UTF8String], 20);

		sid = IOTC_Connect_ByUID_Parallel(buffer, sessionID4ConnStop);
        
        printf("!!!!!!!!!!!!!!!!!!!!!!!!!!sessionID4ConnStop: %d SID: %d  BUffer: %s\n",sessionID4ConnStop,sid,buffer);

        if (sid >= 0)
        {
            sessionID = sid;
            
            struct st_SInfo Sinfo;
            int ret;
            
            ret = IOTC_Session_Check(sid, &Sinfo);
            
            if(Sinfo.Mode == 0){
 				sessionMode = CONNECTION_MODE_P2P;
            }
            else if(Sinfo.Mode == 1){
 				sessionMode = CONNECTION_MODE_RELAY;
            }
            else if(Sinfo.Mode == 2){
 				sessionMode = CONNECTION_MODE_LAN;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sessionState = CONNECTION_STATE_CONNECTED;
				            
                if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectSessionStates:)])
                    [self.cameraDelegate camera:self connect_updateConnectSessionStates:CONNECTION_STATE_CONNECTED];
            });
            
        }
        else if (sid == IOTC_ER_UNLICENSE || sid == IOTC_ER_UNKNOWN_DEVICE || sid == IOTC_ER_CAN_NOT_FIND_DEVICE)
        {
			connFailErrCode = sid;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    
                sessionState = CONNECTION_STATE_UNKNOWN_DEVICE;
                connectionState = CONNECTION_STATE_UNKNOWN_DEVICE;
                NSLog(@"%@ session: CONNECTION_STATE_UNKNOWN_DEVICE", uid );

                if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectSessionStates:)])
                    [self.cameraDelegate camera:self connect_updateConnectSessionStates:CONNECTION_STATE_UNKNOWN_DEVICE];
            });
            
        }
        else if (sid == IOTC_ER_TIMEOUT)
        {
			connFailErrCode = sid;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sessionState = CONNECTION_STATE_TIMEOUT;
                connectionState = CONNECTION_STATE_TIMEOUT;
                NSLog(@"%@ session: CONNECTION_STATE_TIMEOUT", uid);

                if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectSessionStates:)])
                    [self.cameraDelegate camera:self connect_updateConnectSessionStates:CONNECTION_STATE_TIMEOUT];
            });
            
        }
        else if (sid == IOTC_ER_CONNECT_IS_CALLING)
        {
 			connFailErrCode = sid;
            connectionState = CONNECTION_STATE_CONNECT_FAILED;
        }
        else
        { 
 			connFailErrCode = sid;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                         
                sessionState = CONNECTION_STATE_CONNECT_FAILED;
                connectionState = CONNECTION_STATE_CONNECT_FAILED;
                NSLog(@"%@ session: CONNECTION_STATE_CONNECT_FAILED", uid);

                if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectSessionStates:)])
                    [self.cameraDelegate camera:self connect_updateConnectSessionStates:CONNECTION_STATE_CONNECT_FAILED];
            });
        }
        
        if(buffer!=NULL)
        {
            free(buffer);
        }
        
    }
    
    if(sessionID>=0)
    {

        if (avIndex < 0)
        {
            
            NSLog(@"SesionID %d AccountName: %@ Password: %@\n\n",sessionID,viewAcc,viewPwd);
            avIndex = avClientStart2(sessionID, (char *)[viewAcc UTF8String], (char *)[viewPwd UTF8String], 30, (unsigned long *)&serverType, avChannel, &nAvResend);
            
            NSLog(@" SID:%@ %d %d %d\n",self.name, connectionState,sessionState,avIndex);
            if (avIndex >= 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    connectionState = CONNECTION_STATE_CONNECTED;
                    
                    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectIndex4SessionStates:)])
                        [self.cameraDelegate camera:self connect_updateConnectIndex4SessionStates:CONNECTION_STATE_CONNECTED];
                });
                
            } else if (avIndex == AV_ER_WRONG_VIEWACCorPWD)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    connectionState = CONNECTION_STATE_WRONG_PASSWORD;
                    
                    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectIndex4SessionStates:)])
                        [self.cameraDelegate camera:self connect_updateConnectIndex4SessionStates:CONNECTION_STATE_WRONG_PASSWORD];
                });
                
                
            } else if (avIndex == AV_ER_REMOTE_TIMEOUT_DISCONNECT || avIndex == AV_ER_TIMEOUT)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    connectionState = CONNECTION_STATE_TIMEOUT;
                    
                    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:connect_updateConnectIndex4SessionStates:)])
                        [self.cameraDelegate camera:self connect_updateConnectIndex4SessionStates:CONNECTION_STATE_TIMEOUT];
                });
                
            }
            
        }
        
        
        
    }
    else
    {
        //session id<=0;
    }
    
    //发送接受Msg线程.
    if((sessionID>=0)&&(avIndex>=0))
    {
        isRunningSendIOCtrlThread=TRUE;
        isRunningRecvIOCtrlThread=TRUE;
        
        [NSThread detachNewThreadSelector:@selector(sendIOCtrlFromMsgQueueThread) toTarget:self withObject:nil];
        
        [NSThread detachNewThreadSelector:@selector(recvIOCtrlFromDeviceThread) toTarget:self withObject:nil];
    }
    else if((sessionID<0)||(avIndex<0))
    {
        if(reConnectCount++<3)
        {
                goto RECONNECT_POINT;
        }

    }
    
    isConnectingServer=FALSE;
    

}

- (void)doCheckStatusThread
{
    

    int ret = -1;
    struct st_SInfo* info = malloc(sizeof(struct st_SInfo));
    

    if(sessionID>=0)
    {
        NSLog(@"=== Check Status Thread ===  (%@)", name);
        ret = IOTC_Session_Check(sessionID, info);
        
        sessionMode = info->Mode;
        
        
        if (ret >= 0)
        {
            sessionState = CONNECTION_STATE_CONNECTED;
            connectionState=CONNECTION_STATE_CONNECTED;
        }
        else 
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sessionState = CONNECTION_STATE_CONNECT_FAILED;
                connectionState = CONNECTION_STATE_CONNECT_FAILED;

                if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:checkStatus_reConnectSesssion:)])
                    [self.cameraDelegate camera:self checkStatus_reConnectSesssion:CONNECTION_STATE_CONNECT_FAILED];
            });

        }

    }
    else if(sessionID<0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sessionState = CONNECTION_STATE_CONNECT_FAILED;
            connectionState = CONNECTION_STATE_CONNECT_FAILED;
            
            if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:checkStatus_reConnectSesssion:)])
                [self.cameraDelegate camera:self checkStatus_reConnectSesssion:CONNECTION_STATE_CONNECT_FAILED];
        });
    }
    
    
    free(info);
    isConnectingServer=FALSE;
    
    

}


- (void)doRecvVideo
{

    
    int readSize = -1;
    char *recvBuf = malloc(RECV_VIDEO_BUFFER_SIZE);
    
    FRAMEINFO_t frmInfo = {0};
    unsigned int frmNo = 0,prevFrmNo=0x0FFFFFFF;


    int outBufSize = 0, outFrmSize = 0, outFrmInfoSize = 0;

    H264Decoder*     decoder=[[H264Decoder alloc] init];
    decoder.updateDelegate=self;
    
    unsigned int timestamp=_getTickCount();
    
    
    int videoBps=0;
    
    if (sessionID >= 0 && avIndex >= 0)
    {

        avClientCleanVideoBuf(avIndex);

        
        while (isRunningRecvVideoThread)
        {
           
           
            unsigned int now = _getTickCount();
            
            if (now - timestamp > 1000)
            {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.cameraDelegate &&[self.cameraDelegate respondsToSelector:@selector(camera:frameInfoWithVideoBPS:)])
                    {
                        [self.cameraDelegate camera:self frameInfoWithVideoBPS:videoBps];
                    }
                        
                });
                
                timestamp = now;
                videoBps = 0;
            }
            
            //usleep(1*1000);
            
  
            readSize = avRecvFrameData2(avIndex, recvBuf, RECV_VIDEO_BUFFER_SIZE, &outBufSize, &outFrmSize, (char *)&frmInfo, sizeof(frmInfo), &outFrmInfoSize, &frmNo);

            
            if (readSize == AV_ER_BUFPARA_MAXSIZE_INSUFF)
            {

                continue;
                
            }else if (readSize ==  AV_ER_MEM_INSUFF)
            {
                continue;
            } else if(readSize == AV_ER_INCOMPLETE_FRAME)
            {
                continue;
            }
            else if (readSize == AV_ER_LOSED_THIS_FRAME)
            {
                continue;
            }
            else if (readSize == AV_ER_DATA_NOREADY)
            {
                usleep(10*1000);
                continue;
                
            }
            else if (readSize >= 0)
            {
                if (frmInfo.flags == IPC_FRAME_FLAG_IFRAME || frmNo == (prevFrmNo + 1))
                {
                    
                    prevFrmNo = frmNo;
                    if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264)
                    {
                        //printf("RECV H.264 ======================size: %d\n",readSize);
                        [[Mp4VideoRecorder getInstance] writeFrameData:(unsigned char *)recvBuf withSize:readSize];
                        
                        [decoder DecodeH264Frames:(unsigned char*)recvBuf withLength:readSize];
                      
                    }
                    videoBps+=readSize;
                }
                else
                {
                    NSLog(@"\t[H264] Incorrect %@ frame no(%d), prev:%d -> drop frame", (frmInfo.flags == IPC_FRAME_FLAG_IFRAME ? @"I" : @"P"), frmNo, prevFrmNo);
                    usleep(1*1000);
                    continue;
                }

                
            }
            else
            {
                usleep(1*1000);
                continue;
                
            }


        }

    }
    else
    {
        free(recvBuf);
        
        decoder.updateDelegate=nil;
        [decoder release];
        
        printf("doRecvVideo: [sessionID < 0 || avIndex < 0]\n");
        return;
    }



    free(recvBuf);
    
    decoder.updateDelegate=nil;
    [decoder release];
    
    NSLog(@"\t=== RecvVideo Thread Exit ===\n");
    

}

- (void)updateDecodedH264FrameData:(H264YUV_Frame *)yuvFrame
{
    if(updatingYUVFrame)
    {
        if([cameraDelegate respondsToSelector:@selector(cameraUpdateDecodedH264FrameData:)])
        {
            [cameraDelegate cameraUpdateDecodedH264FrameData:yuvFrame];
        }
    }
}

- (void)doRecvAudio
{
    //NSLog(@"=== RecvAudio Thread Start (%@) ===", uid);
    OpenALPlayer *player = nil;
    BOOL bFirst = YES;
    
    int readSize = 0;
    char recvBuf[RECV_AUDIO_BUFFER_SIZE] = {0};
       
    FRAMEINFO_t stFrmInfo = {0};
    
    unsigned int nFrmNo = 0;
    
    short decodeBuffer[640];
    unsigned char outBuffer[1280];
    
	if (sessionID >= 0 && avIndex >= 0)
	{
		avClientCleanAudioBuf(avIndex);
    }
    
    while(isRunningRecvAudioThread)
    {
    
        if (sessionID >= 0 && avIndex >= 0)
        {
    
            readSize = avRecvAudioData(avIndex, recvBuf, RECV_AUDIO_BUFFER_SIZE, (char *)&stFrmInfo, sizeof(FRAMEINFO_t), &nFrmNo);
     
            if (readSize >= 0)
            {
                                
                if (bFirst)
                {
                    bFirst = NO;
                    player = [[OpenALPlayer alloc] init];
                    [player  initOpenAL:AL_FORMAT_MONO16 :8000];
                    
                }   
                //printf("Receive Audio------------------------>>>%d %X:\n\n",readSize,stFrmInfo.codec_id);
                if ((stFrmInfo.codec_id == 0x8F)||(stFrmInfo.codec_id == 0x8A))
                {

                    memset(decodeBuffer, 0, sizeof(decodeBuffer));
                    
                    G711Decoder(decodeBuffer,(unsigned char *)recvBuf,readSize,0);
                    
                    memset(outBuffer, 0, sizeof(outBuffer));
                    memcpy(outBuffer, (unsigned char*)decodeBuffer, readSize*2);

                    //录音
                    [[Mp4VideoRecorder getInstance] writeListenData:(unsigned char*)outBuffer withSize:readSize*2];
                        
                    [player openAudioFromQueue:outBuffer withLength:readSize*2];

                }

                
            }
            else if (readSize == AV_ER_DATA_NOREADY) {                
                //NSLog(@"avRecvAudioData return AV_ER_DATA_NOREADY");
                usleep(10 * 1000);
            }
            else if (readSize == AV_ER_LOSED_THIS_FRAME)
            {
                //NSLog(@"avRecvAudioData return AV_ER_LOSED_THIS_FRAME");
            }
            else
            {
                //NSLog(@"avRecvAudioData return err - %d", readSize);
                usleep(10 * 1000);
            }
        }
        else usleep(10 * 1000);
    }

    if (player != nil)
    {
        [player stopSound];
        [player cleanUpOpenAL];
        [player release];
        player = nil;
    }
    
    NSLog(@"=== Recv Audio Thread Exit (%@) ===",self.name);
    
}

- (void)doSendAudio
{
    
    
    chIndexForSendAudio = IOTC_Session_Get_Free_Channel(sessionID);
    
    if (chIndexForSendAudio < 0)
    {
        NSLog(@" Error: doSendAudio  chIndexForSendAudio<0 \n");
        return;
    }
    
    SMsgAVIoctrlAVStream *s = malloc(sizeof(SMsgAVIoctrlAVStream));
    s->channel=chIndexForSendAudio;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_SPEAKERSTART Data:(char *)s DataSize:sizeof(SMsgAVIoctrlAVStream)];
    free(s);
    
 
    
    if((avIndexForSendAudio = avServStart(sessionID, NULL, NULL, 60, 0, chIndexForSendAudio)) < 0)
    {
        NSLog(@"Error: doSendAudio avServStart(%d, %d) : %d\n", sessionID, chIndexForSendAudio, avIndexForSendAudio);
    }
    
  
    
    ResetADPCMEncoder();
    
    AudioStreamBasicDescription format = (AudioStreamBasicDescription)
    {
        .mSampleRate = 8000,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
        .mBitsPerChannel = 16,
        .mChannelsPerFrame = 1,
        .mBytesPerFrame = 2,
        .mFramesPerPacket = 1,
        .mBytesPerPacket = 2,
    };
    
    audioCodec=MEDIA_CODEC_AUDIO_G711;
    recorder = [[AudioCollector alloc] initAudioCollectorWithAvIndex:avIndexForSendAudio Codec:audioCodec AudioFormat:format Delegate:self];
    
    [recorder start:320];
    
    isRunningSendAudio=TRUE;
    

}

#pragma mark - AudioCollectorDelegate Methods
- (void)recvRecordingWithAvIndex:(NSInteger)avIndex_ Codec:(NSInteger)codec Data:(void *)buff DataLength:(NSInteger)length {
    
    if (avIndex_ >= 0)
    {
        
        FRAMEINFO_t frameInfo;
        frameInfo.cam_index = 0;
        frameInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;
        frameInfo.onlineNum = 0;
        frameInfo.timestamp = _getTickCount();
        frameInfo.codec_id = MEDIA_CODEC_AUDIO_G711;
        
        unsigned int encodeInLength=length/2;
        
        //printf("--------------------------->>>> %d\n",encodeInLength);
        
        short recordBuff[160]={0};
        memcpy(recordBuff, buff, length);
        
        unsigned char outG711Buf[160] = {0};
        
        G711Encoder(recordBuff,outG711Buf,encodeInLength,0);
        
        avSendAudioData(avIndex_, (char *)outG711Buf, encodeInLength, &frameInfo, sizeof(FRAMEINFO_t));
        
    }
}

- (void)sendIOCtrl:(int)controlCMD Data:(char *)buff DataSize:(NSInteger)size
{
    [ioCtrlMsgQueue enqueueIOCtrlMsg:controlCMD :buff :size];
}

- (void)sendIOCtrlFromMsgQueueThread
{
    
    int type, size;
    char *buff = malloc(MAX_IOCTRL_BUFFER_SIZE);
    
    while (isRunningSendIOCtrlThread)
    {
        while (isRunningSendIOCtrlThread && (sessionID < 0 || avIndex < 0)) {
            usleep(1 * 1000);
            continue;
        }
        
        if (sessionID >= 0 && avIndex >= 0)
        {
            
            if ([ioCtrlMsgQueue dequeueIOCtrlMsg:&type :buff :&size] == 1) {
                
				BOOL bRetry = FALSE;
                
				do
                {
					bRetry = FALSE;
                    
                    
					int nRet = avSendIOCtrl(avIndex, type, buff, size);
      
                    
					switch(nRet)
                    {
						case AV_ER_INVALID_ARG:
						{
							
						}   break;
						case AV_ER_SENDIOCTRL_ALREADY_CALLED:
						{
							bRetry = TRUE;
							usleep( 1*1000 );
						}   break;
						case AV_ER_SESSION_CLOSE_BY_REMOTE:
						{
							
						}   break;
						case AV_ER_REMOTE_TIMEOUT_DISCONNECT:
						{
							
						}   break;
						case AV_ER_INVALID_SID:
						{
							
						}   break;
						case AV_ER_SENDIOCTRL_EXIT:
						{
							
						}   break;
						case AV_ER_EXCEED_MAX_SIZE:
						{
							
						}   break;
							
						case AV_ER_NoERROR:
						default:
							break;
					}
				} while (bRetry);
                
            }
        }
        
        usleep(1 * 1000);
    }
    
    free(buff);
    
    
}

- (void)recvIOCtrlFromDeviceThread
{
 

    
    unsigned int type;
    int readSize = 0;
   
    
    while (isRunningRecvIOCtrlThread)
    {
        

        __block unsigned int    currentRecvedSize=0;
        //memset(snapshotImageBuffer, 0, sizeof(snapshotImageBuffer));
        
RE_RECEIVEF:
        
        usleep(1000);

        [avIndex_Locker lock];
        if(avIndex>=0)
        {
            readSize = avRecvIOCtrl(avIndex, &type, recvIOCtrlBuff, MAX_IOCTRL_BUFFER_SIZE, 1000);
        }
        [avIndex_Locker unlock];
        
        if (readSize >= 0)
        {
            
            //NSLog(@">>> avRecvIOCtrl( %d, %d, %X, %@)\n", sessionID, avIndex, type, [self _getHexString:recvIOCtrlBuff Size:readSize]);
            
            
            if (type == IOTYPE_USER_IPCAM_GET_FLOWINFO_REQ)
            {
                SMsgAVIoctrlGetFlowInfoReq *req = (SMsgAVIoctrlGetFlowInfoReq *)recvIOCtrlBuff;
                
                NSLog(@"========IOTYPE_USER_IPCAM_GET_FLOWINFO_REQ =========\n");
        
                SMsgAVIoctrlGetFlowInfoResp *resp = malloc(sizeof(SMsgAVIoctrlGetFlowInfoResp));
                resp->channel = 0;
                resp->collect_interval = req->collect_interval;
                [self sendIOCtrl:IOTYPE_USER_IPCAM_GET_FLOWINFO_RESP Data:(char*)resp DataSize:sizeof(SMsgAVIoctrlGetFlowInfoResp)];
                free(resp);
                
            }
            else if(type==IOTYPE_USER_IPCAM_EVENT_REPORT)
            {
                 //NSLog(@"Receive remote notifications %d %d %d %@\n", sessionID, avIndex, type, [self _getHexString:recvIOCtrlBuff Size:readSize]);
                /*
                self.remoteNotifications++;
                SMsgAVIoctrlEvent* resp=(SMsgAVIoctrlEvent*)recvIOCtrlBuff;
                int type=resp->event;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:didReceiveNotifications:)])
                    {
                        [self.cameraDelegate camera:self didReceiveNotifications:type];
                    }
                    
                    
                });*/
            }
            else if(type == IOTYPE_USER_IPCAM_GET_SNAP_RESP)
            {
                
                
               
                
            }
            else
            {
                //NSLog(@">>> avRecvIOCtrl( %d, %d, %X, %@)\n", sessionID, avIndex, type, [self _getHexString:recvIOCtrlBuff Size:readSize]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(camera:didReceiveIOCtrlWithType:Data:DataSize:)])
                    {
                        [self.cameraDelegate camera:self didReceiveIOCtrlWithType:type Data:recvIOCtrlBuff DataSize:readSize];
                    }
                    
                    
                });
            }
            
            

        }

    }
   

 
}





/*=========================================================================================*/
/*   回放通道 : changed by chenchao 2013 回放的时候，首先经过通道0发送回放请求命令                 */
/*   设备允许进行回放操作后，通道0的receiveIOControl,解析返回会获得一个新的设备返回的回放通道          */
/*   设备端根据新获取的通道，新建立一个连接avIndex1=avClientStart(...). 然后利用这个avIndex         */
/*   接受视频，音频数据. 新的回放通道与原来实时视频共享sessionID,共享命令通道avIndex0                 */
/*=========================================================================================*/




- (void)playback_StartWithChannel: (NSInteger)playbackChannel
{
    avChannel_P=playbackChannel;
    int serverType = 0;
    
    if(sessionID>=0)
    {
        if (avIndex_P < 0)
        {
            
        
            //NSLog(@"Playback Channel: SesionID %d AccountName: %@ Password: %@\n\n",sessionID,viewAcc,viewPwd);
            avIndex_P = avClientStart2(sessionID, (char *)[viewAcc UTF8String], (char *)[viewPwd UTF8String], 30, (unsigned long *)&serverType, avChannel_P, &nAvResend);
            
   
            //NSLog(@"Playback Channel: SID:%@ %d %d %d\n",self.name, connectionState,sessionState,avIndex_P);
            if (avIndex_P >= 0)
            {
                connectionState_P = CONNECTION_STATE_CONNECTED;
                
            } else if (avIndex_P == AV_ER_WRONG_VIEWACCorPWD)
            {
                connectionState_P = CONNECTION_STATE_WRONG_PASSWORD;
                
            } else if (avIndex_P == AV_ER_REMOTE_TIMEOUT_DISCONNECT || avIndex == AV_ER_TIMEOUT)
            {
                connectionState_P = CONNECTION_STATE_TIMEOUT;
                     
            }
        }
        
    }
    else
    {
        //session id<=0;
    }
    
    
}

- (void)playback_startShow
{
    int camIndex = 0;
    
    [self sendIOCtrl:IOTYPE_INNER_SND_DATA_DELAY Data:(char *)&camIndex DataSize:4];
    
    [self sendIOCtrl:IOTYPE_USER_IPCAM_START Data:(char *)&camIndex DataSize:4];
    
    
    isRunningRecvVideoThread_P=TRUE;
    updatingYUVFrame=TRUE;
    
    [NSThread detachNewThreadSelector:@selector(playback_RecvVideo) toTarget:self withObject:nil];
    
    
}

- (void)playback_StartSoundToPhone
{
    
    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_AUDIOSTART Data:(char *)&camIndex DataSize:4];
    
    isRunningRecvAudioThread_P = TRUE;
    
    [NSThread detachNewThreadSelector:@selector(playback_RecvAudio) toTarget:self withObject:nil];
    
}

- (void)playback_StopSoundToPhone
{
    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_AUDIOSTOP Data:(char *)&camIndex DataSize:4];
    isRunningRecvAudioThread_P = FALSE;
    
}

- (void)playback_StopShow
{

    isRunningRecvVideoThread_P=FALSE;
    updatingYUVFrame=FALSE;
    
    int camIndex = 0;
    [self sendIOCtrl:IOTYPE_USER_IPCAM_STOP Data:(char *)&camIndex DataSize:4];
    
    
    
}
- (void)playback_StopConnectedChannel4Session
{

    if(avIndex_P>=0)
    {
        avClientStop(avIndex_P);
        avIndex_P=-1;
    }

}


- (void)playback_RecvVideo
{
    
    
    int readSize = -1;
    char *recvBuf = malloc(RECV_VIDEO_BUFFER_SIZE);
    
    FRAMEINFO_t frmInfo = {0};
    unsigned int frmNo = 0;
    
    
    int outBufSize = 0, outFrmSize = 0, outFrmInfoSize = 0;
    
    H264Decoder*     decoder=[[H264Decoder alloc] init];
    decoder.updateDelegate=self;
    
    unsigned int timestamp=_getTickCount();
    
    
    int videoBps=0;

    
    if (sessionID >= 0 && avIndex_P >= 0)
    {

        avClientCleanVideoBuf(avIndex_P);

        
        while (isRunningRecvVideoThread_P)
        {
            
            
            unsigned int now = _getTickCount();
            
            if (now - timestamp > 1000)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.cameraDelegate &&[self.cameraDelegate respondsToSelector:@selector(camera:frameInfoWithVideoBPS:)])
                    {
                        [self.cameraDelegate camera:self frameInfoWithVideoBPS:videoBps];
                    }
                    
                });
                
                timestamp = now;
                videoBps = 0;
            }
            
            
            usleep(1*1000);
      
            readSize = avRecvFrameData2(avIndex_P, recvBuf, RECV_VIDEO_BUFFER_SIZE, &outBufSize, &outFrmSize, (char *)&frmInfo, sizeof(frmInfo), &outFrmInfoSize, &frmNo);

            
            if (readSize == AV_ER_BUFPARA_MAXSIZE_INSUFF)
            {
                
                continue;
                
            }else if (readSize ==  AV_ER_MEM_INSUFF)
            {
                continue;
            } else if(readSize == AV_ER_INCOMPLETE_FRAME)
            {
                continue;
            }
            else if (readSize == AV_ER_LOSED_THIS_FRAME)
            {
                continue;
            }
            else if (readSize == AV_ER_DATA_NOREADY)
            {
                usleep(10*1000);
                continue;
                
            }
            else if (readSize >= 0)
            {
                
                if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264)
                {
                  
                    [decoder DecodeH264Frames:(unsigned char *)recvBuf withLength:readSize];
        
                    
                }
                videoBps+=readSize;
                
            }
            else
            {
                usleep(5*1000);
                continue;
                
            }
            
            
        }
        
    }
    else
    {
        
        free(recvBuf);
        
        [decoder release];
        
        printf("Playback Channel: doRecvVideo: [sessionID < 0 || avIndex < 0]\n");
        return;
    }
    
    
    
    free(recvBuf);
    
    [decoder release];
    
    NSLog(@"\t===Playback: RecvVideo Thread Exit ===\n");
    
    
}


- (void)playback_RecvAudio
{
    
    NSLog(@"===Playback: RecvAudio Thread Start (%@) ===", uid);
    
    OpenALPlayer *player = nil;
    
    
    BOOL bFirst = YES;
    
    int readSize = 0;
    char recvBuf[RECV_AUDIO_BUFFER_SIZE] = {0};
    
    short decodeBuffer[640];
    unsigned char outBuffer[1280];
    
    FRAMEINFO_t stFrmInfo = {0};
    
    unsigned int nFrmNo = 0;
    
	
	if (sessionID >= 0 && avIndex_P >= 0)
		avClientCleanAudioBuf(avIndex_P);
    
    while(isRunningRecvAudioThread_P)
    {
        
        if (sessionID >= 0 && avIndex_P >= 0)
        {
 
            readSize = avRecvAudioData(avIndex_P, recvBuf, RECV_AUDIO_BUFFER_SIZE, (char *)&stFrmInfo, sizeof(FRAMEINFO_t), &nFrmNo);

            
            if (readSize > 0)
            {
                
                if (bFirst)
                {
                    bFirst = NO;
                    player = [[OpenALPlayer alloc] init];
                    [player  initOpenAL:AL_FORMAT_MONO16 :8000];
                    
                }
                if(readSize!=640)//有时候最后一帧音频数据大于640字节，导致内存拷贝崩溃.音频数据为640字节.
                {
                    continue;
                }
                //printf("Receive Audio------------------------>>>%d %X:\n\n",readSize,stFrmInfo.codec_id);
                if ((stFrmInfo.codec_id == 0x8F)||(stFrmInfo.codec_id == 0x8A))
                {
                    
                    memset(decodeBuffer, 0, sizeof(decodeBuffer));
                    
                    G711Decoder(decodeBuffer,(unsigned char *)recvBuf,readSize,0);
                    
                    memset(outBuffer, 0, sizeof(outBuffer));
                    memcpy(outBuffer, (unsigned char*)decodeBuffer, readSize*2);
                    
                    [player openAudioFromQueue:outBuffer withLength:readSize*2];
                    
                   
                    
                }
                
                
            }
            else if (readSize == AV_ER_DATA_NOREADY) {
                NSLog(@"avRecvAudioData return AV_ER_DATA_NOREADY");
                usleep(10 * 1000);
            }
            else if (readSize == AV_ER_LOSED_THIS_FRAME)
            {
                NSLog(@"avRecvAudioData return AV_ER_LOSED_THIS_FRAME");
            }
            else
            {
                NSLog(@"avRecvAudioData return err - %d", readSize);
                usleep(10 * 1000);
            }
        }
        else usleep(10 * 1000);
    }
    
    if (player != nil)
    {
        [player stopSound];
        [player cleanUpOpenAL];
        [player release];
        player = nil;
    }
    
    
}

+ (IPHONEDEVICE_GENERATION)getDeviceInfomation
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone1,1"])    return IPHONEDEVICEGEN_1;
    if ([deviceString isEqualToString:@"iPhone1,2"])    return IPHONEDEVICEGEN_2;
    if ([deviceString isEqualToString:@"iPhone2,1"])    return IPHONEDEVICEGEN_3;
    if ([deviceString isEqualToString:@"iPhone3,1"])    return IPHONEDEVICEGEN_4;
    if ([deviceString isEqualToString:@"iPhone3,2"])    return IPHONEDEVICEGEN_4;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return IPHONEDEVICEGEN_5;
    if ([deviceString isEqualToString:@"iPhone4,2"])    return IPHONEDEVICEGEN_5;
    if ([deviceString isEqualToString:@"iPhone5,1"])    return IPHONEDEVICEGEN_6;
    if ([deviceString isEqualToString:@"iPhone5,2"])    return IPHONEDEVICEGEN_6;
    if ([deviceString isEqualToString:@"iPhone6,1"])    return IPHONEDEVICEGEN_7;
    if ([deviceString isEqualToString:@"iPhone6,2"])    return IPHONEDEVICEGEN_7;
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return IPHONEDEVICEGEN_1;
    if ([deviceString isEqualToString:@"iPod2,1"])      return IPHONEDEVICEGEN_2;
    if ([deviceString isEqualToString:@"iPod3,1"])      return IPHONEDEVICEGEN_3;
    if ([deviceString isEqualToString:@"iPod4,1"])      return IPHONEDEVICEGEN_4;
    if ([deviceString isEqualToString:@"iPad1,1"])      return IPHONEDEVICEGEN_4;
    if ([deviceString isEqualToString:@"iPad2,1"])      return IPHONEDEVICEGEN_5;
    if ([deviceString isEqualToString:@"iPad2,2"])      return IPHONEDEVICEGEN_5;
    if ([deviceString isEqualToString:@"iPad2,3"])      return IPHONEDEVICEGEN_5;
    if ([deviceString isEqualToString:@"i386"])         return IPHONEDEVICEGEN_UNKNOWN;
    if ([deviceString isEqualToString:@"x86_64"])       return IPHONEDEVICEGEN_UNKNOWN;
    
    
    NSLog(@"NOTE: Unknown device type: %@\n", deviceString);
    return deviceString;
}

@end

