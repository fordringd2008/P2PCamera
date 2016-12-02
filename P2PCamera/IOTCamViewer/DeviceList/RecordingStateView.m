//
//  RecordingStateView.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-9-17.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "RecordingStateView.h"

@implementation RecordingStateView

@synthesize                 mintesImgView;    //分
@synthesize                 secondsImgView1;  //秒1
@synthesize                 secondsImgView2;  //秒2

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        recordingImgView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 25, 12)];
        [recordingImgView setImage:[UIImage imageNamed:@"recordingState_base.png"]];
        recordingImgView.tag=0;
        
        mintesImgView=[[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 7, 14)];
        [mintesImgView setImage:[UIImage imageNamed:@"number_0.png"]];
        
        pointsImageView=[[UIImageView alloc] initWithFrame:CGRectMake(47, 0, 3, 14)];
        [pointsImageView setImage:[UIImage imageNamed:@"points.png"]];
        pointsImageView.tag=0;
        
        secondsImgView1=[[UIImageView alloc] initWithFrame:CGRectMake(52, 0, 7, 14)];
        [secondsImgView1 setImage:[UIImage imageNamed:@"number_8.png"]];
        
        secondsImgView2=[[UIImageView alloc] initWithFrame:CGRectMake(62, 0, 7, 14)];
        [secondsImgView2 setImage:[UIImage imageNamed:@"number_9.png"]];
        
        [self addSubview:recordingImgView];
        [self addSubview:mintesImgView];
        [self addSubview:pointsImageView];
        [self addSubview:secondsImgView1];
        [self addSubview:secondsImgView2];
        
        [recordingImgView release];
        [mintesImgView release];
        [pointsImageView release];
        [secondsImgView1 release];
        [secondsImgView2 release];
        
        recordingStateTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRecordingState) userInfo:nil repeats:YES];
        pointsTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshPointsState) userInfo:nil repeats:YES];
        
        
    }
    return self;
}

- (void)dealloc
{
    [recordingStateTimer invalidate];
    [pointsTimer invalidate];
    [super dealloc];
}
- (void)refreshRecordingState
{
   
    if(recordingImgView.tag==0)
    {
        [recordingImgView setFrame:CGRectMake(0, 0, 25, 12)];
        [recordingImgView setImage:[UIImage imageNamed:@"recordingState_raised.png"]];
        recordingImgView.tag=1;
    }
    else if(recordingImgView.tag==1)
    {
        [recordingImgView setFrame:CGRectMake(0, 0, 25, 12)];
        [recordingImgView setImage:[UIImage imageNamed:@"recordingState_base.png"]];
        recordingImgView.tag=0;
    }

}
- (void)refreshPointsState
{
    
    if(pointsImageView.tag==0)
    {
        [pointsImageView setImage:[UIImage imageNamed:@""]];
        [pointsImageView setFrame:CGRectMake(45, 0, 3, 14)];
        pointsImageView.tag=1;
    }
    else if(pointsImageView.tag==1)
    {
        [pointsImageView setImage:[UIImage imageNamed:@"points.png"]];
        [pointsImageView setFrame:CGRectMake(45, 0, 3, 14)];
        pointsImageView.tag=0;
    }
}

@end
