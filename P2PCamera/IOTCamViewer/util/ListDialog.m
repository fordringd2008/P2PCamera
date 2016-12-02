//
//  UIDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-10.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

const UIWindowLevel ListDialogWindowLevelSIAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel ListDialogWindowLevelSIAlertBackground = 1998.0; // below the alert window

#import "ListDialog.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListDialog
@synthesize listDialogView;
@synthesize listDialogDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelAlert;
        
        listDialogView = [[ListDialogView alloc] initWithFrame:self.bounds];
        listDialogView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

        listDialogView.listDialogViewDelegate=self;
        
        [self addSubview:listDialogView];
    
        [listDialogView release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"listDialog_MakeMainDialogDisappeared" object:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"listDialog_MakeMainDialogDisappeared" object:nil];
    [super dealloc];
}

- (void)show {

    
    [self showBackground];
    [self makeKeyAndVisible];
    
    
    listDialogView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         listDialogView.alpha = 1;
                     }];
    
}
- (void)dismiss
{
    [self hideBackgroundAnimated];
    [self resignKeyWindow];
    
    [self release];
}
- (void)showBackground
{
    if (!_listDialogBG_window) {
        _listDialogBG_window = [[ListDialogBGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                                             andStyle:SIAlertViewBackgroundStyleGradient];
        [_listDialogBG_window makeKeyAndVisible];
        _listDialogBG_window.alpha = 0.05;

    }
}

- (void)hideBackgroundAnimated
{

    _listDialogBG_window.alpha = 0;
    [_listDialogBG_window removeFromSuperview];
    [_listDialogBG_window release];
    _listDialogBG_window=nil;

}



- (void)setDialogBackGroundImage:(NSString*)imageString
{

    [self.listDialogView setDialogBGImage:imageString];
}

#pragma mark DialogView Delegate
- (void)onDialogViewReconnectButtonSelected
{
    if([self.listDialogDelegate respondsToSelector:@selector(onReconnectButtonSelected)])
    {
            [listDialogDelegate onReconnectButtonSelected];
    }

    [self dismiss];;
}
- (void)onDialogViewSettingsButtonClicked
{
    if([self.listDialogDelegate respondsToSelector:@selector(onDeviceSettingsButtonClicked)])
    {
        [listDialogDelegate onDeviceSettingsButtonClicked];
    }

    [self dismiss];;
}
- (void)onDialogViewLocalRecordButtonSelected
{
    if([self.listDialogDelegate respondsToSelector:@selector(onLocalRecordButtonSelected)])
    {
        [listDialogDelegate onLocalRecordButtonSelected];
    }

    [self dismiss];;
}
- (void)onDialogViewRemoteEventsButtonSelected
{
    if([self.listDialogDelegate respondsToSelector:@selector(onRemoteEventsButtonSelected)])
    {
         [listDialogDelegate onRemoteEventsButtonSelected];
    }

    [self dismiss];
}
- (void)onDialogViewCancelButtonSelected
{
    [self dismiss];
}

- (void)onDialogViewDeleteButtonSelected
{
    if([self.listDialogDelegate respondsToSelector:@selector(onDeleteDeviceButtonSelected)])
    {
        [listDialogDelegate onDeleteDeviceButtonSelected];
    }

    [self dismiss];
}

@end




@implementation ListDialogBGWindow

- (id)initWithFrame:(CGRect)frame andStyle:(SIAlertViewBackgroundStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = ListDialogWindowLevelSIAlertBackground;
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
        case SIAlertViewBackgroundStyleGradient:
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
        case SIAlertViewBackgroundStyleSolid:
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"listDialog_MakeMainDialogDisappeared" object:nil];
}

@end


