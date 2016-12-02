//
//  WindowMessage.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-18.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WindowMessage :  NSObject {
    
	NSInteger offsetLeft;
	NSInteger offsetTop;
	
	NSTimer *timer;
	
	UIView *view;
	NSString *text;
}

- (void)showFromView: (UIView*)superView;

+ (WindowMessage  *) makeText:(NSString *) text;

@end
