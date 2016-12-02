//
//  TimeSearchDialogView.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TimeSearchDialogViewDelegate ;

@interface TimeSearchDialogView : UIView
{

    UIButton*   aHourButton;
    UIButton*   aDayButton;
    UIButton*   aWeekButton;
    UIButton*   allButton;
    UIButton*   cancelButton;
    
    id<TimeSearchDialogViewDelegate>  timeSearchDialogViewDelegate;
}
@property (nonatomic,assign) id<TimeSearchDialogViewDelegate>  timeSearchDialogViewDelegate;



@end


@protocol TimeSearchDialogViewDelegate <NSObject>

@optional

- (void)onTimeSearchDialogView1Hour;
- (void)onTimeSearchDialogView1Day;
- (void)onTimeSearchDialogView1Week;
- (void)onTimeSearchDialogViewAll;
- (void)onTimeSearchDialogViewCancel;

@end