//
//  SendIOCtrlMsgQueue.h
//  P2PCamera
//
//  Created by chenchao on 13-10-20.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#define QUEUE_SIZE 32
#define MAX_IOCTRL_BUFFER_SIZE 1024

typedef struct IOCtrlMsgQueue{
    int type;
    char buffer[MAX_IOCTRL_BUFFER_SIZE];
    int buffer_size;
    
} IOCtrlMsgQueue_t;

#import <Foundation/Foundation.h>

@interface SendIOCtrlMsgQueue : NSObject
{
    
    NSInteger front;
    NSInteger rear;
    IOCtrlMsgQueue_t *sendIOCtrlMsgQueue;
    
}

- (BOOL)IOCtrlMsgQueueIsEmtpy;
- (int)enqueueIOCtrlMsg:(int)type :(char*)buffer :(int)buffer_size;
- (int)dequeueIOCtrlMsg:(int *)type :(char*)buffer :(int *)buffer_size;

@end
