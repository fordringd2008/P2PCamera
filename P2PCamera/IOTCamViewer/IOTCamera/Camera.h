//
//  Camera.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/5/11.
//  Copyright (c) 2011 CHENCHAO. All rights reserved.
//



#define CONNECTION_MODE_NONE -1
#define CONNECTION_MODE_P2P 0
#define CONNECTION_MODE_RELAY 1
#define CONNECTION_MODE_LAN 2

/* used for display status */
#define CONNECTION_STATE_NONE 0
#define CONNECTION_STATE_CONNECTING 1
#define CONNECTION_STATE_CONNECTED 2
#define CONNECTION_STATE_DISCONNECTED 3
#define CONNECTION_STATE_UNKNOWN_DEVICE 4
#define CONNECTION_STATE_WRONG_PASSWORD 5
#define CONNECTION_STATE_TIMEOUT 6
#define CONNECTION_STATE_UNSUPPORTED 7
#define CONNECTION_STATE_CONNECT_FAILED 8

typedef struct st_LanSearchInfo LanSearch_t;



#define REAL_AUDIO_OUT


#define AVRECVFRAMEDATA2



#define RECV_VIDEO_BUFFER_SIZE 1280 * 720 * 3
#define RECV_AUDIO_BUFFER_SIZE 1280
#define SPEEX_FRAME_SIZE 160
#define MAX_IOCTRL_BUFFER_SIZE 1024
#define kQualityMonitorPeriod 60000
#define SNAPSHOTIMAGEBUFFER_SIZE 10240
#define DONE 1
#define NOTDONE 0


typedef  enum
{
    IPHONEDEVICEGEN_1=0,
    IPHONEDEVICEGEN_2,
    IPHONEDEVICEGEN_3,
    IPHONEDEVICEGEN_4,
    IPHONEDEVICEGEN_5,
    IPHONEDEVICEGEN_6,
    IPHONEDEVICEGEN_7,
    IPHONEDEVICEGEN_UNKNOWN
    
}IPHONEDEVICE_GENERATION;


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "H264Decoder.h"
#import "AudioCollector.h"
#import "SendIOCtrlMsgQueue.h"

@protocol CameraDelegate;

@interface Camera : NSObject<updateDecodedH264FrameDelegate,AudioCollectorDelegate>
{

    int              sessionID;
    int              sessionMode;
    int              sessionState;
    int              sessionID4ConnStop;
    
    int              avChannel;
    
    int              audioCodec;
    int              nAvResend;
    int              avIndex;
    
    int              connFailErrCode;
    int              connectionState; //连接状态.
    int              chIndexForSendAudio; //发送Audio通道。
    int              avIndexForSendAudio; //sendAudio index
    
    int              remoteNotifications;//推送数量
    BOOL             bIsSupportTimeZone;
	int              nGMTDiff;
    
    NSString         *name;
    NSString         *uid;
    NSString         *viewAcc;
    NSString         *viewPwd;

    volatile BOOL             updatingYUVFrame;
    volatile BOOL             isRunningRecvAudioThread;
    volatile BOOL             isRunningRecvVideoThread;
    volatile BOOL             isRunningSendIOCtrlThread;
    volatile BOOL             isRunningRecvIOCtrlThread;
    volatile BOOL             isRunningCheckingThread;
    
    volatile BOOL             isConnectingServer;
    volatile BOOL             isRunningSendAudio;
    
    volatile BOOL             connectState;
    
    char                      recvIOCtrlBuff[MAX_IOCTRL_BUFFER_SIZE];
    char                      snapshotImageBuffer[SNAPSHOTIMAGEBUFFER_SIZE];
    
    id<CameraDelegate>         cameraDelegate;
    
    SendIOCtrlMsgQueue        *ioCtrlMsgQueue;
    AudioCollector             *recorder;

    
    
    //回放通道
    int                       avChannel_P;
    int                       nAvResend_P;
    int                       avIndex_P;
    
    int                       connectionState_P; //连接状态.
    
    volatile BOOL             isRunningRecvAudioThread_P;
    volatile BOOL             isRunningRecvVideoThread_P;
    
    char                      recvIOCtrlBuff_P[MAX_IOCTRL_BUFFER_SIZE];
    
    NSLock*                   avIndex_Locker;
    

}


@property (nonatomic, copy)                     NSString *name;
@property (nonatomic, copy)                     NSString *uid;
@property (nonatomic, copy)                     NSString *viewAcc;
@property (nonatomic, copy)                     NSString *viewPwd;
@property (nonatomic,readwrite)int              sessionState;
@property (nonatomic,readwrite)int              remoteNotifications;
@property (nonatomic,readonly)int               connectionState; //连接状态.

@property (nonatomic,readwrite)volatile BOOL             updatingYUVFrame;
@property (nonatomic,readwrite)volatile BOOL             isRunningRecvAudioThread;
@property (nonatomic,readwrite)volatile BOOL             isRunningRecvVideoThread;
@property (nonatomic,readwrite)volatile BOOL             isRunningSendIOCtrlThread;
@property (nonatomic,readwrite)volatile BOOL             isRunningRecvIOCtrlThread;
@property (nonatomic,readwrite)volatile BOOL             isRunningCheckingThread;

@property (nonatomic,readwrite)volatile BOOL             isRunningRecvAudioThread_P;
@property (nonatomic,readwrite)volatile BOOL             isRunningRecvVideoThread_P;


@property (nonatomic, assign) BOOL                      bIsSupportTimeZone;
@property (nonatomic, assign) int                       nGMTDiff;

@property (nonatomic, assign) id<CameraDelegate> cameraDelegate;

/*
 
 415926
 
 */

- (id)initWithUID:(NSString*)uid camName:(NSString *)name viewAccount:(NSString *)viewAcc_ viewPassword:(NSString *)viewPwd_;
+ (void)initIOTC;
+ (void)uninitIOTC;
+ (NSString *)getIOTCAPIsVerion;
+ (NSString *)getAVAPIsVersion;
+ (LanSearch_t *)LanSearch:(int *)num timeout:(int)timeoutVal;

- (void)connect;
- (void)stopConnectedSession;
- (void)exitConnectedSession;


- (Boolean)isConnecting;
- (void)startShow;
- (void)stopShow;

- (void)startSoundToPhone;
- (void)stopSoundToPhone;
- (void)startSoundToDevice;
- (void)stopSoundToDevice;

- (void)sendIOCtrl:(int)controlCMD Data:(char *)buff DataSize:(NSInteger)size;
- (NSString *)getViewAccount;
- (NSString *)getViewPassword;
- (unsigned long)getServiceType;
- (int)getConnectionState;
- (void)setConnectionState:(NSInteger)state;


- (void)setRemoteNotification:(NSInteger)type EventTime:(long)time;



- (NSString*)getOverAllQualityString;
+ (NSString*)getConnModeString:(NSInteger)connMode;
+ (IPHONEDEVICE_GENERATION)getDeviceInfomation;


/*=========================================================================================*/
/*   回放通道 : changed by chenchao 2013 回放的时候，首先经过通道0发送回放请求命令                 */
/*   设备允许进行回放操作后，通道0的receiveIOControl,解析返回会获得一个新的设备返回的回放通道          */
/*   设备端根据新获取的通道，新建立一个连接avIndex1=avClientStart(...). 然后利用这个avIndex         */
/*   接受视频，音频数据. 新的回放通道与原来实时视频共享sessionID,共享命令通道avIndex0                 */
/*=========================================================================================*/

- (void)playback_StartWithChannel: (NSInteger)playbackChannel;
- (void)playback_startShow;
- (void)playback_StartSoundToPhone;

- (void)playback_StopSoundToPhone;
- (void)playback_StopShow;
- (void)playback_StopConnectedChannel4Session;


@end


//Camera 协议.
@protocol CameraDelegate <NSObject>

@optional
- (void)camera:(Camera *)camera didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height;
- (void)camera:(Camera *)camera updateRemoteNotifications:(NSInteger)type EventTime:(long)time;
- (void)camera:(Camera *)camera frameInfoWithVideoBPS:(NSInteger)videoBps;

- (void)camera:(Camera *)camera connect_updateConnectSessionStates:(NSInteger)states;
- (void)camera:(Camera *)camera connect_updateConnectIndex4SessionStates:(NSInteger)states;

- (void)camera:(Camera *)camera checkStatus_reConnectSesssion:(NSInteger)status;

- (void)camera:(Camera *)camera didReceiveNotifications:(NSInteger)type;
- (void)camera:(Camera *)camera didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size;
- (void)cameraUpdateDecodedH264FrameData:(H264YUV_Frame*)yuvFrame;


@end


