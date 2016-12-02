//
//  TimeSearchDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeSearchDialog.h"
#import "TimeSearchDialogView.h"

@class TimeSearchBackgroundWindow;
@protocol TimeSearchDialogDelegate;

typedef NS_ENUM(NSInteger, TimeSearchBackgroundWindowBGStyle)
{
    TimeSearchBackgroundWindowStyleGradient = 0,
    TimeSearchBackgroundWindowStyleSolid,
};

@interface TimeSearchDialog : UIWindow<TimeSearchDialogViewDelegate>
{
    TimeSearchDialogView *timeSearchDialogView;
    TimeSearchBackgroundWindow *timeSearch_background_window;
    id<TimeSearchDialogDelegate> timeSearchDialogDelegate;
}
@property (nonatomic,retain)TimeSearchDialogView *timeSearchDialogView;
@property (nonatomic,assign)id<TimeSearchDialogDelegate> timeSearchDialogDelegate;
- (void)show;
- (void)dismiss;

@end


@interface TimeSearchBackgroundWindow : UIWindow
{
    
}
@property (nonatomic, assign) TimeSearchBackgroundWindowBGStyle style;

- (id)initWithFrame:(CGRect)frame andStyle:(TimeSearchBackgroundWindowBGStyle)style;

@end


@protocol TimeSearchDialogDelegate <NSObject>

@optional

- (void)onTimeSearchDialog1Hour;
- (void)onTimeSearchDialog1Day;
- (void)onTimeSearchDialog1Week;
- (void)onTimeSearchDialogAll;
- (void)onTimeSearchDialogCancel;

@end