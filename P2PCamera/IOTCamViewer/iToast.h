//
//  iToast.h
//  iToast
//
//  Created by Diallo Mamadou Bobo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface iToast : NSObject {

	NSInteger offsetLeft;
	NSInteger offsetTop;
	
	NSTimer *timer;
	
	UIView *view;
	NSString *text;
}

- (void)showFromView: (UIView*)superView;

+ (iToast *) makeText:(NSString *) text;

@end

