//
//  AddCamSingleFrameView.m
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-18.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "AddCamSingleFrameView.h"

@implementation AddCamSingleFrameView

@synthesize addCamSingleFrameDelegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([addCamSingleFrameDelegate respondsToSelector:@selector(onAddCamSingleFrameViewTouched)])
    {
        [addCamSingleFrameDelegate onAddCamSingleFrameViewTouched];
    }
}



@end
