//
//  RecordingStateView.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-9-17.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingStateView : UIView
{
    UIImageView*             recordingImgView; //录像状态动画.
    UIImageView*             mintesImgView;    //分
    UIImageView*             pointsImageView;  //点
    UIImageView*             secondsImgView1;  //秒1
    UIImageView*             secondsImgView2;  //秒2
    
    NSTimer*                 recordingStateTimer;
    NSTimer*                 pointsTimer;
    
}


@property (nonatomic,retain)UIImageView*             mintesImgView;  //点
@property (nonatomic,retain)UIImageView*             secondsImgView1;  //秒1
@property (nonatomic,retain)UIImageView*             secondsImgView2;  //秒2

@end
