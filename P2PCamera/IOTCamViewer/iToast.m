//
//  iToast.m
//  iToast
//
//  Created by Diallo Mamadou Bobo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iToast.h"
#import <QuartzCore/QuartzCore.h>


@implementation iToast


- (id) initWithText:(NSString *) tex{
	if (self = [super init]) {
		text = [tex copy];
	}
	
	return self;
}
- (void)dealloc
{
    [text release];
    [super dealloc];
}
- (void) showFromView: (UIView*)superView
{

	UIFont*    font=[UIFont fontWithName:@"Verdana" size:16];
	CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(280, 60)];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 5, textSize.height + 5)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = font;
	label.text = text;
	label.numberOfLines = 0;
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(1, 1);
	
	UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
	v.frame = CGRectMake(0, 0, textSize.width + 10, textSize.height + 10);
	label.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
	[v addSubview:label];
    [label release];
	
	v.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
	v.layer.cornerRadius = 2;
	
	
	CGPoint point = CGPointMake(superView.frame.size.width/2, superView.frame.size.height/2);
	

	
	point = CGPointMake(point.x + offsetLeft, point.y + offsetTop);
	v.center = point;
	
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:1
											 target:self selector:@selector(hideToast) 
										   userInfo:nil repeats:NO];
    
	[[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	
	[superView addSubview:v];
    [superView bringSubviewToFront:v];
	
	view = [v retain];
	
}

- (void) hideToast
{
	[UIView beginAnimations:nil context:NULL];
	
    [UIView animateWithDuration:0.2
                     animations:^{
                         view.alpha = 0;;
                     }];
	[UIView commitAnimations];
	
    [view removeFromSuperview];
    [view release];
}


+ (iToast *) makeText:(NSString *) _text{
	iToast *toast = [[[iToast alloc] initWithText:_text] autorelease];
	return toast;
}



@end

