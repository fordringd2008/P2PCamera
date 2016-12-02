//
//  CameraLiveViewController.m
//  IOTCamViewer
//
//  Created by chenchao on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraLiveViewController.h"

#import "iToast.h"
#import "AVFRAMEINFO.h"
#import <sys/time.h>



#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif



@implementation CameraLiveViewController

@synthesize currentRecordType;
@synthesize isRecordingVideo;
@synthesize mCodecId;
@synthesize selectedChannel;
@synthesize selectedAudioMode;
@synthesize sdCardSize;
@synthesize camera;
@synthesize directoryPath;
@synthesize recordStartTime;




#pragma mark - View lifecycle

-(id)init
{
    
    if(self=[super init])
    {
        
        //self.navigationItem.title = NSLocalizedString(@"Live View", @"");

        recordBeatTimer             =nil;
        __currentDeviceOrientation  =DEVICE_ORIENTATION_PORTRAIT;
        isRecordingVideo            =FALSE;
        currentRecordType           =CURRENT_RECORDTYPE_NONE;
        self.sdCardSize             =-1;
        wrongPwdRetryTime           = 0;
        
        listenModeState             =-1;
        recordModeState             =-1;
        talkModeState               =-1;
        
        CGRect screenRect=[[UIScreen mainScreen] bounds];
        
        float TITLEVIEW_STARTY=65;
        
        
        float   OPENGLESVIEW_STARTX=0.0;
        float   OPENGLESVIEW_STARTY=130.0;
        float   OPENGLESVIEW_WIDTH=320.0;
        float   OPENGLESVIEW_HEIGHT=180.0;
        
        float   ACTIVITYINDICATORVIEW_STARTX=145.0;
        float   ACTIVITYINDICATORVIEW_STARTY=60.0;
        float   ACTIVITYINDICATORVIEW_WIDTH=30.0;
        float   ACTIVITYINDICATORVIEW_HEIGHT=30.0;
        
        float   RECORDBEATIMAGE_STARTX=250.0;
        float   RECORDTIMELABEL_STARTX=260.0;
        
        
        
        //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
        if([self getIOSVersion] !=70)
        {
            TITLEVIEW_STARTY=25;
            OPENGLESVIEW_STARTY=80.0;
        }

        
        if (screenRect.size.height==568)
        {
            TITLEVIEW_STARTY=140;

            
            OPENGLESVIEW_STARTX=0.0;
            OPENGLESVIEW_STARTY=180.0;
            OPENGLESVIEW_WIDTH=320.0;
            OPENGLESVIEW_HEIGHT=180.0;
            
            ACTIVITYINDICATORVIEW_STARTX=145.0;
            ACTIVITYINDICATORVIEW_STARTY=70.0;
            ACTIVITYINDICATORVIEW_WIDTH=30.0;
            ACTIVITYINDICATORVIEW_HEIGHT=30.0;
            
            //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
            if([self getIOSVersion] !=70)
            {
                TITLEVIEW_STARTY=25;
                OPENGLESVIEW_STARTY=120.0;
            }
        }
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            TITLEVIEW_STARTY=180;
            

            
            OPENGLESVIEW_STARTX=0.0;
            OPENGLESVIEW_STARTY=240.0;
            OPENGLESVIEW_WIDTH=768.0;
            OPENGLESVIEW_HEIGHT=432.0;
            
            ACTIVITYINDICATORVIEW_STARTX=370.0;
            ACTIVITYINDICATORVIEW_STARTY=200.0;
            ACTIVITYINDICATORVIEW_WIDTH=30.0;
            ACTIVITYINDICATORVIEW_HEIGHT=30.0;
            
            RECORDBEATIMAGE_STARTX=708.0;
            RECORDTIMELABEL_STARTX=718.0;
            
            //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
            if([self getIOSVersion] !=70)
            {
                TITLEVIEW_STARTY=120;
                OPENGLESVIEW_STARTY=180.0;
            }
        }

        UIView *screenView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [screenView setBackgroundColor:[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1]];
        screenView.autoresizesSubviews=YES;

        
        titleView=[[UIView alloc] initWithFrame:CGRectMake(screenRect.size.width-80, TITLEVIEW_STARTY, 75, 15)];
        [titleView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        
        
        UIFont*     labelFont=[UIFont fontWithName:@"Verdana" size:12];
        UIFont*     timerFont=[UIFont fontWithName:@"Verdana" size:12];
        
        UILabel* netUnit_Label=[[UILabel alloc] initWithFrame:CGRectMake(42, 5, 35, 15)];
        [netUnit_Label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [netUnit_Label setText:@"kBps"];
        [netUnit_Label setFont:labelFont];
        [netUnit_Label setTextAlignment:NSTextAlignmentLeft];
        [netUnit_Label setTextColor:[UIColor whiteColor]];
        [titleView addSubview:netUnit_Label];
        [netUnit_Label release];
        
        
        
        networkSpeed_Label=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 40, 15)];
        [networkSpeed_Label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [networkSpeed_Label setText:@"0"];
        [networkSpeed_Label setFont:labelFont];
        [networkSpeed_Label setTextAlignment:NSTextAlignmentRight];
        [networkSpeed_Label setTextColor:[UIColor whiteColor]];
        [titleView addSubview:networkSpeed_Label];

        
        videoWH_Label=[[UILabel alloc] initWithFrame:CGRectMake(-screenRect.size.width+90, 5, 80, 15)];
        [videoWH_Label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [videoWH_Label setText:@"00x00"];
        [videoWH_Label setFont:labelFont];
        [videoWH_Label setTextAlignment:NSTextAlignmentLeft];
        [videoWH_Label setTextColor:[UIColor whiteColor]];
        [titleView addSubview:videoWH_Label];
        
        
        
        
        
        UIButton* backButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateHighlighted];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateSelected];
        [backButton addTarget:self action:@selector(onBackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setExclusiveTouch:YES];
        UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
        
        [backButton release];
        [backBarButtonItem release];
        
        


        
        
        openGLESView=[[OpenGLFrameView alloc] initWithFrame:CGRectMake(OPENGLESVIEW_STARTX, OPENGLESVIEW_STARTY, OPENGLESVIEW_WIDTH, OPENGLESVIEW_HEIGHT)];
        openGLESView.openGLESViewPTZDelegate=self;
        
        scrollView=[[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [scrollView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
        scrollView.delegate=self;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 4.0;
        scrollView.showsHorizontalScrollIndicator=NO;
        scrollView.showsVerticalScrollIndicator=NO;
        scrollView.contentSize = openGLESView.frame.size;
        scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [scrollView setAutoresizesSubviews:YES];
        [scrollView setMultipleTouchEnabled:YES];
        [scrollView addSubview:openGLESView];
        
        
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ACTIVITYINDICATORVIEW_STARTX,ACTIVITYINDICATORVIEW_STARTY,ACTIVITYINDICATORVIEW_WIDTH,ACTIVITYINDICATORVIEW_HEIGHT)];
        activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
        activityIndicatorView.hidesWhenStopped=YES;
        activityIndicatorView.userInteractionEnabled=NO;
        [openGLESView addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        
        audioButton=[[UIButton alloc] initWithFrame:CGRectMake(screenSize.width/2-60, openGLESView.frame.origin.y+OPENGLESVIEW_HEIGHT+40, 40, 40)];
        audioButton.tag=0;
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateNormal];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateSelected];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateHighlighted];
        [audioButton addTarget:self action:@selector(selectAudio:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        recordButton=[[UIButton alloc] initWithFrame:CGRectMake(screenSize.width/2+20, openGLESView.frame.origin.y+OPENGLESVIEW_HEIGHT+40, 40, 40)];
        recordButton.tag=0;
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateSelected];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateHighlighted];
        [recordButton addTarget:self action:@selector(selectRecrod:) forControlEvents:UIControlEventTouchUpInside];
        
        
        


        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        

        
   
        
        updateVideoIsReady=FALSE;
        
        [screenView addSubview: scrollView];
        [screenView addSubview:titleView];
        
        [screenView addSubview:audioButton];
        [audioButton release];
        
        [screenView addSubview:recordButton];
        [recordButton release];
        
        self.view=screenView;

        [titleView release];
        [openGLESView release];
        [scrollView release];
        [screenView release];


    }
    
    return self;
    
}


- (void)dealloc
{
   
    if(recordBeatTimer){
        [recordBeatTimer invalidate];
    }
    [self.camera release];
    [self.directoryPath release];
    openGLESView.openGLESViewPTZDelegate=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
     
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{

    updateVideoIsReady=FALSE;
    isRecordingVideo=FALSE;
    currentRecordType=CURRENT_RECORDTYPE_NONE;
    self.sdCardSize=-1;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    //获取SD卡状态命令.
    SMsgAVIoctrlDeviceInfoReq *s = malloc(sizeof(SMsgAVIoctrlDeviceInfoReq));
    memset(s, 0, sizeof(SMsgAVIoctrlDeviceInfoReq));
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_DEVINFO_REQ Data:(char *)s
              DataSize:sizeof(SMsgAVIoctrlDeviceInfoReq)];
    free(s);
    
    //iphone4 4s
    if(( [Camera getDeviceInfomation]==IPHONEDEVICEGEN_4)
       ||([Camera getDeviceInfomation]==IPHONEDEVICEGEN_5))
    {
        //手机访问，默认修改分辨率为720P 10帧,256k码流.
        SMsgAVIoctrlSetStreamCtrlReq *s = malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        memset(s, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        
        s->channel = 0;
        s->quality = AVIOCTRL_QUALITY_MAX;
        
        [camera sendIOCtrl:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                      Data:(char *)s
                  DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        
        free(s);

        
    }
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];

    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{

    self.navigationItem.title =self.camera.name;
    


    
    if (camera != nil) {
        
        camera.cameraDelegate = self;
        
        
        [self verifyConnectionStatus];
        
        if (camera.sessionState != CONNECTION_STATE_CONNECTED)
        {
            [camera connect];
        }
        
        
        [camera startShow];
        
        [self activeAudioSession];
        
        if (selectedAudioMode == AUDIO_MODE_SPEAKER)
        {
            [camera startSoundToPhone];
        }
        
        if (selectedAudioMode == AUDIO_MODE_MICROPHONE)
        {
            [camera startSoundToDevice];
        }
    }
    
    [activityIndicatorView startAnimating];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{

    if (camera != nil)
    {
        self.camera.cameraDelegate=nil;
        
        [camera stopShow];
        [camera stopSoundToDevice];
        [camera stopSoundToPhone];
        
        [self unactiveAudioSession];
        
    }
    [activityIndicatorView stopAnimating];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    
    float   OPENGLVIEW_PORTRAIT_STARTX=0.0;
    float   OPENGLVIEW_PORTRAIT_STARTY=130.0;
    float   OPENGLVIEW_PORTRAIT_WIDTH=320.0;
    float   OPENGLVIEW_PORTRAIT_HEIGHT=180.0;
    
    float   OPENGLVIEW_LANDSCAPE_STARTX=0.0;
    float   OPENGLVIEW_LANDSCAPE_STARTY=25.0;
    float   OPENGLVIEW_LANDSCAPE_WIDTH=480.0;
    float   OPENGLVIEW_LANDSCAPE_HEIGHT=270.0;
    
    float   ACTIVITYINDICATORVIEW_PORTRAIT_STARTX=145.0;
    float   ACTIVITYINDICATORVIEW_PORTRAIT_STARTY=60.0;
    float   ACTIVITYINDICATORVIEW_PORTRAIT_WIDTH=30.0;
    float   ACTIVITYINDICATORVIEW_PORTRAIT_HEIGHT=30.0;
    
    float   ACTIVITYINDICATORVIEW_LANDSCAPE_STARTX=195.0;
    float   ACTIVITYINDICATORVIEW_LANDSCAPE_STARTY=145.0;
    float   ACTIVITYINDICATORVIEW_LANDSCAPE_WIDTH=30.0;
    float   ACTIVITYINDICATORVIEW_LANDSCAPE_HEIGHT=30.0;
    
    float   TITLEVIEW_PORTRAIT_STARTX =245;
    float   TITLEVIEW_LANDSCAP_STARTX =405;
    float   TITLEVIEW_PORTRAIT_STARTY =65;
    float   TITLEVIEW_LANDSCAP_STARTY =26;
    

    
    float   RECORDBEATIMAGE_PRORAIT_STARTX=250.0;
    float   RECORDTIMELABEL_PRORAIT_STARTX=260.0;
    
    float   RECORDBEATIMAGE_LANDSCAPE_STARTX=420.0;
    float   RECORDTIMELABEL_LANDSCAPE_STARTX=430.0;
    
    
    //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
    if([self getIOSVersion] !=70)
    {
        OPENGLVIEW_PORTRAIT_STARTY=80.0;
        TITLEVIEW_PORTRAIT_STARTY =25;

    }

    
    if(screenSize.height==568)
    {
        
        OPENGLVIEW_PORTRAIT_STARTX=0.0;
        OPENGLVIEW_PORTRAIT_STARTY=180.0;
        OPENGLVIEW_PORTRAIT_WIDTH=320.0;
        OPENGLVIEW_PORTRAIT_HEIGHT=180.0;
        
        OPENGLVIEW_LANDSCAPE_STARTX=0.0;
        OPENGLVIEW_LANDSCAPE_STARTY=0.0;
        OPENGLVIEW_LANDSCAPE_WIDTH=568.0;
        OPENGLVIEW_LANDSCAPE_HEIGHT=320.0;
        
        ACTIVITYINDICATORVIEW_PORTRAIT_STARTX=145.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_STARTY=70.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_WIDTH=30.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_HEIGHT=30.0;
        
        ACTIVITYINDICATORVIEW_LANDSCAPE_STARTX=268.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_STARTY=145.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_WIDTH=30.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_HEIGHT=30.0;
        
        TITLEVIEW_PORTRAIT_STARTX =245;
        TITLEVIEW_LANDSCAP_STARTX =493;
        TITLEVIEW_PORTRAIT_STARTY =140;
        TITLEVIEW_LANDSCAP_STARTY =1;
        

        
        RECORDBEATIMAGE_PRORAIT_STARTX=250.0;
        RECORDTIMELABEL_PRORAIT_STARTX=260.0;
        
        RECORDBEATIMAGE_LANDSCAPE_STARTX=508.0;
        RECORDTIMELABEL_LANDSCAPE_STARTX=518.0;
        
        
        //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
        if([self getIOSVersion] !=70)
        {
            OPENGLVIEW_PORTRAIT_STARTY=120.0;
            TITLEVIEW_PORTRAIT_STARTY =25;

        }
        
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        OPENGLVIEW_PORTRAIT_STARTX=0.0;
        OPENGLVIEW_PORTRAIT_STARTY=240.0;
        OPENGLVIEW_PORTRAIT_WIDTH=768.0;
        OPENGLVIEW_PORTRAIT_HEIGHT=432.0;
        
        OPENGLVIEW_LANDSCAPE_STARTX=0.0;
        OPENGLVIEW_LANDSCAPE_STARTY=96.0;
        OPENGLVIEW_LANDSCAPE_WIDTH=1024.0;
        OPENGLVIEW_LANDSCAPE_HEIGHT=576.0;
        
        ACTIVITYINDICATORVIEW_PORTRAIT_STARTX=370.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_STARTY=200.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_WIDTH=30.0;
        ACTIVITYINDICATORVIEW_PORTRAIT_HEIGHT=30.0;
        
        ACTIVITYINDICATORVIEW_LANDSCAPE_STARTX=500.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_STARTY=270.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_WIDTH=30.0;
        ACTIVITYINDICATORVIEW_LANDSCAPE_HEIGHT=30.0;
        
        TITLEVIEW_PORTRAIT_STARTX =688;
        TITLEVIEW_LANDSCAP_STARTX =940;
        TITLEVIEW_PORTRAIT_STARTY =180;
        TITLEVIEW_LANDSCAP_STARTY =60;
      
        
        RECORDBEATIMAGE_PRORAIT_STARTX=704.0;
        RECORDTIMELABEL_PRORAIT_STARTX=714.0;
        
        RECORDBEATIMAGE_LANDSCAPE_STARTX=960.0;
        RECORDTIMELABEL_LANDSCAPE_STARTX=970.0;
        
        
        //7.1版本坐标不一致，从导航栏下开始计算frame.origin.y=0,y上移动64。
        if([self getIOSVersion] !=70)
        {
            OPENGLVIEW_PORTRAIT_STARTY=180.0;
            TITLEVIEW_PORTRAIT_STARTY =120;

        }
    }
   
    [scrollView setZoomScale:1.0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recordModeDialog_makeMainDialogDisappeared" object:nil];
    if(toInterfaceOrientation==UIDeviceOrientationPortrait)
    {
        __currentDeviceOrientation=DEVICE_ORIENTATION_PORTRAIT;
 
        [openGLESView setFrame:CGRectMake(OPENGLVIEW_PORTRAIT_STARTX, OPENGLVIEW_PORTRAIT_STARTY, OPENGLVIEW_PORTRAIT_WIDTH, OPENGLVIEW_PORTRAIT_HEIGHT)];

        [self.navigationController.navigationBar setHidden:NO];
        [[UIApplication sharedApplication ]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        [activityIndicatorView setFrame:CGRectMake(ACTIVITYINDICATORVIEW_PORTRAIT_STARTX,ACTIVITYINDICATORVIEW_PORTRAIT_STARTY,ACTIVITYINDICATORVIEW_PORTRAIT_WIDTH,ACTIVITYINDICATORVIEW_PORTRAIT_HEIGHT)];
        
        [titleView setFrame:CGRectMake(TITLEVIEW_PORTRAIT_STARTX, TITLEVIEW_PORTRAIT_STARTY, 75, 15)];




    }
    else if((toInterfaceOrientation==UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation==UIDeviceOrientationLandscapeRight))
    {

         __currentDeviceOrientation=DEVICE_ORIENTATION_LANDSCAP;
        [self.navigationController.navigationBar setHidden:YES];
    
        [openGLESView setFrame:CGRectMake(OPENGLVIEW_LANDSCAPE_STARTX, OPENGLVIEW_LANDSCAPE_STARTY, OPENGLVIEW_LANDSCAPE_WIDTH, OPENGLVIEW_LANDSCAPE_HEIGHT)];

        
        [[UIApplication sharedApplication ]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        [activityIndicatorView setFrame:CGRectMake(ACTIVITYINDICATORVIEW_LANDSCAPE_STARTX,ACTIVITYINDICATORVIEW_LANDSCAPE_STARTY,ACTIVITYINDICATORVIEW_LANDSCAPE_WIDTH,ACTIVITYINDICATORVIEW_LANDSCAPE_HEIGHT)];
        [titleView setFrame:CGRectMake(TITLEVIEW_LANDSCAP_STARTX, TITLEVIEW_LANDSCAP_STARTY, 75, 15)];

        
        
    }

}


- (void)verifyConnectionStatus
{

}



- (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height {
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    
    
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    
    
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
    
    return [[img copy] autorelease];
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0];
    }
 
    return [[documentsPath stringByAppendingPathComponent:relativePath] retain];
}

- (void)saveImageToFile:(UIImage *)image :(NSString *)fileName {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgFullName = [self pathForDocumentsResource:fileName];
    
    [imgData writeToFile:imgFullName atomically:YES];
    [imgFullName release];
}

- (NSString *)directoryPath {
    
	if (!directoryPath) {
        
		directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Library"];
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directoryPath = [[dirs objectAtIndex:0] retain];
    }
	return directoryPath;
}

- (void)snapshot:(id)sender
{
    if(!updateVideoIsReady){
        return;
    }
    if(openGLESView!=nil)
    {
        UIImage* snapshotImage=[openGLESView snapshotPicture];
        if(snapshotImage!=nil)
        {
            NSDateFormatter *dateFormatter0 = [[NSDateFormatter alloc] init];
            [dateFormatter0 setDateFormat:@"yyMMddHHmmssAA"];
            NSString *currentDateStr0 = [dateFormatter0 stringFromDate:[NSDate date]];
            
            NSString *imgName = [NSString stringWithFormat:@"%@.jpg",currentDateStr0];

            
            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr1 = [dateFormatter1 stringFromDate:[NSDate date]];
            
            [self saveImageToFile:snapshotImage :imgName];
            
            if (database != NULL) {
                if (![database executeUpdate:@"INSERT INTO snapshotTB(dev_uid, file_path, user,time) VALUES(?,?,?,?)", camera.uid, imgName,G_loginAccountName, currentDateStr1]){
                    NSLog(@"Fail to add snapshot to database.");
                }
            }
            
            [[iToast makeText:NSLocalizedString(@"Snapshot saved", @"")] showFromView:openGLESView];

        }
    }

    
}

- (void)playSnapshotSound
{

    SystemSoundID sound=kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(sound);
    
}



//退出截取最后一帧图片
- (void)onBackButtonSelected:(id)sender
{

    //截取缩略图.
    if(updateVideoIsReady)
    {

        if(G_loginAccountName!=nil)
        {
            NSString *imgName = [NSString stringWithFormat:@"%@-%@.jpg", G_loginAccountName,camera.uid];
            if(openGLESView!=nil)
            {
                UIImage* snapshotImage=[openGLESView snapshotPicture];
                if(snapshotImage!=nil)
                {
                    [self saveImageToFile:snapshotImage :imgName];
                }
                
            }
        }

        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Camera Delegate Methods
- (void)camera:(Camera *)_camera didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{

    if (_camera == camera && type == IOTYPE_USER_IPCAM_DEVINFO_RESP)
    {
        
        SMsgAVIoctrlDeviceInfoResp *structDevInfo = (SMsgAVIoctrlDeviceInfoResp*)data;
        self.sdCardSize = structDevInfo->total;

    }
    
    if (_camera == camera && type == IOTYPE_USER_IPCAM_SETRECORD_RESP)
    {
        /* 
         
        SMsgAVIoctrlSetRecordResp *resp = (SMsgAVIoctrlSetRecordResp *) data;
        
        if(resp->result==1)//设备录像SD卡出错
        {
            isRecordingVideo=FALSE;
            currentRecordType=CURRENT_RECORDTYPE_NONE;
            [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
            [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateHighlighted];
            [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateSelected];
            [[iToast makeText:NSLocalizedString(@"SDCard error", @"")] showFromView:self.view];
        }
        

         if(resp->result==0)//设备正在进行录像.
         {
         
         [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateNormal];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateHighlighted];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateSelected];
         isRecordingVideo=TRUE;
         currentRecordType=CURRENT_RECORDTYPE_SDCARD;
         }
         else if(resp->result==1)//设备录像SD卡出错
         {
         isRecordingVideo=FALSE;
         currentRecordType=CURRENT_RECORDTYPE_NONE;
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateHighlighted];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateSelected];
         [[iToast makeText:NSLocalizedString(@"SDCard error", @"")] showFromView:self.view];
         }
         else if(resp->result==2)//设备录像已经停止.
         {
         isRecordingVideo=FALSE;
         currentRecordType=CURRENT_RECORDTYPE_NONE;
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateHighlighted];
         [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateSelected];
         }
         */
        
        
    }

    
    
}
- (void)camera:(Camera *)camera_ checkStatus_reConnectSesssion:(NSInteger)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];
    /*
    if (camera_ == camera) 
    {
        
        [self verifyConnectionStatus];
        updateVideoIsReady=FALSE;
        if (status == CONNECTION_STATE_TIMEOUT) {
            
            [camera stopShow];
            [camera stopSoundToDevice];
            [camera stopSoundToPhone];
            
            [camera stopConnectedSession];
            
            [self unactiveAudioSession];
            
            [camera connectWithUID:camera.uid];
            [camera startShow];
            
            [self activeAudioSession];
            
            if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone];
            if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice];
            
        }

    }
    [activityIndicatorView stopAnimating];
     */
}

- (void)camera:(Camera *)camera_ connect_updateConnectIndex4SessionStates:(NSInteger)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];
    
    /*
    if (camera_ == camera)
    {
        updateVideoIsReady=FALSE;

        
        [self verifyConnectionStatus];
        
        if (status == CONNECTION_STATE_WRONG_PASSWORD)
        {
            
            [camera stopConnectedSession];
            
            if (wrongPwdRetryTime++ < 3) {
                
                // show change password dialog
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Correct the wrong password", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), NSLocalizedString(@"OK", nil), nil];
                [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                [alert show];
                [alert release];
            }
            
        } else if (status == CONNECTION_STATE_CONNECTED)
        {
            
            
        } else if (status == CONNECTION_STATE_CONNECTING)
        {
            
            
        } else if (status == CONNECTION_STATE_TIMEOUT)
        {
            
            
            [camera stopShow];
            [camera stopSoundToDevice];
            [camera stopSoundToPhone];
            [self unactiveAudioSession];
            
            [camera connectWithUID:camera.uid];
            [camera startShow];
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrl:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrl:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
            SMsgAVIoctrlTimeZone s3={0};
            s3.cbSize = sizeof(s3);
            [camera sendIOCtrl:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
            
            
            [self activeAudioSession];
            
            if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone];
            if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice];
            
        } else
        {
     
            
        }
    }
    [activityIndicatorView stopAnimating];
     */
}



- (void)camera:(Camera *)camera_ frameInfoWithVideoBPS:(NSInteger)videoBps
{
    
    [networkSpeed_Label setText:[NSString stringWithFormat:@"%d",videoBps/1024]];
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 1) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString *acc = @"admin";
        NSString *pwd = textField.text;
        
        if (database != NULL) {
            if (![database executeUpdate:@"UPDATE device SET view_pwd=? WHERE dev_uid=?", pwd, camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
        
        [camera setViewAcc:acc];
        [camera setViewPwd:pwd];
        [camera startShow];

        
        [self activeAudioSession];
        
        if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
            [camera startSoundToPhone];
            

        }
        
        if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
            [camera startSoundToDevice];
            

        }
    }
}



#pragma mark - AudioSession implementations
- (void)activeAudioSession
{
    OSStatus error;
    
    UInt32 category = kAudioSessionCategory_LiveAudio;
    
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        category = kAudioSessionCategory_LiveAudio;
        NSLog(@"kAudioSessionCategory_LiveAudio");
    }
    
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
        category = kAudioSessionCategory_PlayAndRecord;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
    }
    
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error) printf("couldn't set audio category!");
    
    error = AudioSessionSetActive(true);
    if (error) printf("AudioSessionSetActive (true) failed");
}

- (void)unactiveAudioSession {
    
    AudioSessionSetActive(false);
}

#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{


    [openGLESView setHidden:YES];
    [titleView setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    [camera stopShow];
    [camera stopSoundToDevice];
    [camera stopSoundToPhone];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];


}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    /*
    [camera startShow];
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE)
        [camera startSoundToDevice];
    if (selectedAudioMode == AUDIO_MODE_SPEAKER)
        [camera startSoundToPhone];
    
    [self dismissViewControllerAnimated:YES completion:nil];
     */
}




#pragma mark  VideoRecorder delegate
- (void)writeRecordMediaToDatabase:(NSString *)path withDateTime:(NSString *)dateTime
{
}


- (void)cameraUpdateDecodedH264FrameData:(H264YUV_Frame*)yuvFrame
{
    
    if([activityIndicatorView isAnimating])
    {
        [activityIndicatorView stopAnimating];
    }
    [videoWH_Label setText:[NSString stringWithFormat:@"%dx%d",yuvFrame->width,yuvFrame->height]];
    [openGLESView render:yuvFrame];
    updateVideoIsReady=TRUE;
    
    
}


- (void)cameraPTZ_Stop
{
    
    SMsgAVIoctrlPtzCmd request;
    memset(&request, 0, sizeof(request));
    request.channel = 0;
    request.control = AVIOCTRL_PTZ_STOP;
    request.speed = PT_SPEED;
    request.point = 0;
    request.limit = 0;
    request.aux = 0;
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)&request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
    
}

- (void)cameraPTZ_Left
{
    
    SMsgAVIoctrlPtzCmd request;
    memset(&request, 0, sizeof(request));
    request.channel = 0;
    request.control = AVIOCTRL_PTZ_LEFT;
    request.speed = PT_SPEED;
    request.point = 0;
    request.limit = 0;
    request.aux = 0;
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)&request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
    
    
}
- (void)cameraPTZ_Right
{
    
    SMsgAVIoctrlPtzCmd request;
    memset(&request, 0, sizeof(request));
    request.channel = 0;
    request.control = AVIOCTRL_PTZ_RIGHT;
    request.speed = PT_SPEED;
    request.point = 0;
    request.limit = 0;
    request.aux = 0;
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)&request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
}
- (void)cameraPTZ_Up
{
    SMsgAVIoctrlPtzCmd request;
    memset(&request, 0, sizeof(request));
    request.channel = 0;
    request.control = AVIOCTRL_PTZ_UP;
    request.speed = PT_SPEED;
    request.point = 0;
    request.limit = 0;
    request.aux = 0;
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)&request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
}
- (void)cameraPTZ_Down
{
    
    SMsgAVIoctrlPtzCmd request;
    memset(&request, 0, sizeof(request));
    request.channel = 0;
    request.control = AVIOCTRL_PTZ_DOWN;
    request.speed = PT_SPEED;
    request.point = 0;
    request.limit = 0;
    request.aux = 0;
    
    [camera sendIOCtrl:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)&request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
}

//单点触摸视频,显示/隐藏toolBar
- (void)singleTouchOnOpenGLESView
{
            
   
    
}
- (int)getIOSVersion
{
    float versionValue= [[[UIDevice currentDevice] systemVersion] floatValue];
    //NSLog(@"IOS VERSION: %d\n",(int)(versionValue*10));
    return (int)(versionValue*10);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return openGLESView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{

}

- (void)scrollViewDidZoom:(UIScrollView *)_zoomView
{

    CGRect screenRect=[[UIScreen mainScreen] bounds];
    
    CGFloat xcenter = _zoomView.center.x;
    CGFloat ycenter = _zoomView.center.y;
    
    if(__currentDeviceOrientation==DEVICE_ORIENTATION_PORTRAIT)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            if([self getIOSVersion] !=70)
            {
                ycenter=ycenter-60;
            }
        }
        else
        {
            if (screenRect.size.height==568)
            {
                if([self getIOSVersion] !=70)
                {
                    ycenter=ycenter-40;
                }
            }
            else
            {
                if([self getIOSVersion] !=70)
                {
                    ycenter=ycenter-50;
                }
            }
        }
    }

    xcenter = _zoomView.contentSize.width > _zoomView.frame.size.width ? _zoomView.contentSize.width/2 : xcenter;
    ycenter = _zoomView.contentSize.height > _zoomView.frame.size.height ? _zoomView.contentSize.height/2 : ycenter;
    
    //printf("SCROLLVIEW ZOOM: %f %f %f %f\n",xcenter,ycenter,_zoomView.contentSize.width/2,_zoomView.contentSize.height/2);
    
    [openGLESView  setCenter:CGPointMake(xcenter, ycenter)];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{

}

- (void)selectRecrod:(id)sender
{
    if(!updateVideoIsReady){
        return;
    }

    UIButton* button=(UIButton*)sender;
    
    if(button.tag==0){
        button.tag=1;
        [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateHighlighted];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateSelected];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startRecordingVideo" object:nil];
        
    
    }
    else if(button.tag==1)
    {
        button.tag=0;
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateHighlighted];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateSelected];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];
    }
}
- (void)selectAudio:(id)sender
{
    if(!updateVideoIsReady){
        return;
    }
    
    UIButton* button=(UIButton*)sender;
    
    if(button.tag==0){
        button.tag=1;
        
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listenning.png"] forState:UIControlStateNormal];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listenning.png"] forState:UIControlStateSelected];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listenning.png"] forState:UIControlStateHighlighted];
        if(camera!=nil){
            
            selectedAudioMode=AUDIO_MODE_SPEAKER;
            
            [camera startSoundToPhone];
            [self activeAudioSession];
            
        }

    }
    else if(button.tag==1)
    {
        button.tag=0;
        
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateNormal];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateSelected];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"listen.png"] forState:UIControlStateHighlighted];
        if(camera!=nil){
            
            selectedAudioMode=AUDIO_MODE_OFF;
            [camera stopSoundToPhone];
            [self unactiveAudioSession];
            
        }
        
    }
    
    
}



@end
