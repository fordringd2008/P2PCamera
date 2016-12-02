//
//  ScanTwoDimensinalCode.m
//  IPCamera
//
//  Created by apexis on 13-2-25.
//  Copyright (c) 2013年 apexis. All rights reserved.
//

#import "ScanTDCodeViewController.h"



@implementation ScanTDCodeViewController
@synthesize lightToggleOn;
@synthesize controllerDelegate;

- (id)init
{
    if(self=[super init])
    {
        lightToggleOn=false;
        UIView* screenView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        [screenView setBackgroundColor:[UIColor blackColor]];
        
        zbarReaderView=[[ZBarReaderView alloc] init];
        [zbarReaderView setFrame:[[UIScreen mainScreen] bounds]];
        zbarReaderView.readerDelegate = self;
        
        [screenView addSubview:zbarReaderView];
        
        CGRect screenRect=[[UIScreen mainScreen] bounds];
        
        float           BACKBUTTON_STARTX=65;
        float           BACKBUTTON_STARTY=350;
        float           LIGHTBUTTON_STARTX=205;
        float           LIGHTBUTTON_STARTY=350;
        if (screenRect.size.height==568)
        {
            BACKBUTTON_STARTX=65;
            BACKBUTTON_STARTY=430;
            LIGHTBUTTON_STARTX=205;
            LIGHTBUTTON_STARTY=430;
        }
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            BACKBUTTON_STARTX=265;
            BACKBUTTON_STARTY=750;
            LIGHTBUTTON_STARTX=455;
            LIGHTBUTTON_STARTY=750;
        }
        
        UIButton* backButton=[[UIButton alloc] initWithFrame:CGRectMake(BACKBUTTON_STARTX, BACKBUTTON_STARTY, 50, 50)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"scanTDCBackButton.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"scanTDCBackButton.png"] forState:UIControlStateHighlighted];
        [backButton setBackgroundImage:[UIImage imageNamed:@"scanTDCBackButton.png"] forState:UIControlStateSelected];
        [backButton addTarget:self action:@selector(onBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* lightButton=[[UIButton alloc] initWithFrame:CGRectMake(LIGHTBUTTON_STARTX,LIGHTBUTTON_STARTY, 50, 50)];
        [lightButton setBackgroundImage:[UIImage imageNamed:@"scanTDCLightButton.png"] forState:UIControlStateNormal];
        [lightButton setBackgroundImage:[UIImage imageNamed:@"scanTDCLightButton.png"] forState:UIControlStateHighlighted];
        [lightButton setBackgroundImage:[UIImage imageNamed:@"scanTDCLightButton.png"] forState:UIControlStateSelected];
        [lightButton addTarget:self action:@selector(tagLightButtonButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [screenView addSubview:lightButton];
        [screenView addSubview:backButton];
        

        self.view=screenView;
        
        [backButton release];
        [lightButton release];
        [screenView release];
        
        
    }
    return self;
}

- (void)tagLightButtonButtonClicked:(id)sender
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(self.lightToggleOn==false)
    {
        if ([device hasTorch])
        {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }
        self.lightToggleOn=true;
    }else
    {
        if ([device hasTorch])
        {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        self.lightToggleOn=false;
    }
   
}
- (void)onBackButtonClicked:(id)sender
{
    [controllerDelegate onScanTDCodeControllerBack];
}
- (void) readerView: (ZBarReaderView*) view didReadSymbols: (ZBarSymbolSet*) syms fromImage: (UIImage*) img
{

    for(ZBarSymbol *sym in syms)
    {
        NSString* resultText=nil;
        resultText = sym.data;
        
        if(resultText!=nil)
        {
            [controllerDelegate OnScanTDCodeGetResult:resultText];
        }
       
        break;
    }
     
}

- (void) cleanup
{

    zbarReaderView.readerDelegate = nil;
    [zbarReaderView release];
    zbarReaderView = nil;

}


- (BOOL) shouldAutorotate
{
       return NO;
}

- (void) viewDidAppear: (BOOL) animated
{

    [zbarReaderView start];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [zbarReaderView stop];
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient duration: (NSTimeInterval) duration
{
    
    [zbarReaderView willRotateToInterfaceOrientation: orient duration: duration];
}

@end
