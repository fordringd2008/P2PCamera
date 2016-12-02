//
//  DeviceListTableViewCell.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-9-6.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListTableViewCell : UITableViewCell
{
    NSInteger                        cellIndex;
    UILabel*                         cameraNameLabel;
    UILabel*                         cameraStatusLabel;
    UIImageView*                     cameraSnapshotImageView;
    UIButton*                        notifyButton;
    UIView*                          screenView;
}
@property(nonatomic,retain)UILabel*                         cameraNameLabel;
@property(nonatomic,retain)UILabel*                         cameraStatusLabel;
@property(nonatomic,retain)UIImageView*                     cameraSnapshotImageView;

- (void)setIndex: (NSInteger)value;
- (void)HideNotifyButton;
- (void)showNotifyMessageWithValue: (NSInteger)value;

@end
