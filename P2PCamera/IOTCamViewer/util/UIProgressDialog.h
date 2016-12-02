//
//  UIProgressDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-20.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressDialogBGWindow;

@interface UIProgressDialog : UIWindow
{
    UIActivityIndicatorView*            activityIndicatorView;
    UILabel*                    showLabel;
    ProgressDialogBGWindow*     _progressDlgBGWindow;
}
- (void)setProgressShowString: (NSString*)aString;
- (void)show;
- (void)dismiss;
@end

@interface ProgressDialogBGWindow : UIWindow
{
    
}
- (id)initWithFrame:(CGRect)frame;

@end