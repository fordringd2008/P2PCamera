//
//  TimeSearchDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//
const UIWindowLevel TimeSearchBGWindowLevelAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel TimeSearchBGWindowLevelBackground = 1998.0; // below the alert window

#import "TimeSearchDialog.h"
#import <QuartzCore/QuartzCore.h>


@implementation TimeSearchDialog

@synthesize timeSearchDialogView;
@synthesize timeSearchDialogDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelAlert;
        
        timeSearchDialogView = [[TimeSearchDialogView alloc] initWithFrame:self.bounds];
        timeSearchDialogView.backgroundColor = [UIColor whiteColor];
        timeSearchDialogView.layer.cornerRadius = 4;
        timeSearchDialogView.layer.shadowOffset = CGSizeZero;
        timeSearchDialogView.layer.shadowRadius = 8;
        timeSearchDialogView.layer.shadowOpacity = 0.5;
        timeSearchDialogView.timeSearchDialogViewDelegate=self;
        
        [self addSubview:timeSearchDialogView];
        
        [timeSearchDialogView release];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"timeSearchDialog_makeMainDialogDisappeared" object:nil];
        
        
    }
    
    return self;
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"timeSearchDialog_makeMainDialogDisappeared" object:nil];
    [super dealloc];
}

- (void)show {
    
    [self showBackground];
    [self makeKeyAndVisible];
    

    
    timeSearchDialogView.alpha = 0.5;
    [UIView animateWithDuration:0.1
                     animations:^{
                         timeSearchDialogView.alpha = 1;
                     }];
    
}
- (void)dismiss
{
    [self hideBackgroundAnimated:YES];
    [self resignKeyWindow];
    [self release];
}
- (void)showBackground
{
    if (!timeSearch_background_window) {
        timeSearch_background_window = [[TimeSearchBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                                             andStyle:TimeSearchBackgroundWindowStyleGradient];
        [timeSearch_background_window makeKeyAndVisible];
        timeSearch_background_window.alpha = 0.5;
        [UIView animateWithDuration:0.1
                         animations:^{
                             timeSearch_background_window.alpha = 1;
                         }];
    }
}

- (void)hideBackgroundAnimated:(BOOL)animated
{
    
    timeSearch_background_window.alpha = 0;
    [timeSearch_background_window removeFromSuperview];
    [timeSearch_background_window release];
    timeSearch_background_window=nil;
    
}


#pragma mark DialogView Delegate
- (void)onTimeSearchDialogView1Hour
{
    if([self.timeSearchDialogDelegate respondsToSelector:@selector(onTimeSearchDialog1Hour)])
    {
         [timeSearchDialogDelegate onTimeSearchDialog1Hour];
    }
    [self dismiss];
}
- (void)onTimeSearchDialogView1Day
{
    if([self.timeSearchDialogDelegate respondsToSelector:@selector(onTimeSearchDialog1Day)])
    {
        [timeSearchDialogDelegate onTimeSearchDialog1Day];
    }
    [self dismiss];
}
- (void)onTimeSearchDialogView1Week
{
    if([self.timeSearchDialogDelegate respondsToSelector:@selector(onTimeSearchDialog1Week)])
    {
        [timeSearchDialogDelegate onTimeSearchDialog1Week];
    }
    [self dismiss];
}
- (void)onTimeSearchDialogViewAll
{
    if([self.timeSearchDialogDelegate respondsToSelector:@selector(onTimeSearchDialogAll)])
    {
        [timeSearchDialogDelegate onTimeSearchDialogAll];
    }
    [self dismiss];
}
- (void)onTimeSearchDialogViewCancel
{
    [self dismiss];
}

@end




@implementation TimeSearchBackgroundWindow

- (id)initWithFrame:(CGRect)frame andStyle:(TimeSearchBackgroundWindowBGStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = TimeSearchBGWindowLevelBackground;
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
    switch (self.style) {
        case TimeSearchBackgroundWindowStyleGradient:
        {
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
            break;
        }
        case TimeSearchBackgroundWindowStyleSolid:
        {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timeSearchDialog_makeMainDialogDisappeared" object:nil];
}

@end
