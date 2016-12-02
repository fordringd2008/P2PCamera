//
//  UIDialogView.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-10.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "ListDialogView.h"

@implementation ListDialogView

@synthesize listDialogViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIFont* buttonFont=[UIFont fontWithName:@"ArialMT" size:11];
        UIFont* hdFont=[UIFont fontWithName:@"ArialMT" size:12];
        
         bgImageView=[[UIImageView alloc] initWithFrame:frame];
        [bgImageView setImage:[UIImage imageNamed:@"longPressDlg_left_5.png"]];
        
        refreshButton=[[UIButton alloc] initWithFrame:CGRectMake(1, 4, 60, 30)];
        [refreshButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0]];
        [refreshButton setTitle:NSLocalizedString(@"Reconnect",@"") forState:UIControlStateHighlighted];
        [refreshButton setTitle:NSLocalizedString(@"Reconnect",@"") forState:UIControlStateSelected];
        [refreshButton setTitle:NSLocalizedString(@"Reconnect",@"") forState:UIControlStateNormal];
        [refreshButton.titleLabel setFont:buttonFont];
        
        [refreshButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [refreshButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [refreshButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [refreshButton addTarget:self action:@selector(onReconnectButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        remoteEventsButton=[[UIButton alloc] initWithFrame:CGRectMake(63, 4, 58, 30)];
        [remoteEventsButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0]];
        [remoteEventsButton setTitle:NSLocalizedString(@"Remote events",@"") forState:UIControlStateHighlighted];
        [remoteEventsButton setTitle:NSLocalizedString(@"Remote events",@"") forState:UIControlStateSelected];
        [remoteEventsButton setTitle:NSLocalizedString(@"Remote events",@"") forState:UIControlStateNormal];
        [remoteEventsButton.titleLabel setFont:buttonFont];
        
        [remoteEventsButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [remoteEventsButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [remoteEventsButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [remoteEventsButton addTarget:self action:@selector(onRemoteEventsButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        localRecordButton=[[UIButton alloc] initWithFrame:CGRectMake(123, 4, 60, 30)];
        [localRecordButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0]];
        [localRecordButton setTitle:NSLocalizedString(@"Collections",@"") forState:UIControlStateHighlighted];
        [localRecordButton setTitle:NSLocalizedString(@"Collections",@"") forState:UIControlStateSelected];
        [localRecordButton setTitle:NSLocalizedString(@"Collections",@"") forState:UIControlStateNormal];
        [localRecordButton.titleLabel setFont:buttonFont];
        
        [localRecordButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [localRecordButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [localRecordButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [localRecordButton addTarget:self action:@selector(onLocalRecordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        deviceSettingButton=[[UIButton alloc] initWithFrame:CGRectMake(186, 4, 58, 30)];
        [deviceSettingButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0]];
        [deviceSettingButton setTitle:NSLocalizedString(@"Settings",@"") forState:UIControlStateHighlighted];
        [deviceSettingButton setTitle:NSLocalizedString(@"Settings",@"") forState:UIControlStateSelected];
        [deviceSettingButton setTitle:NSLocalizedString(@"Settings",@"") forState:UIControlStateNormal];
        [deviceSettingButton.titleLabel setFont:buttonFont];
        
        [deviceSettingButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [deviceSettingButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [deviceSettingButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [deviceSettingButton addTarget:self action:@selector(onDeviceSettingButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        deleteDeviceButton=[[UIButton alloc] initWithFrame:CGRectMake(246, 4, 58, 30)];
        [deleteDeviceButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0]];
        [deleteDeviceButton setTitle:NSLocalizedString(@"Delete",@"") forState:UIControlStateHighlighted];
        [deleteDeviceButton setTitle:NSLocalizedString(@"Delete",@"") forState:UIControlStateSelected];
        [deleteDeviceButton setTitle:NSLocalizedString(@"Delete",@"") forState:UIControlStateNormal];
        [deleteDeviceButton.titleLabel setFont:buttonFont];
        
        [deleteDeviceButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [deleteDeviceButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [deleteDeviceButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [deleteDeviceButton addTarget:self action:@selector(onDeleteDeviceButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [refreshButton  setFrame:CGRectMake(6, 6, 60, 30)];
            [remoteEventsButton setFrame:CGRectMake(76, 6, 58, 30)];
            [localRecordButton setFrame:CGRectMake(143, 6, 60, 30)];
            [deviceSettingButton setFrame:CGRectMake(213, 6, 58, 30)];
            [deleteDeviceButton setFrame:CGRectMake(282, 6, 58, 30)];
            [refreshButton.titleLabel setFont:hdFont];
            [remoteEventsButton.titleLabel setFont:hdFont];
            [localRecordButton.titleLabel setFont:hdFont];
            [deviceSettingButton.titleLabel setFont:hdFont];
            [deleteDeviceButton.titleLabel setFont:hdFont];
        }
        

        
        [self addSubview:bgImageView];
        [self addSubview:refreshButton];
        [self addSubview:remoteEventsButton];
        [self addSubview:localRecordButton];
        [self addSubview:deviceSettingButton];
        [self addSubview:deleteDeviceButton];

        
        [bgImageView release];
        [refreshButton release];
        [remoteEventsButton release];
        [localRecordButton release];
        [deviceSettingButton release];
        [deleteDeviceButton release];


    }
    return self;
}

- (void)setDialogBGImage:(NSString*)imageString
{
    [bgImageView setImage:[UIImage imageNamed:imageString]];
}
- (void)onReconnectButtonSelected:(id)sender
{
    [listDialogViewDelegate  onDialogViewReconnectButtonSelected];
}
- (void)onRemoteEventsButtonSelected:(id)sender
{
    [listDialogViewDelegate  onDialogViewRemoteEventsButtonSelected];
}
- (void)onLocalRecordButtonSelected:(id)sender
{
    [listDialogViewDelegate  onDialogViewLocalRecordButtonSelected];
}
- (void)onDeviceSettingButtonSelected:(id)sender
{
    [listDialogViewDelegate  onDialogViewSettingsButtonClicked];
}

- (void)onDeleteDeviceButtonSelected:(id)sender
{
    [listDialogViewDelegate onDialogViewDeleteButtonSelected];
}

- (void)dealloc
{
    [super dealloc];
}

@end
