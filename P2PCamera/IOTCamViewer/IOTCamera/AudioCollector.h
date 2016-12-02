//
//  AudioCollector.h
//  IOTCamViewer
//
//  Created by chenchao on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kNumberRecordBuffers	5
#define kBufferDurationSeconds .5
#define VERIFY_STATUS(status)   (status, __FILE__, __LINE__)

@protocol AudioCollectorDelegate;

@interface AudioCollector : NSObject {
    
    id<AudioCollectorDelegate> delegate;
	AudioQueueRef audioQueue;
    AudioQueueBufferRef	audioQueueBuffer[kNumberRecordBuffers];
    AudioStreamBasicDescription format;
    
    NSInteger avIndex;
    NSInteger codec;
}

@property (nonatomic, retain) id<AudioCollectorDelegate>delegate;
@property (readonly) AudioQueueRef audioQueue;
@property NSInteger avIndex;
@property NSInteger codec;

- (id)initAudioCollectorWithAvIndex:(NSInteger)avIndex Codec:(NSInteger)codec AudioFormat:(AudioStreamBasicDescription) format Delegate:(id<AudioCollectorDelegate>)delegate;
- (void)stop;
- (void)start:(int)bufferSize;

BOOL AudioQueueVerifyStatus(OSStatus status, char *file, int line);

@end

@protocol AudioCollectorDelegate

- (void)recvRecordingWithAvIndex:(NSInteger)avIndex Codec:(NSInteger)codec Data:(void *)buff DataLength:(NSInteger)length;

@end
