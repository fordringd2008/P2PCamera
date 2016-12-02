//
//  FHSignalFrameView.h
//  apexisCam
//
//  Created by apexis on 13-1-12.
//  Copyright (c) 2013年 apexis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleFrameViewDelegate;

@interface SingleFrameView : UIView<UIGestureRecognizerDelegate>
{
    int                             singleFrameViewIndex;
    

    UILabel*                        signalViewNameLabel;
    UIImageView*                    statusImageView;
    UIButton*                       notifyButton;
    UIImageView*                    backGroundImageView;
    
    UIActivityIndicatorView*        activityIndicatorView;

    id<SingleFrameViewDelegate>     singleTouchPointDelegate;
}

@property (nonatomic,readwrite)int                        singleFrameViewIndex;
@property (nonatomic,assign)  id<SingleFrameViewDelegate> singleTouchPointDelegate;

- (void)updateImage:(NSString*)imagePath;
- (void)setRemoteNotificationsWithNumber: (NSInteger)number;
- (void)setNetworkConnectedStatus: (int)status;
- (void)setDeviceName: (NSString*)devName;


@end

@protocol SingleFrameViewDelegate <NSObject>

@optional
- (void)onSingleTouchPointSelected:(NSSet*)touches;
- (void)onLongPressTouchSelected:(UILongPressGestureRecognizer *)gestureRecognizer;

@end