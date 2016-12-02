//
//  UIDialogView.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-10.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ListDialogViewDelegate;

@interface ListDialogView : UIView
{
    UIImageView*    bgImageView;
    UIButton*   refreshButton;
    UIButton*   remoteEventsButton;
    UIButton*   localRecordButton;
    UIButton*   deviceSettingButton;
    UIButton*   deleteDeviceButton;

    id<ListDialogViewDelegate>  listDialogDelegate;
}
@property (nonatomic,assign) id<ListDialogViewDelegate>  listDialogViewDelegate;
- (void)setDialogBGImage:(NSString*)imageString;


@end


@protocol ListDialogViewDelegate <NSObject>

@optional
- (void)onDialogViewReconnectButtonSelected;
- (void)onDialogViewSettingsButtonClicked;
- (void)onDialogViewLocalRecordButtonSelected;
- (void)onDialogViewRemoteEventsButtonSelected;
- (void)onDialogViewCancelButtonSelected;
- (void)onDialogViewDeleteButtonSelected;

@end