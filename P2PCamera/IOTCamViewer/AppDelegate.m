//
//  AppDelegate.m
//  IOTCamViewer
//
//  Created by chenchao on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Camera.h"
#import "CameraListForLiveViewController.h"
#import "RootNavigationController.h"

#import "Mp4VideoRecorder.h"

@implementation AppDelegate

@synthesize dboxTotalSize;
@synthesize dboxComsumedSize;
@synthesize dbFreeSize;
@synthesize dbUserAccountString;
@synthesize oauthTokenString;
@synthesize oauthTokenSecretString;
@synthesize oauthTokenStateString;
@synthesize oauthTokenUIDString;
@synthesize dropboxAppKey;
@synthesize dropbox_AppSecret;
@synthesize dropboxRoot;
@synthesize dboxResetClient;

@synthesize window;

#pragma mark - AudioSession implementations
void interruptionListener(void * inClientData, UInt32 inInterruptionState)
{
    
    if (inInterruptionState == kAudioSessionBeginInterruption)
    {
        
        NSLog(@"AudioSession Begin Interruption");
    }
    else if (inInterruptionState == kAudioSessionEndInterruption)
    {
        
        NSLog(@"AudioSession End Interruption");
    }    
}

- (void)initAudioSession
{
    
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);  
    
    if (error)
    {
        printf("ERROR INITIALIZING AUDIO SESSION! %d/n", (int)error);  
    }
}

- (void)dealloc
{
    
    printf("AppDelegate Dealloc******\n\n");
    [self.dboxResetClient release];
    [window release];
    [super dealloc];
}

#pragma mark - Application Lifecycle Methods


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Mp4VideoRecorder getInstance];
    
    [Camera initIOTC];
    camera_list = [[NSMutableArray alloc] init];
    [self initAudioSession];
    
    [self openDatabase];
    [self createTable];
    
    [self loadDeviceFromLocalDB];
    
    //Global String
    self.dboxTotalSize=0;
    self.dboxComsumedSize=0;
    self.dbFreeSize=0;
    self.dbUserAccountString=nil;
    self.dropboxAppKey = nil;
    self.dropbox_AppSecret = nil;
    self.dropboxRoot = nil;
    self.dropboxAppKey = nil;
    self.dropbox_AppSecret = nil;
    self.dropboxRoot = nil;

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds] ] autorelease];
    
    CameraListForLiveViewController* controller=[[[CameraListForLiveViewController alloc] init] autorelease];
    
    RootNavigationController* rootNavigationController=[[[RootNavigationController alloc] initWithRootViewController:controller] autorelease];
    [rootNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    rootNavigationController.navigationBar.translucent = NO;
    
    [self.window setRootViewController:rootNavigationController];


    [self.window makeKeyAndVisible];

    appAccessModeGlobal=APPLICATIONACCESSMODE_LOCAL;
    


    application.applicationIconBadgeNumber = 0;
    [UIApplication sharedApplication].idleTimerDisabled = YES;


    
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
    printf("\n\n=============================release=======================================\n\n");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecordingVideo" object:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        for (Camera *camera in camera_list)
        {
            [camera exitConnectedSession];

        }
        [self closeDatabase];
    
        // logout.
        NSError *error = nil;
        NSString* logoutString=[NSString stringWithFormat:@"http://www.p2picamera.com/UserAccount/logout.php"];
        [NSString stringWithContentsOfURL:[NSURL URLWithString:logoutString] encoding:NSUTF8StringEncoding error:&error];

    
        
        [Camera uninitIOTC];
        
        if(camera_list)
        {
            
            [camera_list removeAllObjects];
            [camera_list release];
            
        }
        
    });
    
    printf("\n\n**************************releaseAllCameraResources***************************************\n\n");
    
}



- (NSString *)URLEncodedString:(NSString *)string
{
    NSString *result = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)string,
                                                                          NULL,
                                                                          CFSTR("\"\\.-_!~|{}^!*'();:@&=+$,/?%#[]"),
                                                                          kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] 
             URLsForDirectory:NSDocumentDirectory 
             inDomains:NSUserDomainMask] lastObject];
}



- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    

}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to register, error: %@", error);
}

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo {    
    

}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
}
- (void)initializeDropBox
{
    
}


#pragma mark - SQLite Methods

- (void)openDatabase
{
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *databaseFilePath = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"database.sqlite"];
    
    database = [[FMDatabase alloc] initWithPath:databaseFilePath];
    
    if (![database open])
    {
        NSLog(@"open sqlite db error.");
    }
    
}

- (void)closeDatabase
{
    if (database != NULL) {
        [database close];
        [database release];
        NSLog(@"close sqlite db ok.");
    }
}

- (void)createTable
{
    //截图，视频录制数据库.....
    if (database != NULL)
    {
        if (![database executeUpdate:SQLCMD_CREATE_TABLE_LOCALDEVICES]) NSLog(@"Can not create table device");
        if (![database executeUpdate:SQLCMD_CREATE_TABLE_SNAPSHOT]) NSLog(@"Can not create table snapshotTB");
        if (![database executeUpdate:SQLCMD_CREATE_TABLE_RECORDMOVIE]) NSLog(@"Can not create table recordMovieTB");
        
    }
}



#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{

	[[[[UIAlertView alloc] initWithTitle:@"Dropbox Session" message:@"Dropbox Session failed." delegate:nil
	   cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease] show];
}



#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    
	if ([[DBSession sharedSession] handleOpenURL:url])
    {
        NSString* URLString=[url absoluteString];
        NSDictionary *paramDic = [self dictionaryFromQuery:URLString usingEncoding:NSUTF8StringEncoding];
        
        //NSLog(@"DIC PARAM URL: %@\n",paramDic);

        
        self.oauthTokenString=[paramDic objectForKey:@"oauth_token"];
        self.oauthTokenSecretString=[paramDic objectForKey:@"oauth_token_secret"];
        self.oauthTokenStateString=[paramDic objectForKey:@"state"];
        self.oauthTokenUIDString=[paramDic objectForKey:@"uid"];

        
        if(self.dboxResetClient)
        {
            [self.dboxResetClient release];
        }
        self.dboxResetClient=[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.dboxResetClient.delegate=self;
        [self.dboxResetClient loadAccountInfo];
        
		return YES;
	}
	
	return NO;
}

- (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;?"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[[NSScanner alloc] initWithString:query] autorelease];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}
- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)accountInfo
{
    
    self.dbUserAccountString=[accountInfo displayName];
    self.dboxTotalSize=accountInfo.quota.totalBytes/1024/1024.0;
    self.dboxComsumedSize=accountInfo.quota.totalConsumedBytes/1024/1024.0;
    self.dbFreeSize=dboxTotalSize-dboxComsumedSize;
    NSLog(@"Dropbox Name: %@  %.3f G %.3f G\n",self.dbUserAccountString,self.dboxTotalSize,self.dbFreeSize);
    
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    NSLog(@"file upload successfully to path: %@",metadata.path);
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"file upload failed with error: %@",[error description]);
}

- (void)loadDeviceFromLocalDB
{
    
    if (database != NULL) {
        
        FMResultSet *result = [database executeQuery:@"SELECT * FROM device"];
        int count = 0;
        
        while([result next] && count++ < 128)
        {
            
            NSString *uid = [result stringForColumn:@"dev_uid"];
            NSString *name = [result stringForColumn:@"dev_nickname"];
            NSString *view_acc = [result stringForColumn:@"view_acc"];
            NSString *view_pwd = [result stringForColumn:@"view_pwd"];
            NSLog(@"Local login: %@ %@ %@ %@\n",uid,name,view_acc,view_pwd);
            Camera *myCamera = [[Camera alloc] initWithUID:uid camName:name viewAccount:view_acc viewPassword:view_pwd];
            [myCamera connect];
            [camera_list addObject:myCamera];
            
            [myCamera release];
            
            
        }
        [result close];
    }
    
    
}
@end
