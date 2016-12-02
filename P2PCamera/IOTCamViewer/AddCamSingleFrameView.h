//
//  AddCamSingleFrameView.h
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-18.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCamSingleFrameViewDelegate;

@interface AddCamSingleFrameView : UIImageView
{
     id<AddCamSingleFrameViewDelegate>     addCamSingleFrameDelegate;
}

@property (nonatomic,assign)id<AddCamSingleFrameViewDelegate>     addCamSingleFrameDelegate;

@end

@protocol AddCamSingleFrameViewDelegate <NSObject>


@optional
- (void)onAddCamSingleFrameViewTouched;
@end
