//
//  UserAccountDialog.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-10-11.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "UserAccountDialog.h"
#import <QuartzCore/QuartzCore.h>

const UIWindowLevel UserAccountDialogWindowLevelAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel UserAccountDialogWindowLevelAlertBackground = 1998.0; // below the alert window

@implementation UserAccountDialog

@synthesize userAccountDlgDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelAlert;
        UIFont* titleFont=[UIFont fontWithName:@"Verdana" size:16];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"userDialog_makeMainDialogDisappeared" object:nil];
        
        
        UIImageView* headerDialogView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerDialog_bg.png"]];

        [headerDialogView setFrame:CGRectMake(0, 0, 130, 240)];
        [self addSubview:headerDialogView];
        [headerDialogView release];
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.layer.cornerRadius = 4;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 0.9;
        
        UIButton* addDeviceButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 40, 110, 30)];
        [addDeviceButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2]];
        [addDeviceButton setTitle:NSLocalizedString(@"Add device",@"") forState:UIControlStateHighlighted];
        [addDeviceButton setTitle:NSLocalizedString(@"Add device",@"") forState:UIControlStateSelected];
        [addDeviceButton setTitle:NSLocalizedString(@"Add device",@"") forState:UIControlStateNormal];
        [addDeviceButton.titleLabel setFont:titleFont];
        [addDeviceButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [addDeviceButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [addDeviceButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [addDeviceButton addTarget:self action:@selector(onAddDeviceButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* accountSettingsButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 90, 110, 30)];
        [accountSettingsButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2]];
        [accountSettingsButton setTitle:NSLocalizedString(@"Setting",@"") forState:UIControlStateHighlighted];
        [accountSettingsButton setTitle:NSLocalizedString(@"Setting",@"") forState:UIControlStateSelected];
        [accountSettingsButton setTitle:NSLocalizedString(@"Setting",@"") forState:UIControlStateNormal];
        [accountSettingsButton.titleLabel setFont:titleFont];
        [accountSettingsButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [accountSettingsButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [accountSettingsButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [accountSettingsButton addTarget:self action:@selector(onAccountSettingsSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* appInfoButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 140, 110, 30)];
        [appInfoButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2]];
        [appInfoButton setTitle:NSLocalizedString(@"App info",@"") forState:UIControlStateHighlighted];
        [appInfoButton setTitle:NSLocalizedString(@"App info",@"") forState:UIControlStateSelected];
        [appInfoButton setTitle:NSLocalizedString(@"App info",@"") forState:UIControlStateNormal];
        [appInfoButton.titleLabel setFont:titleFont];
        [appInfoButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] forState:UIControlStateNormal];
        [appInfoButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] forState:UIControlStateSelected];
        [appInfoButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] forState:UIControlStateHighlighted];
        [appInfoButton addTarget:self action:@selector(onAppInfoButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton* cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 190, 110, 30)];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:0.95 green:0.0 blue:0.0 alpha:0.5]];
        [cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateHighlighted];
        [cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateSelected];
        [cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:titleFont];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(onCancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];

        
        [self addSubview:cancelButton];
        [self addSubview:accountSettingsButton];
        [self addSubview:addDeviceButton];
        [self addSubview:appInfoButton];
        
        [accountSettingsButton release];
        [addDeviceButton release];
        [appInfoButton release];
        [cancelButton release];
    }
    
    return self;
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userDialog_makeMainDialogDisappeared" object:nil];
    [super dealloc];
}

- (void)show {

    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    [self makeKeyAndVisible];
    [self showBackground];
    
    self.alpha = 0.5;
    [self setFrame:CGRectMake(screenSize.width+130, 55, 140, 240)];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
                        [self setFrame:CGRectMake(screenSize.width-135, 55, 130, 240)];
                     }];
    
}
- (void)dismiss
{
    [self hideBackgroundAnimated:YES];
    [self resignKeyWindow];
    [self release];
}

- (void)onAddDeviceButtonSelected:(id)sender
{
    if([self.userAccountDlgDelegate respondsToSelector:@selector(userAccountDlg_AddDeviceButtonSelected)])
    {
        [userAccountDlgDelegate userAccountDlg_AddDeviceButtonSelected];
    }

    [self dismiss];
}
- (void)onAccountSettingsSelected:(id)sender
{
    [userAccountDlgDelegate userAccountDlg_AccountSettingsSelected];
    [self dismiss];
}
- (void)onAppInfoButtonSelected:(id)sender
{
    if([self.userAccountDlgDelegate respondsToSelector:@selector(userAccountDlg_AppInfoSelected)])
    {
        [userAccountDlgDelegate userAccountDlg_AppInfoSelected];
    }

    [self dismiss];
}
- (void)onCancelButtonSelected:(id)sender
{
//    if([self.userAccountDlgDelegate respondsToSelector:@selector(userAccountDlg_CancelSelected)])
//    {
//        [userAccountDlgDelegate userAccountDlg_CancelSelected];
//    }
    
    [self dismiss];
}


- (void)showBackground
{
    if (!_userAccountDialogBG_window) {
        _userAccountDialogBG_window = [[UserAccountDialogBGWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_userAccountDialogBG_window makeKeyAndVisible];
        _userAccountDialogBG_window.alpha = 0.05;

    }
}

- (void)hideBackgroundAnimated:(BOOL)animated
{
    
    _userAccountDialogBG_window.alpha = 0;
    [_userAccountDialogBG_window removeFromSuperview];
    [_userAccountDialogBG_window release];
    _userAccountDialogBG_window=nil;
    
}



@end





@implementation UserAccountDialogBGWindow

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UserAccountDialogWindowLevelAlertBackground;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDialog_makeMainDialogDisappeared" object:nil];
}

@end
