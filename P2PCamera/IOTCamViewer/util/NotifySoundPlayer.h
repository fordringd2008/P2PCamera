//
//  SoundPlayer.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-5.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 

@interface NotifySoundPlayer : NSObject
{
    SystemSoundID soundID;
}

-(void)playingForVibrate;
-(void)playingSystemSoundEffect;
-(void)playingSoundEffectWith:(NSString *)filename;

@end
