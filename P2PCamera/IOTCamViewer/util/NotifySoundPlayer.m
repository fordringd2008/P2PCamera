//
//  SoundPlayer.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-5.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "NotifySoundPlayer.h"

@implementation NotifySoundPlayer

-(id)init
{
    if(self=[super init])
    {
        soundID = kSystemSoundID_Vibrate;
    }
    
    return self;
}

-(void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
    [super dealloc];
}

-(void)playingForVibrate
{
    soundID = kSystemSoundID_Vibrate;
}
-(void)playingSystemSoundEffect
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
    if (path)
    {
        SystemSoundID theSoundID;
        OSStatus error =  AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
        if (error == kAudioServicesNoError)
        {
            soundID = theSoundID;
        }else
        {
            NSLog(@"Failed to create sound ");
        }
    }
    
}
-(void)playingSoundEffectWithFile:(NSString *)filename
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    if (fileURL != nil)
    {
        SystemSoundID theSoundID;
        OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &theSoundID);
        if (error == kAudioServicesNoError)
        {
            soundID = theSoundID;
        }else
        {
            NSLog(@"Failed to create sound ");
        }
    }
}

@end
