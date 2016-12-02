//
//  UIDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-10.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListDialogView.h"

@class ListDialogBGWindow;
@protocol ListDialogDelegate;

typedef NS_ENUM(NSInteger, SIAlertViewBackgroundStyle) {
    SIAlertViewBackgroundStyleGradient = 0,
    SIAlertViewBackgroundStyleSolid,
};

@interface ListDialog : UIWindow<ListDialogViewDelegate>
{
    ListDialogView *listDialogView;
    ListDialogBGWindow *_listDialogBG_window;
    id<ListDialogDelegate> listDialogDelegate;
}
@property (nonatomic,retain)ListDialogView *listDialogView;
@property (nonatomic,assign)id<ListDialogDelegate> listDialogDelegate;
- (void)show;
- (void)dismiss;
- (void)setDialogBackGroundImage:(NSString*)imageString;

@end


@interface ListDialogBGWindow : UIWindow
{
    
}
@property (nonatomic, assign) SIAlertViewBackgroundStyle style;

- (id)initWithFrame:(CGRect)frame andStyle:(SIAlertViewBackgroundStyle)style;

@end


@protocol ListDialogDelegate <NSObject>

@optional
- (void)onReconnectButtonSelected;
- (void)onDeviceSettingsButtonClicked;
- (void)onLocalRecordButtonSelected;
- (void)onRemoteEventsButtonSelected;
- (void)onDeleteDeviceButtonSelected;
- (void)onCancelButtonSelected;

@end