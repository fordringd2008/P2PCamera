//
//  RecordModeDialogViewController.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-8.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum DeviceOrientation
{
    DEVICE_ORIENTATION_PORTRAIT=0,
    DEVICE_ORIENTATION_LANDSCAP,
    DEVICE_ORIENTATION_NONE
}CurrentDeviceOrientation;

typedef enum RecordType
{
    CURRENT_RECORDTYPE_LOCAL=0,
    CURRENT_RECORDTYPE_SDCARD,
    CURRENT_RECORDTYPE_NONE
    
}CURRENT_RECORDTYPE;

extern CurrentDeviceOrientation __currentDeviceOrientation;

@protocol RecordModeDialogControllerDelegate;

@interface RecordModeDialogViewController : UIViewController
{


    id<RecordModeDialogControllerDelegate>  recordControllerDelegate;
}

@property (nonatomic,assign)id<RecordModeDialogControllerDelegate>  recordControllerDelegate;

@end


@protocol RecordModeDialogControllerDelegate <NSObject>

- (void)onRecordControllerSDCardSelected;
- (void)onRecordControllerLocalSelected;


@end