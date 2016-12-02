//
//  RecordModeDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-4.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//



#import "RecordModeDialog.h"
#import  <QuartzCore/QuartzCore.h>


@implementation RecordModeDialog

@synthesize recordDialogDelegate;


const UIWindowLevel RecordModeDialogWindowLevelAlert = 1999.0;
const UIWindowLevel RecordModeDialogWindowLevelAlertBackground = 1998.0;

- (id)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame])
    {
        // Initialization code
        
        self.windowLevel = UIWindowLevelAlert;
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        RecordModeDialogViewController* recordModeController=[[RecordModeDialogViewController alloc] init];
        recordModeController.recordControllerDelegate=self;
        
        [self setRootViewController:recordModeController];
        
        [recordModeController release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"recordModeDialog_makeMainDialogDisappeared" object:nil];
        

    }
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recordModeDialog_makeMainDialogDisappeared" object:nil];
    [super dealloc];
}

- (void)show {

    [self makeKeyAndVisible];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
                     }];
    
}
- (void)dismiss
{

    [self resignKeyWindow];
    [self release];
}

- (void)onRecordControllerSDCardSelected
{
    if([self.recordDialogDelegate respondsToSelector:@selector(onRecordModeDialogDistSDCard)])
    {
        [recordDialogDelegate onRecordModeDialogDistSDCard];
    }

    [self dismiss];
    
}
- (void)onRecordControllerLocalSelected
{
    if([self.recordDialogDelegate respondsToSelector:@selector(onRecordModeDialogDistLocal)])
    {
        [recordDialogDelegate onRecordModeDialogDistLocal];
    }

    [self dismiss];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}





@end
