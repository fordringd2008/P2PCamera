//
//  MessageDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

const UIWindowLevel MsgDialogWindowLevelAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel MsgDialogWindowLevelAlertBackground = 1998.0; // below the alert window
#import "MessageDialog.h"


@implementation MessageDialog

@synthesize messageDialogDelegate;

- (id)initWithFrame:(CGRect)frame
{

    if (self= [super initWithFrame:frame])
    {
        self.windowLevel = UIWindowLevelAlert;
        UIFont* titleFont=[UIFont fontWithName:@"Verdana-Bold" size:16];
        UIFont* detailFont=[UIFont fontWithName:@"Verdana" size:12];
        
        UIImageView*      backGroundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msgDialog_bg.png"]];
        [backGroundImageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:backGroundImageView];
        [backGroundImageView setUserInteractionEnabled:YES];
        [backGroundImageView release];
        
        UILabel*    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 214, 20)];
        [titleLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [titleLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [titleLabel setText:NSLocalizedString(@"Warning", @"")];
        [titleLabel setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
        [titleLabel setFont:titleFont];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        UILabel*    detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 37, 214, 20)];
        [detailLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [detailLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [detailLabel setText:NSLocalizedString(@"delete this camera?", @"")];
        [detailLabel setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
        [detailLabel setFont:detailFont];
        [detailLabel setTextAlignment:NSTextAlignmentCenter];


        UIButton*   okButton=[[UIButton alloc] initWithFrame:CGRectMake(19, 70, 88, 38)];
        [okButton setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.8]];
        [okButton setTitle:NSLocalizedString(@"ok", @"") forState:UIControlStateHighlighted];
        [okButton setTitle:NSLocalizedString(@"ok", @"") forState:UIControlStateSelected];
        [okButton setTitle:NSLocalizedString(@"ok", @"") forState:UIControlStateNormal];
        [okButton.titleLabel setFont:titleFont];
        
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [okButton addTarget:self action:@selector(onOkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton*   cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(127, 70, 88, 38)];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:0.95 green:0.0 blue:0.0 alpha:0.5]];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateHighlighted];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateSelected];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:titleFont];
        
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(onCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"msgDialog_makeMainDialogDisappeared" object:nil];
        
        [self addSubview:titleLabel];
        [self addSubview:detailLabel];
        [self addSubview:okButton];
        [self addSubview:cancelButton];
        
        [titleLabel release];
        [detailLabel release];
        [okButton release];
        [cancelButton release];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"msgDialog_makeMainDialogDisappeared" object:nil];
    [super dealloc];
}

- (void)show {
    
    [self makeKeyAndVisible];
    [self showBackground];
    
    self.alpha = 0.5;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
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
    if (!_msgDialogBG_Window) {
        _msgDialogBG_Window = [[MsgDialogBGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_msgDialogBG_Window makeKeyAndVisible];
        _msgDialogBG_Window.alpha = 0.05;
        
    }
}

- (void)hideBackgroundAnimated:(BOOL)animated
{
    
    _msgDialogBG_Window.alpha = 0;
    [_msgDialogBG_Window removeFromSuperview];
    [_msgDialogBG_Window release];
    _msgDialogBG_Window=nil;
    
}

- (void)onOkButtonClicked: (id)sender
{
    if([self.messageDialogDelegate respondsToSelector:@selector(messageDialogOkSelected)])
    {
        [self.messageDialogDelegate messageDialogOkSelected];
    }
    [self dismiss];
}
- (void)onCancelButtonClicked: (id)sender
{
    if([self.messageDialogDelegate respondsToSelector:@selector(messageDialogCancelSelected)])
    {
        [self.messageDialogDelegate messageDialogCancelSelected];
    }
    [self dismiss];
}


@end

@implementation MsgDialogBGWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = MsgDialogWindowLevelAlertBackground;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"msgDialog_makeMainDialogDisappeared" object:nil];
}

@end
