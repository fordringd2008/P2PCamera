//
//  ANVideoRecorder.m
//
//  IpCamera
//  Created by chenchao on 13-5-23.
//  Copyright (c) 2013年 aoni. All rights reserved.
//

#import "ANVideoRecorder.h"

static ANVideoRecorder* instance=nil;

@implementation ANVideoRecorder

@synthesize isRecordingVideo;
@synthesize fps;

+(ANVideoRecorder* ) getInstance
{
    @synchronized(self)
    {
        if(instance==nil){
            instance=[[ANVideoRecorder alloc] init];
        }
        
    }
    return instance;
}
- (id)init
{
    if(self=[super init])
    {
        isRecordingVideo=false;
         fps = 30;
        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartRecordingVideo) name:@"startRecordingVideo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStopRecordingVideo) name:@"stopRecordingVideo" object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Release Video Recorder Instance!!!!!! ");
    
    [instance release];
    instance=nil;
    [super dealloc];
}
- (void)initVideoAssertWriter
{
     
    NSError *error = nil;
   
    currentSeconds = 0;
    
    //写文件
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* path = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssAAAA"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *videoOutputPath=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",currentDateStr]];
   
   
    CGSize imageSize = CGSizeMake(640, 480);
    
    videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                       error:&error];
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSParameterAssert(videoWriter);
    
    
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
    
    
    
    videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:videoSettings] retain];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:imageSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:imageSize.width] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    videoInputPixelBufAdaptor = [[AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:attributes] retain];
    
    
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);

    [videoWriter addInput:videoWriterInput];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    BOOL start = [videoWriter startWriting];
    //printf("STATE: %d",start);
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    

}

- (void)writeVideoWithImageframe: (CGImageRef)frameImage
{
    
    CVPixelBufferRef buffer = NULL;
   
    if(isRecordingVideo)
    {
        
        if (videoInputPixelBufAdaptor.assetWriterInput.readyForMoreMediaData)
        {
            //printf("-----------------------------------write video Enter:%d\n",isRecordingVideo);
            currentSeconds++;
            //NSLog(@"inside for loop %d %@ ",i, filename);
            CMTime frameTime = CMTimeMake(1, fps);
            CMTime lastTime=CMTimeMake(currentSeconds, fps);
            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
            
            //NSString *filePath = [documents stringByAppendingPathComponent:filename];
            
            //UIImage *imgFrame = [UIImage imageWithContentsOfFile:filePath] ;
            buffer = [self pixelBufferFromCGImage:frameImage];
            BOOL result = [videoInputPixelBufAdaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            if (result == NO) //failes on 3GS, but works on iphone 4
            {
                //printf("failed to append buffer");
                //NSLog(@"The error is %@", [videoWriter error]);
            }
            if(buffer)
                CVBufferRelease(buffer);
        }
        else
        {
            //printf("error\n");
            currentSeconds--;
        }
    }

}

-(void)updateTimer
{
    currentSeconds++;
}

- (void)stopWrittingVideo
{
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    //CVPixelBufferPoolRelease(videoInputPixelBufAdaptor.pixelBufferPool);
    [videoInputPixelBufAdaptor release];
    [videoWriter release];
    [videoWriterInput release];
    
    currentSeconds=0;
}


- (void)recordAudio
{
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    
    
    NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
    // audio input file...
    NSString *audio_inputFilePath = [bundleDirectory stringByAppendingPathComponent:@"30secs.mp3"];
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    
    
    // this is the video file that was just written above, full path to file is in --> videoOutputPath
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:videoOutputPath];
    
    
    
    // create the final video output file as MOV file - may need to be MP4, but this works so far...
    NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    
    //AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    __block AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    
    NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
    _assetExport.outputURL = outputFileUrl;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch (_assetExport.status) {
            case AVAssetExportSessionStatusCompleted:
                // Custom method to import the Exported Video
                NSLog(@"completed!!!");
                break;
            case AVAssetExportSessionStatusFailed:
                //
                NSLog(@"Failed:%@",_assetExport.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                //
                NSLog(@"Canceled:%@",_assetExport.error);
                break;
            default:
                break;
        }
    }];
    
    
    
    ///// THAT IS IT DONE... the final video file will be written here...
    NSLog(@"DONE.....outputFilePath--->%@", outputFilePath);
    
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef)image
{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    //图像倒立变换
    //CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, CGImageGetHeight(image));
    //CGContextConcatCTM(context, flipVertical);
    //CGAffineTransform flipHorizontal = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0);
    //CGContextConcatCTM(context, flipHorizontal);
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

- (void)onStartRecordingVideo
{
    if(isRecordingVideo==true)
    {
        [self onStopRecordingVideo];
    }
    
    [instance initVideoAssertWriter];
    isRecordingVideo=true;
}
- (void)onStopRecordingVideo
{
    if(isRecordingVideo==true)
    {
      
        isRecordingVideo=false;
        [instance stopWrittingVideo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSubViewWhenRecordMovie" object:nil];
    }
}
@end
