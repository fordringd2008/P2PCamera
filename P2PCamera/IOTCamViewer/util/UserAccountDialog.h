//
//  UserAccountDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-11.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserAccountDialogBGWindow;

@protocol   UserAccountDialogDelegate;

@interface UserAccountDialog : UIWindow
{

    
    UserAccountDialogBGWindow *_userAccountDialogBG_window;
    id<UserAccountDialogDelegate>   userAccountDlgDelegate;
}
@property (nonatomic,assign) id<UserAccountDialogDelegate>   userAccountDlgDelegate;
- (void)show;
- (void)dismiss;

@end


@interface UserAccountDialogBGWindow : UIWindow
{
    
}
- (id)initWithFrame:(CGRect)frame;

@end

@protocol UserAccountDialogDelegate <NSObject>

@optional
- (void)userAccountDlg_AddDeviceButtonSelected;
- (void)userAccountDlg_AccountSettingsSelected;
- (void)userAccountDlg_AppInfoSelected;
- (void)userAccountDlg_CancelSelected;

@end