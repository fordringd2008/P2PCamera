//
//  SendIOCtrlMsgQueue.m
//  P2PCamera
//
//  Created by chenchao on 13-10-20.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "SendIOCtrlMsgQueue.h"

@implementation SendIOCtrlMsgQueue

- (id)init
{
    if(self=[super init])
    {
        sendIOCtrlMsgQueue = malloc(QUEUE_SIZE * sizeof(IOCtrlMsgQueue_t));
        
    }
    return self;
}

- (void)dealloc
{
    if (sendIOCtrlMsgQueue)
    {
        free(sendIOCtrlMsgQueue);
    }
    //[self releaseSendIOCtrlQueue];
    
    [super dealloc];
}

- (void)initIOCtrlMsgQueue
{
    memset(sendIOCtrlMsgQueue, 0, QUEUE_SIZE * sizeof(IOCtrlMsgQueue_t));
    front = rear = 0;
}
- (void)releaseSendIOCtrlQueue
{
    for (int i = 0; i < QUEUE_SIZE; i++) {
        
        sendIOCtrlMsgQueue[i].type = 0;
        sendIOCtrlMsgQueue[i].buffer_size = 0;
        
        memset(sendIOCtrlMsgQueue[i].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);
    }
}
- (BOOL)IOCtrlMsgQueueIsEmtpy
{
    return front == rear;
}
- (int)enqueueIOCtrlMsg:(int)type :(char*)buffer :(int)buffer_size
{
    @synchronized(self) {
        
        int r = (rear + 1) % QUEUE_SIZE;
        
        if (front == r) {
            return 0;
        }
        
        memset(sendIOCtrlMsgQueue[r].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);
        
        sendIOCtrlMsgQueue[r].type = type;
        sendIOCtrlMsgQueue[r].buffer_size = buffer_size;
        memcpy(sendIOCtrlMsgQueue[r].buffer, buffer, buffer_size);
        
        rear = r;
    }
    
    return 1;
}
- (int)dequeueIOCtrlMsg:(int *)type :(char*)buffer :(int *)buffer_size
{
    @synchronized(self) {
        int f;
        if (front == rear)
            return 0;
        
        f = (front + 1) % QUEUE_SIZE;
        
        *type = sendIOCtrlMsgQueue[f].type;
        *buffer_size = sendIOCtrlMsgQueue[f].buffer_size;
        memcpy(buffer, sendIOCtrlMsgQueue[f].buffer, sendIOCtrlMsgQueue[f].buffer_size);
        
        memset(sendIOCtrlMsgQueue[f].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);
        sendIOCtrlMsgQueue[f].buffer_size = 0;
        sendIOCtrlMsgQueue[f].type = 0;
        
        front = f;
    }
    
    return 1;
}


@end
