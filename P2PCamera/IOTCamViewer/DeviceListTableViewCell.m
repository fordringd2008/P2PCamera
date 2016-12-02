//
//  DeviceListTableViewCell.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-9-6.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "DeviceListTableViewCell.h"

@implementation DeviceListTableViewCell

@synthesize                      cameraNameLabel=_cameraNameLabel;
@synthesize                      cameraStatusLabel=_cameraStatusLabel;
@synthesize                      cameraSnapshotImageView=_cameraSnapshotImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        cellIndex=-1;
 
        UIFont* statusFont=[UIFont fontWithName:@"Verdana" size:17];
        UIFont* nameFont=[UIFont fontWithName:@"Verdana-Bold" size:16];
        
        screenView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        [screenView setBackgroundColor:[UIColor whiteColor]];
        
        
        _cameraSnapshotImageView=[[UIImageView alloc] initWithFrame:CGRectMake(12, 20, 70, 40)];
        [screenView addSubview:_cameraSnapshotImageView];
        [_cameraSnapshotImageView release];
        
        notifyButton=[[UIButton alloc] initWithFrame:CGRectMake(69, 10, 22, 22)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notifyButton.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notifyButton.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notifyButton.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:@"0" forState:UIControlStateHighlighted];
        [notifyButton setTitle:@"0" forState:UIControlStateSelected];
        [notifyButton setTitle:@"0" forState:UIControlStateNormal];

        [notifyButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:7]];
        [notifyButton setHidden:YES];
        [screenView addSubview:notifyButton];
        [notifyButton release];
        
        _cameraNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(105, 15, 187, 21)];
        [_cameraNameLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [_cameraNameLabel setFont:nameFont];
        [_cameraNameLabel setText:@""];
        [screenView addSubview:_cameraNameLabel];
        [_cameraNameLabel release];
        
        _cameraStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(105, 45, 187, 18)];
        [_cameraStatusLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [_cameraStatusLabel setFont:statusFont];
        [_cameraStatusLabel setText:@""];
        [screenView addSubview:_cameraStatusLabel];
        [_cameraStatusLabel release];
        
        
        
        [self setShouldGroupAccessibilityChildren:YES];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [self addSubview:screenView];
        
        
        
        [screenView release];
        

        
        

    }
    return self;
}
- (void)dealloc
{

    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setIndex: (NSInteger)value
{
    cellIndex=value;
}
- (void)showNotifyMessageWithValue: (NSInteger)value
{
    NSString* stringValue=[NSString stringWithFormat:@"%d",value];
    [notifyButton setTitle:stringValue forState:UIControlStateHighlighted];
    [notifyButton setTitle:stringValue forState:UIControlStateSelected];
    [notifyButton setTitle:stringValue forState:UIControlStateNormal];
    [notifyButton setHidden:NO];
}

- (void)HideNotifyButton
{
    NSString* stringValue=@"";
    [notifyButton setTitle:stringValue forState:UIControlStateHighlighted];
    [notifyButton setTitle:stringValue forState:UIControlStateSelected];
    [notifyButton setTitle:stringValue forState:UIControlStateNormal];
    [notifyButton setHidden:YES];
}

@end
