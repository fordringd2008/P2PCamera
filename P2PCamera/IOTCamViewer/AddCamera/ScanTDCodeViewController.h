//
//  ScanTwoDimensinalCode.h
//  IPCamera
//
//  Created by apexis on 13-2-25.
//  Copyright (c) 2013年 apexis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarSDK.h"

@protocol ScanTDCodeControllerDelegate;


@interface ScanTDCodeViewController : UIViewController<ZBarReaderDelegate>
{
    ZBarReaderView *zbarReaderView;
    bool                lightToggleOn;
    id<ScanTDCodeControllerDelegate> controllerDelegate;
}
@property (nonatomic,assign)id<ScanTDCodeControllerDelegate> controllerDelegate;
@property (nonatomic,readwrite)bool                lightToggleOn;
@end


@protocol ScanTDCodeControllerDelegate <NSObject>

@optional
- (void)OnScanTDCodeGetResult: (NSString*)scanResult;
- (void)onScanTDCodeControllerBack;
@end