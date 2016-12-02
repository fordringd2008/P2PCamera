//
//  UIProgressDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-20.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "UIProgressDialog.h"

const UIWindowLevel ProgressDialogWindowLevelAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel ProgressDialogWindowLevelAlertBackground = 1998.0; // below the alert window

@implementation UIProgressDialog

- (id)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame])
    {
        UIFont* labelFont=[UIFont fontWithName:@"Arial-BoldMT" size:18];
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width/2-15 ,30,30,screenSize.height)];
        activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
        activityIndicatorView.hidesWhenStopped=YES;
        activityIndicatorView.userInteractionEnabled=NO;
        [self addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        showLabel=[[UILabel alloc] initWithFrame:CGRectMake(screenSize.width/2-130 ,screenSize.height/2-50,260,30)];
        [showLabel setText:@""];
        [showLabel setFont:labelFont];
        [showLabel setTextColor:[UIColor whiteColor]];
        [showLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:showLabel];
        
        [showLabel release];
        

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setProgressShowString: (NSString*)aString
{
    [showLabel setText:aString];
}
- (void)show {
    
    [self makeKeyAndVisible];
    [self showBackground];
    
    [activityIndicatorView startAnimating];
    
    self.alpha = 0.5;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
                     }];
    
}
- (void)dismiss
{
    [activityIndicatorView stopAnimating];
    [self hideBackgroundAnimated:YES];
    [self resignKeyWindow];
    [self release];
}
- (void)showBackground
{
    if (!_progressDlgBGWindow) {
        _progressDlgBGWindow = [[ProgressDialogBGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_progressDlgBGWindow makeKeyAndVisible];
        _progressDlgBGWindow.alpha = 0.05;
        
    }
}

- (void)hideBackgroundAnimated:(BOOL)animated
{
    
    _progressDlgBGWindow.alpha = 0;
    [_progressDlgBGWindow removeFromSuperview];
    [_progressDlgBGWindow release];
    _progressDlgBGWindow=nil;
    
}


@end


@implementation ProgressDialogBGWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = ProgressDialogWindowLevelAlertBackground;
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end
