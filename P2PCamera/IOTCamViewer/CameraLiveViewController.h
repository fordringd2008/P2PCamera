//
//  CameraLiveViewController.h
//  IOTCamViewer
//
//  Created by chenchao on 12/7/11.
//  Copyright (c) 2012 CHENCHAO. All rights reserved.
//



#define MAX_IMG_BUFFER_SIZE	(1280*720*3)
#define PT_SPEED 50
#define ZOOM_MAX_SCALE 5.0
#define ZOOM_MIN_SCALE 1.0
#define degreeToRadians(x) (M_PI * (x) / 180.0)

#import <UIKit/UIKit.h>
#import "AVIOCTRLDEFs.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Camera.h"
#import "FMDatabase.h"
#import "WEPopoverController.h"
#import "OpenGLFrameView.h"
#import "Mp4VideoRecorder.h"
#import "RecordModeDialog.h"

typedef enum
{
	AUDIO_MODE_OFF          = 0,
	AUDIO_MODE_SPEAKER      = 1,
    AUDIO_MODE_MICROPHONE   = 2,
}ENUM_AUDIO_MODE;



extern FMDatabase *database;
extern NSString* G_loginAccountName;

//全局变量，定义当前屏幕的旋转方向.
CurrentDeviceOrientation            __currentDeviceOrientation;

@interface CameraLiveViewController : UIViewController
<UIAlertViewDelegate,UIScrollViewDelegate,CameraDelegate,OpenGLESViewPTZDelegate,RecordModeDialogDelegate> {
    

    CURRENT_RECORDTYPE                  currentRecordType;
	unsigned short                      mCodecId;
    
    int                                 listenModeState;
    int                                 recordModeState;
    int                                 talkModeState;
    
    NSString                            *directoryPath;
    
    Camera                            *camera;
    
    NSInteger                           selectedChannel;
    ENUM_AUDIO_MODE                     selectedAudioMode;
    
    int                                 wrongPwdRetryTime;
    
    UIButton*                           audioButton;
    
    UIButton*                           recordButton;
    

    UILabel*                            networkSpeed_Label;
    UILabel*                            videoWH_Label;
    
    UIView*                             titleView;
    UIScrollView*                       scrollView;

    
    BOOL                                updateVideoIsReady;
    BOOL                                isRecordingVideo;
    
    OpenGLFrameView*                    openGLESView;
    
    UIActivityIndicatorView*            activityIndicatorView;
    

    
    NSTimer*                            recordBeatTimer;
    NSString*                           recordStartTime;
    

    
}

@property (nonatomic,readwrite)int                                  sdCardSize;
@property (nonatomic,readwrite)CURRENT_RECORDTYPE                   currentRecordType;
@property (nonatomic,readwrite)BOOL                                 isRecordingVideo;
@property (nonatomic, assign) unsigned short                        mCodecId;
@property (nonatomic,retain)NSString*                               recordStartTime;

@property (nonatomic, retain) Camera *camera;
@property NSInteger selectedChannel;
@property ENUM_AUDIO_MODE selectedAudioMode;;
@property (nonatomic, copy) NSString *directoryPath;


@end
