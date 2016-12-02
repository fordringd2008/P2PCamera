//
//  CameraListForLiveViewController.h
//  IOTCamViewer
//
//  Created by chenchao on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "Camera.h"
#import "ListDialog.h"
#import "DeviceListTableViewCell.h"
#import "PopupNavigationController.h"
#import "RootNavigationController.h"

#import "UserAccountDialog.h"
#import "AddCameraController.h"
#import "SingleFrameView.h"


#import "MessageDialog.h"

#import "AddCamSingleFrameView.h"
#import "APSearchCamViewController.h"


#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width ) > 1))

#define CAMERA_NAME_TAG 1
#define CAMERA_STATUS_TAG 2
#define CAMERA_UID_TAG 3
#define CAMERA_SNAPSHOT_TAG 4
#define REFRESH_HEADER_HEIGHT 52.0f
#define STATUS_NAVI_HEADER_HEIGHT 60.0f

extern NSMutableArray *camera_list;
extern FMDatabase *database;
extern NSString *deviceTokenString;
extern NSString *G_loginAccountName;
extern APPLICATIONACCESSMODE appAccessModeGlobal;

@class Camera;
@protocol CameraListViewControllerDelegate;


@interface CameraListForLiveViewController : UIViewController
    <UIScrollViewDelegate,CameraDelegate,UIAlertViewDelegate,ListDialogDelegate,UserAccountDialogDelegate,SingleFrameViewDelegate,UIScrollViewDelegate,MessageDialogDelegate,AddCamSingleFrameViewDelegate>
{
        

    CGPoint                                 touchLocationPoint;
    NSInteger                               currentTouchIndex;
    UserAccountDialog*                      _userAccountDialog;
    NSMutableArray*                         singleVCArrays;
        
    
    //ScrollView and refresh....
    UIScrollView*                           scrollView;
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
    
    id<CameraListViewControllerDelegate>       camListVCDelegate;
    
    AddCamSingleFrameView*                  addCamFrameView;
    
    
}
@property (nonatomic,assign)id<CameraListViewControllerDelegate>       camListVCDelegate;

@property (nonatomic, retain)UIScrollView*         scrollView;
@property (nonatomic, retain)UIView*                refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)showLoading;


@end


@protocol CameraListViewControllerDelegate <NSObject>

@optional
- (void)onCameraListViewControllerBackToLoginPage;

@end
