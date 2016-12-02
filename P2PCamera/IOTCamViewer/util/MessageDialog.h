//
//  MessageDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageDialogDelegate;
@class MsgDialogBGWindow;

@interface MessageDialog : UIWindow
{

    MsgDialogBGWindow*   _msgDialogBG_Window;
    id<MessageDialogDelegate> messageDialogDelegate;
}
@property (nonatomic,assign)id<MessageDialogDelegate> messageDialogDelegate;
- (void)show;
- (void)dismiss;
@end



@interface MsgDialogBGWindow : UIWindow
{
    
}
- (id)initWithFrame:(CGRect)frame;

@end



@protocol MessageDialogDelegate <NSObject>

@optional
- (void)messageDialogOkSelected;
- (void)messageDialogCancelSelected;

@end
