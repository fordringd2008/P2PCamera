//
//  RecordModeDialogViewController.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-8.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "RecordModeDialogViewController.h"


@implementation RecordModeDialogViewController

@synthesize recordControllerDelegate;

- (id)init
{
  
    if (self=[super init])
    {
        UIFont* titleFont=[UIFont fontWithName:@"Verdana" size:12];
        
        UIImageView*      backGroundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recordMode.png"]];
        [backGroundImageView setFrame:CGRectMake(60, 368, 117, 45)];
        [self.view addSubview:backGroundImageView];
        [backGroundImageView setUserInteractionEnabled:YES];
        [backGroundImageView release];
        
        
        UIButton* sdCardButton=[[UIButton alloc] initWithFrame:CGRectMake(63, 372, 55, 28)];
        [sdCardButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0 blue:0 alpha:0]];
        [sdCardButton setTitle:NSLocalizedString(@"SD card",@"") forState:UIControlStateHighlighted];
        [sdCardButton setTitle:NSLocalizedString(@"SD card",@"") forState:UIControlStateSelected];
        [sdCardButton setTitle:NSLocalizedString(@"SD card",@"") forState:UIControlStateNormal];
        [sdCardButton.titleLabel setFont:titleFont];
        [sdCardButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [sdCardButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [sdCardButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [sdCardButton addTarget:self action:@selector(onSDRecordSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *localButton=[[UIButton alloc] initWithFrame:CGRectMake(120, 372, 55, 28)];
        [localButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0 blue:0 alpha:0]];
        [localButton setTitle:NSLocalizedString(@"Local",@"") forState:UIControlStateHighlighted];
        [localButton setTitle:NSLocalizedString(@"Local",@"") forState:UIControlStateSelected];
        [localButton setTitle:NSLocalizedString(@"Local",@"") forState:UIControlStateNormal];
        [localButton.titleLabel setFont:titleFont];
        [localButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [localButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
        [localButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [localButton addTarget:self action:@selector(onLocalRecordSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        
        if(__currentDeviceOrientation==DEVICE_ORIENTATION_PORTRAIT)
        {
            //iphone5
            if(screenSize.height==568)
            {
                [backGroundImageView setFrame:CGRectMake(60, 378, 117, 45)];
                [sdCardButton setFrame:CGRectMake(60, 380, 57, 30)];
                [localButton setFrame:CGRectMake(118, 380, 57, 30)];
            }
            else if(screenSize.height==480)
            {
                [backGroundImageView setFrame:CGRectMake(60, 328, 117, 45)];
                [sdCardButton setFrame:CGRectMake(60, 330, 57, 30)];
                [localButton setFrame:CGRectMake(118, 330, 57, 30)];
            }
            else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [backGroundImageView setFrame:CGRectMake(260, 700, 117, 45)];
                [sdCardButton setFrame:CGRectMake(260, 703, 57, 30)];
                [localButton setFrame:CGRectMake(320, 703, 57, 30)];
            }

            
            
        }
        else if(__currentDeviceOrientation==DEVICE_ORIENTATION_LANDSCAP)
        {

            if(screenSize.height==568)
            {
                [backGroundImageView setFrame:CGRectMake(185, 208, 117, 45)];
                [sdCardButton setFrame:CGRectMake(185, 210, 57, 30)];
                [localButton setFrame:CGRectMake(243, 210, 57, 30)];
            }
            else if(screenSize.height==480)
            {
                [backGroundImageView setFrame:CGRectMake(145, 203, 117, 45)];
                [sdCardButton setFrame:CGRectMake(145, 205, 57, 30)];
                [localButton setFrame:CGRectMake(203, 205, 57, 30)];
                
            }
            else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [backGroundImageView setFrame:CGRectMake(390, 640, 117, 45)];
                [sdCardButton setFrame:CGRectMake(392, 643, 57, 30)];
                [localButton setFrame:CGRectMake(450, 643, 57, 30)];
            }

        }
        
        
        [self.view addSubview:sdCardButton];
        [self.view addSubview:localButton];


        [sdCardButton release];
        [localButton release];
        

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)onSDRecordSelected:(id)sender
{
    [recordControllerDelegate onRecordControllerSDCardSelected];
    
}
- (void)onLocalRecordSelected:(id)sender
{
    [recordControllerDelegate onRecordControllerLocalSelected];
}


- (BOOL)shoudAutoRotate
{
    return YES;
}



@end
