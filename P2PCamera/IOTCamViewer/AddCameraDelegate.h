//
//  CameraDidAddDelegate.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/6/28.
//  Copyright (c) 2012年 CHENCHAO. All rights reserved.
//

#ifndef IOTCamViewer_AddCameraDelegate_h
#define IOTCamViewer_AddCameraDelegate_h

@protocol AddCameraDelegate <NSObject>
@required
- (void) camera:(NSString*)UID didAddwithName:(NSString *)name password:(NSString *)password;

@end

#endif