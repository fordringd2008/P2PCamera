//
//  LANSearchDevice.m
//  IOTCamViewer
//
//  Created by chenchao on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LANSearchDevice.h"

@implementation LANSearchDevice

@synthesize uid;
@synthesize ip;
@synthesize port;

- (void)dealloc {
    
    [uid release];
    [ip release];
    [super dealloc];
}

@end