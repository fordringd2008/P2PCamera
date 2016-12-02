//
//  AudioCollector.m
//  IOTCamViewer
//
//  Created by chenchao on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioCollector.h"

@interface AudioCollector()
@property (readwrite) AudioQueueRef audioQueue;
@end

@implementation AudioCollector

@synthesize delegate;
@synthesize audioQueue;
@synthesize avIndex;
@synthesize codec;

void audioQueueInputCallback (void *inUserData,
                              AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer,
                              const AudioTimeStamp *inStartTime,
                              UInt32 inNumberPacketDescriptions,
                              const AudioStreamPacketDescription *inPacketDescs) {
    
    AudioCollector *self = (AudioCollector *)inUserData;

    if (inNumberPacketDescriptions == 0 && self->format.mBytesPerPacket != 0){
        inNumberPacketDescriptions = inBuffer->mAudioDataByteSize / self->format.mBytesPerPacket;
    }
    
    //NSLog(@"audioQueueInputCallBack:(%lu, %lu)", inBuffer->mAudioDataBytesCapacity, inBuffer->mAudioDataByteSize);
        
    [self->delegate recvRecordingWithAvIndex:self.avIndex Codec:self.codec Data:inBuffer->mAudioData DataLength:inBuffer->mAudioDataBytesCapacity];     
    
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

- (int) computeRecordBufferSize:(const AudioStreamBasicDescription *)_format BufferTime:(float)seconds {
    
	int packets, frames, bytes = 0;
    
    frames = (int)ceil(seconds * _format->mSampleRate);
    
    if (_format->mBytesPerFrame > 0)
        bytes = frames * _format->mBytesPerFrame;
    else {
        UInt32 maxPacketSize;
        if (_format->mBytesPerPacket > 0)
            maxPacketSize = _format->mBytesPerPacket;	// constant packet size
        else {
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioQueueGetProperty(audioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
                                  &propertySize);
        }
        if (_format->mFramesPerPacket > 0)
            packets = frames / _format->mFramesPerPacket;
        else
            packets = frames;	// worst-case scenario: 1 frame in a packet
        if (packets == 0)		// sanity check
            packets = 1;
        bytes = packets * maxPacketSize;
    }
    
	return bytes;
}

- (id)initAudioCollectorWithAvIndex:(NSInteger)avIndex_ Codec:(NSInteger)codec_ AudioFormat:(AudioStreamBasicDescription)format_ Delegate:(id<AudioCollectorDelegate>)delegate_ {
    
  	self = [super init];
    
    if (self) {
        avIndex = avIndex_;
        codec = codec_;
        delegate = delegate_;
        format = format_;        
    }
    
	return self;  
}

- (void)start:(int)bufferSize;
{        
    if (AudioQueueNewInput(&format, audioQueueInputCallback, self, NULL, NULL, 0, &audioQueue) != noErr){
		return;
	}
    
    // allocate and enqueue buffers
    int i, bufferByteSize;
    
    //bufferByteSize = [self computeRecordBufferSize:&format BufferTime:kBufferDurationSeconds];	// enough bytes for half a second

    bufferByteSize = bufferSize;
    
    for (i = 0; i < kNumberRecordBuffers; ++i) {
        AudioQueueAllocateBuffer(audioQueue, bufferByteSize, &audioQueueBuffer[i]);                      
        AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer[i], 0, NULL);
    }
    
    if (audioQueue) {
        AudioQueueStart(audioQueue, NULL);
    }
    
    //UInt32 val = 1;
    //AudioQueueSetProperty(audioQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
}

- (void)stop {
    
    if (audioQueue) {
        AudioQueueStop(audioQueue, YES);
        AudioQueueDispose(audioQueue, YES);
        audioQueue = NULL;
    }
}

BOOL AudioQueueVerifyStatus(OSStatus status, char *file, int line) {
    
	if (status != noErr) {        
		char *s = (char *)&status;
		NSLog(@"error number: %ld error code: %c%c%c%c at %s:%i", status, s[3], s[2], s[1], s[0], file, line);
	}
    
	return status == noErr;
}

- (void)dealloc {
    
	[self stop];
    delegate = nil;
	[super dealloc];
}
@end
