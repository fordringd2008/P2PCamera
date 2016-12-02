//
//  AppDelegate.h
//  IOTCamViewer
//
//  Created by chenchao on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AVIOCTRLDEFs.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"


//UID: SVWHXJ7WMYULFX3WENE1
//Password :415926

#define SQLCMD_CREATE_TABLE_LOCALDEVICES @"CREATE TABLE IF NOT EXISTS device(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, dev_nickname TEXT, dev_name TEXT, dev_pwd TEXT, view_acc TEXT, view_pwd TEXT, ask_format_sdcard INTEGER)"

#define SQLCMD_CREATE_TABLE_SNAPSHOT @"CREATE TABLE IF NOT EXISTS snapshotTB(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, file_path TEXT, user TEXT,time TEXT)"

#define SQLCMD_CREATE_TABLE_RECORDMOVIE @"CREATE TABLE IF NOT EXISTS recordMovieTB(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, file_path TEXT,user TEXT, time TEXT)"


NSString *deviceTokenString;
NSMutableArray *camera_list;
FMDatabase *database;
NSString* G_loginAccountName;


APPLICATIONACCESSMODE appAccessModeGlobal;

@interface AppDelegate : UIResponder<UIApplicationDelegate, UINavigationControllerDelegate,DBSessionDelegate, DBNetworkRequestDelegate,DBRestClientDelegate>
{
    float dboxTotalSize;
    float dboxComsumedSize;
    float dbFreeSize;
    NSString* dbUserAccountString;
    NSString* oauthTokenString;
    NSString* oauthTokenSecretString;
    NSString* oauthTokenStateString;
    NSString* oauthTokenUIDString;
    NSString* dropboxAppKey;
    NSString* dropbox_AppSecret;
    NSString* dropboxRoot;


    DBRestClient* dboxResetClient;
}
@property (retain, nonatomic)UIWindow *window;

@property (readwrite, nonatomic)float dboxTotalSize;
@property (readwrite, nonatomic)float dboxComsumedSize;
@property (readwrite, nonatomic)float dbFreeSize;
@property (retain, nonatomic)NSString* dbUserAccountString;
@property (retain, nonatomic)NSString* oauthTokenString;
@property (retain, nonatomic)NSString* oauthTokenSecretString;
@property (retain, nonatomic)NSString* oauthTokenStateString;
@property (retain, nonatomic)NSString* oauthTokenUIDString;
@property (retain, nonatomic)NSString* dropboxAppKey;
@property (retain, nonatomic)NSString* dropbox_AppSecret;
@property (retain, nonatomic)NSString* dropboxRoot;
@property (retain, nonatomic)DBRestClient* dboxResetClient;

@end
