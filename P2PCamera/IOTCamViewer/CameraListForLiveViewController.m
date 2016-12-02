//
//  CameraListForLiveViewController.m
//  IOTCamViewer
//
//  Created by chenchao on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "iToast.h"
#import <QuartzCore/QuartzCore.h>
#import "CameraListForLiveViewController.h"
#import "CameraLiveViewController.h"




@implementation CameraListForLiveViewController

@synthesize scrollView;
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize camListVCDelegate;

- (id)init
{
    if (self=[super init])
    {

        currentTouchIndex=-1;
        _userAccountDialog=nil;
        touchLocationPoint=CGPointZero;
        
 
        
        float   SIGNALVIEWCONTROLLERSHEIGHT         =88;
        float   SIGNALVIEWCONTROLLERSWIDTH          =156;
        float   SCROLLVIEW_WIDTH                    =320.0;
        float   SCROLLVIEW_HEIGHT                   =480.0;
        float   GRIDVIEW_STEP_HEIGHT                =90.0;
        float   AXIS_POSITION                       =161.0;
        //iphone5
        if([[UIScreen mainScreen] bounds].size.height>=568)
        {
            SCROLLVIEW_HEIGHT=568;
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            SIGNALVIEWCONTROLLERSHEIGHT         =212;
            SIGNALVIEWCONTROLLERSWIDTH          =378;
            SCROLLVIEW_WIDTH                    =768;
            SCROLLVIEW_HEIGHT                   =856;
            GRIDVIEW_STEP_HEIGHT                =213;
            AXIS_POSITION                       =384.0;
        }


        self.navigationItem.title = NSLocalizedString(@"Device List", @"");

        
        
        
        scrollView=[[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [scrollView setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
        scrollView.delegate=self;
        [scrollView setAutoresizesSubviews:YES];
        [scrollView setMultipleTouchEnabled:YES];
        [scrollView setContentMode:UIViewContentModeScaleToFill];
        
        
        singleVCArrays=[[NSMutableArray alloc] initWithCapacity:16];
                        

        if(camera_list)
        {
            int aixisX=0, aixisY=0;
            
            for(int i=0; i<camera_list.count+1; i++)
            {
                
                if(i%2==0)
                {
                    aixisX=2; // singleFrameView start point x
                    aixisY=4+GRIDVIEW_STEP_HEIGHT*i/2; // singleFrameView start point y
                }
                else{
                    aixisX=AXIS_POSITION;  //第二个singleFrameView x坐标.
                }
                //printf("====================================%d %d\n",aixisX,aixisY);
                
                
                //设置小窗口显示...
                if((camera_list!=nil)&&((camera_list.count>i)))
                {
                    
                    SingleFrameView* singleFrameView=[[SingleFrameView alloc] initWithFrame:CGRectMake(aixisX, aixisY, SIGNALVIEWCONTROLLERSWIDTH, SIGNALVIEWCONTROLLERSHEIGHT)];
                    [singleFrameView setSingleFrameViewIndex:i];
                    singleFrameView.singleTouchPointDelegate=self;
                    [scrollView addSubview:singleFrameView];
                    Camera* camera=[camera_list objectAtIndex:i];
                    camera.cameraDelegate=self;
                    
                    //设置名称
                    NSString* deviceName=camera.name;
                    [singleFrameView setDeviceName: deviceName];
                    
                    //设置最后一帧截图
                    if(G_loginAccountName!=nil)
                    {
                        NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@-%@.jpg",G_loginAccountName, camera.uid]];
                        
                        [singleFrameView updateImage:imgFullName];
                        [imgFullName release];
                    }
                 
                    //设置连接状态.
                    BOOL connectState=[camera getConnectionState];
                    [singleFrameView setNetworkConnectedStatus:connectState];
                    
                    //添加到总的ViewControllers中.
                    [singleVCArrays addObject:singleFrameView];
                    [singleFrameView release];
                    
                }
                else if(i==camera_list.count)//添加设备按钮......
                {
                    addCamFrameView=[[AddCamSingleFrameView alloc] initWithFrame:CGRectMake(aixisX, aixisY, SIGNALVIEWCONTROLLERSWIDTH, SIGNALVIEWCONTROLLERSHEIGHT)];
                    [addCamFrameView setImage:[UIImage imageNamed:@"addDevice_bg.png"]];
                    [addCamFrameView setUserInteractionEnabled:YES];
                    addCamFrameView.addCamSingleFrameDelegate=self;
                    
                    [scrollView addSubview:addCamFrameView];
                    [addCamFrameView release];
                }
                


                
            }
            
            if(((4+GRIDVIEW_STEP_HEIGHT)*(camera_list.count/2+1))>=SCROLLVIEW_HEIGHT)
            {
                [scrollView setContentSize:CGSizeMake( SCROLLVIEW_WIDTH , (4+GRIDVIEW_STEP_HEIGHT)*(camera_list.count/2+1))];
            }
            else
            {
                [scrollView setContentSize:CGSizeMake(SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
            }
            
            
        }
        
        self.view =scrollView;

        
        //添加camera后刷新主窗口排列显示.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCameraAndRefreshViewAlignment) name:@"msgAddCameraAndrefreshWindow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAlignmentGridViewWindow) name:@"RefreshCameraGridWindow" object:nil];
    
        
        
        [self setupStrings];
        [self addPullToRefreshHeader];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
    }
    return self;
}




- (void)dealloc
{
    if(singleVCArrays)
    {
        [singleVCArrays removeAllObjects];
    }

    [scrollView release];
    [refreshHeaderView release];
    [refreshLabel release];
    [refreshArrow release];
    [refreshSpinner release];
    [textPull release];
    [textRelease release];
    [textLoading release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"msgAddCameraAndrefreshWindow" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshCameraGridWindow" object:nil];

   
     
    
    [super dealloc];
}

- (BOOL)shouldAutorotate
{
    return false;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication ]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    
    currentTouchIndex=-1;
    touchLocationPoint=CGPointZero;
    for (Camera *myCamera in camera_list)
    {
        myCamera.cameraDelegate = self;
    }
    [self refreshAlignmentGridViewWindow];

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
}





- (NSString *) pathForDocumentsResource:(NSString *) relativePath
{
    
     NSString* documentsPath = nil;
    
    if (nil == documentsPath)
    {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0];
    }

    return [[documentsPath stringByAppendingPathComponent:relativePath] retain];
}
//删除设备，以及最后一帧图像
- (void)deleteCamera:(NSString *)uid {
    
    if(appAccessModeGlobal==APPLICATIONACCESSMODE_LOCAL)
    {
        if (database != NULL) {
            
            if (![database executeUpdate:@"DELETE FROM device where dev_uid=?", uid]) {
                NSLog(@"Fail to remove device from database.");
            }
        }
    }
    if(G_loginAccountName!=nil)
    {
        /* delete camera lastframe snapshot file */
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *imgName = [NSString stringWithFormat:@"%@-%@.jpg", uid,G_loginAccountName];
        NSString* pathString=[self pathForDocumentsResource: imgName];
        
        [fileManager removeItemAtPath:pathString error:NULL];
        
        [pathString release];
    }

    

}
//从数据库中删除设备的抓图.
- (void)deleteSnapshotRecords:(NSString *)uid {
        
    if (database != NULL) {
        //删除本地文件
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshotTB WHERE dev_id=? AND user=?", uid,G_loginAccountName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next])
        {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            NSString *pathString=[self pathForDocumentsResource: filePath];
            [fileManager removeItemAtPath:pathString error:NULL];        
            NSLog(@"camera(%@) snapshot removed", filePath);
            [pathString release];
        }
        
        [rs close];        
        //删除数据库纪录.
        [database executeUpdate:@"DELETE FROM snapshotTB WHERE dev_uid=? AND user=?", uid,G_loginAccountName];
    }  
}

- (void)deleteVideoRecords:(NSString *)uid {
    
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM recordMovieTB WHERE dev_id=? AND user=?", uid,G_loginAccountName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //printf("--------------DELETE MOVIE-------------->>>>>\n");
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            NSString* pathString=[self pathForDocumentsResource: filePath];
            [fileManager removeItemAtPath:pathString error:NULL];
            NSLog(@"camera(%@) video removed\n", filePath);
            [pathString release];
        }
        
        [rs close];
        
        [database executeUpdate:@"DELETE FROM recordMovieTB WHERE dev_uid=? AND user=?", uid,G_loginAccountName];
    }
}



//长按事件的实现
- (void) onLongPressTouchSelected:(UILongPressGestureRecognizer *)gestureRecognizer
{

    SingleFrameView* singleView=(SingleFrameView*)[gestureRecognizer view];
    
    if(singleView==nil)
    {
        return;
    }
     CGRect singleViewRect=singleView.frame;
    CGFloat listDlgLocation_Y=0.0;
    
    if(touchLocationPoint.y>=0)
    {
        listDlgLocation_Y=singleViewRect.origin.y-touchLocationPoint.y;
    }
    else
    {
        listDlgLocation_Y=singleViewRect.origin.y;
    }

    int index=singleView.singleFrameViewIndex;
    
    if(index>=0)
    {
        currentTouchIndex=index;
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            //横向弹出框
            //ipad
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                ListDialog* dialog=[[ListDialog alloc] initWithFrame:CGRectMake(singleViewRect.origin.x+17.5 ,listDlgLocation_Y+85, 345 , 54)];
                if(((currentTouchIndex+1)%2)==0)//偶数窗口
                {

                    [dialog setFrame:CGRectMake(singleViewRect.origin.x+17.5,listDlgLocation_Y+105, 345 , 54)];
                    [dialog  setDialogBackGroundImage:@"longPressDlg_right_5.png"];
                }
                else //奇数窗口
                {
                    [dialog setFrame:CGRectMake(singleViewRect.origin.x+17.5 ,listDlgLocation_Y+105, 345 , 54)];
                    [dialog  setDialogBackGroundImage:@"longPressDlg_left_5.png"];
                }
                dialog.listDialogDelegate=self;
                
                [dialog show];
            }
            else //iphone
            {
                ListDialog* dialog=[[ListDialog alloc] initWithFrame:CGRectMake(singleViewRect.origin.x+5 ,listDlgLocation_Y+85, 305 , 47)];
                if(((currentTouchIndex+1)%2)==0)//偶数窗口
                {
                    [dialog setFrame:CGRectMake(singleViewRect.origin.x-155,listDlgLocation_Y+85, 305 , 47)];
                       [dialog  setDialogBackGroundImage:@"longPressDlg_right_5.png"];
                }
                else //奇数窗口
                {
                    [dialog setFrame:CGRectMake(singleViewRect.origin.x+5 ,listDlgLocation_Y+85, 305 , 47)];
                    [dialog  setDialogBackGroundImage:@"longPressDlg_left_5.png"];
                }
                dialog.listDialogDelegate=self;
            
                [dialog show];
            }

            

        }
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            //NSLog(@"UIGestureRecognizerStateChanged");
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            //NSLog(@"UIGestureRecognizerStateEnded");
            
        }
        
    }
    
}

//打开实时视频
- (void)onSingleTouchPointSelected:(NSSet *)touches
{
    UITouch *touch=[touches anyObject];
    
    SingleFrameView* touchedView=(SingleFrameView*)touch.view;
    if(touchedView==nil)
    {
        return;
    }
    NSInteger index=touchedView.singleFrameViewIndex;

    if(index>=0)
    {
        currentTouchIndex=index;
        Camera* camera=[camera_list objectAtIndex:index];
        if([camera getConnectionState]==CONNECTION_STATE_CONNECTED)
        {
            
            CameraLiveViewController *controller = [[CameraLiveViewController alloc] init];
            camera.cameraDelegate=controller;
            controller.camera = camera;
            // controller.selectedAudioMode = AUDIO_MODE_SPEAKER;

            
            PopupNavigationController*  popUpNavigationController=[[PopupNavigationController alloc] initWithRootViewController:controller];
            [popUpNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar_bg.png"] forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:popUpNavigationController animated:YES completion:nil];
            
            [controller release];
            [popUpNavigationController release];
        }
        
    }
}

/****************************************************************/
/*              addCamSingleFrameView 代理实现                   */
/****************************************************************/

- (void)onAddCamSingleFrameViewTouched
{
    
//    APSearchCamViewController* controller=[[APSearchCamViewController alloc] initWithStyle:UITableViewStylePlain];
//    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
    
    AddCameraController* controller=[[AddCameraController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];

}




/****************************************************************/
/*              长按弹出的dialog上面的事件代理实现                   */
/****************************************************************/

// 设备设置.
- (void)onDeviceSettingsButtonClicked
{

   

}

//本地影像
- (void)onLocalRecordButtonSelected
{

}

// 远程事件
- (void)onRemoteEventsButtonSelected
{

}


//删除设备
- (void)onDeleteDeviceButtonSelected
{
    CGSize screenSize=[[UIScreen mainScreen] bounds].size;

    MessageDialog* msgDialog=[[MessageDialog alloc] initWithFrame:CGRectMake((screenSize.width-234)/2, screenSize.height/2-60, 234, 121)];
    msgDialog.messageDialogDelegate=self;
    [msgDialog show];
    
}

- (void)deleteSingleFrameWindow
{
    //停止camera连接
    Camera* camera=[camera_list objectAtIndex:currentTouchIndex];
    
    if(camera)
    {
        [camera stopConnectedSession];
        camera.cameraDelegate=nil;
        
        NSString* uid = camera.uid;
        

        if (uid != nil)
        {
            
            // 从数据库删除cam以及截屏....
            //[self deleteCamera:uid];
            [self deleteSnapshotRecords:uid];
            [self deleteVideoRecords:uid];
            //本地模式删除设备.
            if(appAccessModeGlobal==APPLICATIONACCESSMODE_LOCAL)
            {
                [self deleteCamera:uid];
                
            }//服务器模式删除设备.
            else if(appAccessModeGlobal==APPLICATIONACCESSMODE_NETWORK)
            {
                
                
                 // 从推送服务器删除推送记录.....
                 dispatch_queue_t unRegQueue = dispatch_queue_create("apns-unreg_client", NULL);
                 dispatch_async(unRegQueue, ^{
                 if (true) {
                 NSError *error = nil;
                 NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
                 NSString *hostString = @"http://www.p2picamera.com/iPhonePush/apns.php";
                 NSString *argsString = @"%@?cmd=unreg_mapping&token=%@&uid=%@&appid=%@";
                 NSString *getURLString = [NSString stringWithFormat:argsString, hostString, deviceTokenString, uid, appidString];
                 NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
                 
                 if (error != NULL) {
                 NSLog(@"%@",[error localizedDescription]);
                 }
                 NSLog(@"%@", registerResult);
                 }
                 });
                 
                 dispatch_release(unRegQueue);
                
                // 从服务器数据库删除设备.
                dispatch_queue_t deleteQueue = dispatch_queue_create("device-deleteServerDB", NULL);
                dispatch_async(deleteQueue, ^{
                    if (uid!= nil) {
                        NSError *error = nil;
                        
                        NSString* deleteString=[NSString stringWithFormat:@"http://www.p2picamera.com/UserAccount/deviceEdit.php?cmd=delete&deviceUID=%@",uid];
                        
                        NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:deleteString] encoding:NSUTF8StringEncoding error:&error];
                        
                        NSLog(@"DELETE TO DB SERVER:%@", registerResult);
                    }
                });
                dispatch_release(deleteQueue);
            }
            
        }
        //删除全局标量camera_list中的camera引用.
        [camera_list removeObjectAtIndex:currentTouchIndex];
        
        
    }
    
    
    //删除singleVCArrays中的指定SingleFrameViewController
    if(singleVCArrays)
    {
        if(currentTouchIndex>=0)
        {
            SingleFrameView* singleFrameView=(SingleFrameView*)[singleVCArrays objectAtIndex:currentTouchIndex];
            
            [singleFrameView removeFromSuperview];
            //删除singleFrameViewController.
            [singleVCArrays removeObjectAtIndex:currentTouchIndex];
            singleFrameView=nil;
            
        }
        
    }
    //重新布局窗口.
    [self refreshAlignmentGridViewWindow];
    
    //[[iToast makeText:NSLocalizedString(@"Delete camera success", @"")] showFromView:self.view];
}

- (void)onReconnectButtonSelected
{
    [self reconnectCameraAndupdate];
}

- (void)reconnectCameraAndupdate
{
    Camera *camera = [camera_list objectAtIndex:currentTouchIndex];
    
    if (camera != nil)
    {
        
        //NSString* uid=camera.uid;
        BOOL isConnecting=[camera isConnecting];
        
        if(!isConnecting)
        {
            [camera stopConnectedSession];
            [camera connect];
            
            [camera setConnectionState:CONNECTION_STATE_CONNECTING];
            [self refreshAlignmentGridViewWindow];

        }
         
    }
    
    
}

//MessgeDialog delegate
- (void)messageDialogOkSelected
{
    [self deleteSingleFrameWindow];
}
- (void)messageDialogCancelSelected
{
    
}

/****************************************************************/
/*              帐户 dialog 相关 事件代理实现                       */
/****************************************************************/

//添加设备.
- (void)userAccountDlg_AddDeviceButtonSelected
{
    AddCameraController* controller=[[AddCameraController alloc] init];

    [self.navigationController pushViewController:controller animated:YES];
    [controller release];

}
//添加设备后更新窗口.
- (void)addCameraAndRefreshViewAlignment
{
    NSLog(@"REFRESH ADD Camera.....%@",camera_list);
    float   SIGNALVIEWCONTROLLERSHEIGHT         =88;
    float   SIGNALVIEWCONTROLLERSWIDTH          =156;
    float   SCROLLVIEW_WIDTH                    =320.0;
    float   SCROLLVIEW_HEIGHT                   =480.0;
    float   GRIDVIEW_STEP_HEIGHT                =90.0;
    float   AXIS_POSITION                       =161.0;
    //iphone5
    if([[UIScreen mainScreen] bounds].size.height>=568)
    {
        SCROLLVIEW_HEIGHT=568;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        SIGNALVIEWCONTROLLERSHEIGHT         =212;
        SIGNALVIEWCONTROLLERSWIDTH          =378;
        SCROLLVIEW_WIDTH                    =768;
        SCROLLVIEW_HEIGHT                   =856;
        GRIDVIEW_STEP_HEIGHT                =213;
        AXIS_POSITION                       =384.0;
    }
    
    if(camera_list)
    {

        int aixisX=0, aixisY=0;
        
        int index=camera_list.count;
        if(index%2==0)
        {
            aixisX=2; // singleFrameView start point x
            aixisY=4+GRIDVIEW_STEP_HEIGHT*index/2; // singleFrameView start point y
        }
        else{
            aixisX=AXIS_POSITION;  //第二个singleFrameView x坐标.
        }
        
        SingleFrameView* singleFrameView=[[SingleFrameView alloc] initWithFrame:CGRectMake(aixisX, aixisY, SIGNALVIEWCONTROLLERSWIDTH, SIGNALVIEWCONTROLLERSHEIGHT)];
        singleFrameView.singleTouchPointDelegate=self;
        [singleFrameView setSingleFrameViewIndex:index];
        [scrollView addSubview:singleFrameView];
        
        [singleVCArrays addObject:singleFrameView];
        
    }

    //重新布局窗口
    [self refreshAlignmentGridViewWindow];

    
}
- (void)userAccountDlg_AccountSettingsSelected
{

}
- (void)userAccountDlg_AppInfoSelected
{


}
- (void)userAccountDlg_CancelSelected
{
    for (Camera *myCamera in camera_list)
    {
        myCamera.CameraDelegate = nil;
    }
    if([camListVCDelegate respondsToSelector:@selector(onCameraListViewControllerBackToLoginPage)])
    {
        [camListVCDelegate  onCameraListViewControllerBackToLoginPage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - CameraDelegate Methods
- (void)camera:(Camera *)camera_ connect_updateConnectSessionStates:(NSInteger)states
{
    
    [self refreshAlignmentGridViewWindow];

}

- (void)camera:(Camera *)camera_ connect_updateConnectIndex4SessionStates:(NSInteger)states
{
    if(states==CONNECTION_STATE_WRONG_PASSWORD)
    {
        [self refreshAlignmentGridViewWindow];
        [camera_ setConnectionState:CONNECTION_STATE_CONNECT_FAILED];
    }
    else if ((states == CONNECTION_STATE_TIMEOUT)||(states==CONNECTION_STATE_DISCONNECTED))
    {

        [self refreshAlignmentGridViewWindow];
    }
    else
    {
        [self refreshAlignmentGridViewWindow];
    }

}
- (void)camera:(Camera *)_camera didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)_size
{
    if(type == IOTYPE_USER_IPCAM_GET_SNAP_RESP)
    {
        if(camera_list)
        {
            for(int i=0; i<camera_list.count; i++)
            {
                Camera* camera=[camera_list objectAtIndex:i];
                if(camera==_camera)
                {
                    if(G_loginAccountName!=nil)
                    {
                        NSString *imgName = [NSString stringWithFormat:@"%@-%@.jpg", G_loginAccountName,camera.uid];
                        if(_size>0)
                        {
                            //NSLog(@"********%d  %@\n",_size,[self _getHexString:(char*)data Size:_size]);
                            UIImage* snapshotImage=[UIImage imageWithData:[NSData dataWithBytes:data length:_size]];
                            
                            if(snapshotImage!=nil)
                            {
                                //NSLog(@"------------00---->>>%d %@ %@\n",_size,camera.name,imgName);
                                [self saveImageToFile:snapshotImage :imgName];
                            }
                            
                        }
                    }

    
                }
            }
            [self refreshAlignmentGridViewWindow];
        }
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

- (void)saveImageToFile:(UIImage *)image :(NSString *)fileName {
                       
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgFullName = [self pathForDocumentsResource:fileName];
    
    [imgData writeToFile:imgFullName atomically:YES];
    [imgFullName release];
}

//checkstatus. 重连....
- (void)camera:(Camera *)camera_ checkStatus_reConnectSesssion:(NSInteger)status
{
    if(status!=CONNECTION_STATE_CONNECTED)
    {
        [camera_ stopConnectedSession];
        [camera_ connect];
    }
     [self refreshAlignmentGridViewWindow];
}

//苹果推送服务器...
- (void)camera:(Camera *)camera updateRemoteNotifications:(NSInteger)type EventTime:(long)time
{
   [self refreshAlignmentGridViewWindow];
}
//cam触发事件
- (void)camera:(Camera *)camera didReceiveNotifications:(NSInteger)type
{

    //[self refreshAlignmentGridViewWindow];
}
//拉刷新实现.
- (void)refreshSingleFrameView
{
    //刷新
      //NSLog(@"-------------------refresh picture-------------------------->\n");
    if(camera_list)
    {
        if(camera_list.count>0)
        {
            for(int i=0; i<camera_list.count; i++)
            {
                Camera* camera=[camera_list objectAtIndex:i];
                //设置连接状态.
                int connectState=[camera getConnectionState];
                if(connectState==CONNECTION_STATE_CONNECTED)
                {
                    int MsgType=IOTYPE_USER_IPCAM_GET_SNAP_REQ;
                    [camera sendIOCtrl:MsgType Data:(char*)&MsgType DataSize:sizeof(MsgType)];
                }
            }
            
        }

    }
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}


//重新布局窗口.(添加/删除设备使用).
- (void)refreshAlignmentGridViewWindow
{
  
    float   SIGNALVIEWCONTROLLERSHEIGHT         =88;
    float   SIGNALVIEWCONTROLLERSWIDTH          =156;
    float   SCROLLVIEW_WIDTH                    =320.0;
    float   SCROLLVIEW_HEIGHT                   =480.0;
    float   GRIDVIEW_STEP_HEIGHT                =90.0;
    float   AXIS_POSITION                       =161.0;
    //iphone5
    if([[UIScreen mainScreen] bounds].size.height>=568)
    {
        SCROLLVIEW_HEIGHT=568;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        SIGNALVIEWCONTROLLERSHEIGHT         =212;
        SIGNALVIEWCONTROLLERSWIDTH          =378;
        SCROLLVIEW_WIDTH                    =768;
        SCROLLVIEW_HEIGHT                   =856;
        GRIDVIEW_STEP_HEIGHT                =213;
        AXIS_POSITION                       =384.0;
    }
 
    if(camera_list)
    {
        int aixisX=0, aixisY=0;
        
        for(int i=0; i<camera_list.count+1; i++)
        {
            
            if(i%2==0)
            {
                aixisX=2; // singleFrameView start point x
                aixisY=4+GRIDVIEW_STEP_HEIGHT*i/2; // singleFrameView start point y
            }
            else{
                aixisX=AXIS_POSITION;  //第二个singleFrameView x坐标.
            }
            
            
            //设置小窗口显示...
            if((camera_list!=nil)&&(camera_list.count>i))
            {
                SingleFrameView* singleFrameView=(SingleFrameView *)[singleVCArrays objectAtIndex:i];
                if(singleFrameView)
                {
                    [singleFrameView setFrame:CGRectMake(aixisX, aixisY, SIGNALVIEWCONTROLLERSWIDTH, SIGNALVIEWCONTROLLERSHEIGHT)];
                    [singleFrameView setSingleFrameViewIndex:i];
                }
                
                Camera* myCamera=[camera_list objectAtIndex:i];
                //设置名称
                NSString* deviceName=myCamera.name;
                [singleFrameView setDeviceName: deviceName];
                
                //设置最后一帧截图
                if(G_loginAccountName!=nil)
                {
                    NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@-%@.jpg",G_loginAccountName, myCamera.uid]];
                    [singleFrameView updateImage:imgFullName];
                    [imgFullName release];
                }

                
                //设置连接状态.
                int connectState=[myCamera getConnectionState];
                [singleFrameView setNetworkConnectedStatus:connectState];
                
                NSInteger notifyNumbers=myCamera.remoteNotifications;
                [singleFrameView setRemoteNotificationsWithNumber:notifyNumbers];

            }
            else if(i==camera_list.count)//添加设备按钮......
            {
                [addCamFrameView setFrame:CGRectMake(aixisX, aixisY, SIGNALVIEWCONTROLLERSWIDTH, SIGNALVIEWCONTROLLERSHEIGHT)];
                [addCamFrameView setImage:[UIImage imageNamed:@"addDevice_bg.png"]];
                [addCamFrameView setUserInteractionEnabled:YES];
                addCamFrameView.addCamSingleFrameDelegate=self;
            }
        }
        
        if((4+GRIDVIEW_STEP_HEIGHT)*(camera_list.count/2+1)>=SCROLLVIEW_HEIGHT)
        {
            [scrollView setContentSize:CGSizeMake(SCROLLVIEW_WIDTH,(4+GRIDVIEW_STEP_HEIGHT)*(camera_list.count/2+1))];
        }
        else
        {
            [scrollView setContentSize:CGSizeMake(SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
        }
        
        CGRect visibleBounds = scrollView.bounds;    //得到当前UIScrollView在屏幕中显示区域相对于scrollview的位置
        touchLocationPoint=CGPointMake(visibleBounds.origin.x, visibleBounds.origin.y);
        
        
    }
  
}





//头部刷新动画.....

- (void)setupStrings
{
    textPull = [[NSString alloc] initWithString:NSLocalizedString(@"Pull down to refresh...", @"")];
    textRelease = [[NSString alloc] initWithString:NSLocalizedString(@"Release to refresh...", @"")];
    textLoading = [[NSString alloc] initWithString:NSLocalizedString(@"Loading...", @"")];
}

- (void)addPullToRefreshHeader
{
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    [refreshLabel setTextColor:[UIColor whiteColor]];
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 16) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    16, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.view addSubview:refreshHeaderView];
}

//scrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isLoading) return;
    
    isDragging = YES;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (isLoading)
    {

        if (_scrollView.contentOffset.y > 0)
        {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        else if (_scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
    }
    else if (isDragging && scrollView.contentOffset.y < 0)
    {

        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT)
            {

                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
            else
            {
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)_scrollView willDecelerate:(BOOL)decelerate
{

    CGRect visibleBounds = _scrollView.bounds;    //得到当前UIScrollView在屏幕中显示区域相对于scrollview的位置
    touchLocationPoint=CGPointMake(visibleBounds.origin.x, visibleBounds.origin.y);

    
    if (isLoading) return;
    isDragging = NO;
    if (_scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT)
    {
        [self startLoading];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    CGRect visibleBounds = _scrollView.bounds;    //得到当前UIScrollView在屏幕中显示区域相对于scrollview的位置
    touchLocationPoint=CGPointMake(visibleBounds.origin.x, visibleBounds.origin.y);

    
}
- (void)showLoading {
    isLoading = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    [self refreshSingleFrameView];
}

- (void)stopLoading
{
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
     completion:^(BOOL finished) {
           [self performSelector:@selector(stopLoadingComplete)];
     }];
}

- (void)stopLoadingComplete {

    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}




@end