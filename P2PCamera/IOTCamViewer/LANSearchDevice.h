//
//  LANSearchDevice.h
//  IOTCamViewer
//
//  Created by chenchao on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LANSearchDevice : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *ip;
@property NSInteger port;

@end
