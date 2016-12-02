//
//  RecordModeDialog.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-4.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordModeDialogViewController.h"


@protocol RecordModeDialogDelegate;

@interface RecordModeDialog : UIWindow<RecordModeDialogControllerDelegate>
{

    
    id<RecordModeDialogDelegate> recordDialogDelegate;
}
@property (nonatomic,assign)id<RecordModeDialogDelegate> recordDialogDelegate;

- (id)initWithFrame:(CGRect)frame;
- (void)show;
- (void)dismiss;


@end




@protocol RecordModeDialogDelegate <NSObject>

@optional
- (void)onRecordModeDialogDistSDCard;
- (void)onRecordModeDialogDistLocal;

@end
