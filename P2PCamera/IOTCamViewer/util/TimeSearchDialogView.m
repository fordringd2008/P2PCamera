//
//  TimeSearchDialogView.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-15.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "TimeSearchDialogView.h"

@implementation TimeSearchDialogView


@synthesize timeSearchDialogViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

        UIFont* titleFont=[UIFont fontWithName:@"Verdana-Bold" size:16];
        
        UILabel*    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
        [titleLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [titleLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [titleLabel setText:NSLocalizedString(@"Events filter", @"")];
        [titleLabel setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
        [titleLabel setFont:titleFont];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        aHourButton=[[UIButton alloc] initWithFrame:CGRectMake(20, 55, 180, 35)];
        [aHourButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]];
        [aHourButton setTitle:NSLocalizedString(@"Within an hour", @"") forState:UIControlStateHighlighted];
        [aHourButton setTitle:NSLocalizedString(@"Within an hour", @"") forState:UIControlStateSelected];
        [aHourButton setTitle:NSLocalizedString(@"Within an hour", @"") forState:UIControlStateNormal];
        
        [aHourButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [aHourButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [aHourButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [aHourButton addTarget:self action:@selector(onTimeSearchButton1Hour:) forControlEvents:UIControlEventTouchUpInside];
        
        aDayButton=[[UIButton alloc] initWithFrame:CGRectMake(20, 105, 180, 35)];
        [aDayButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]];
        [aDayButton setTitle:NSLocalizedString(@"Within a day", @"") forState:UIControlStateHighlighted];
        [aDayButton setTitle:NSLocalizedString(@"Within a day", @"") forState:UIControlStateSelected];
        [aDayButton setTitle:NSLocalizedString(@"Within a day", @"") forState:UIControlStateNormal];
        
        [aDayButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [aDayButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [aDayButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [aDayButton addTarget:self action:@selector(onTimeSearchButton1Day:) forControlEvents:UIControlEventTouchUpInside];
        
        aWeekButton=[[UIButton alloc] initWithFrame:CGRectMake(20, 155, 180, 35)];
        [aWeekButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]];
        [aWeekButton setTitle:NSLocalizedString(@"Within a week", @"") forState:UIControlStateHighlighted];
        [aWeekButton setTitle:NSLocalizedString(@"Within a week", @"") forState:UIControlStateSelected];
        [aWeekButton setTitle:NSLocalizedString(@"Within a week", @"") forState:UIControlStateNormal];
        
        [aWeekButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [aWeekButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [aWeekButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [aWeekButton addTarget:self action:@selector(onTimeSearchButton1Week:) forControlEvents:UIControlEventTouchUpInside];
        
        allButton=[[UIButton alloc] initWithFrame:CGRectMake(20, 205, 180, 35)];
        [allButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]];
        [allButton setTitle:NSLocalizedString(@"All events", @"") forState:UIControlStateHighlighted];
        [allButton setTitle:NSLocalizedString(@"All events", @"") forState:UIControlStateSelected];
        [allButton setTitle:NSLocalizedString(@"All events", @"") forState:UIControlStateNormal];
        
        [allButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateNormal];
        [allButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateSelected];
        [allButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] forState:UIControlStateHighlighted];
        [allButton addTarget:self action:@selector(onTimeSearchButtonAll:) forControlEvents:UIControlEventTouchUpInside];
        
        cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(20, 255, 180, 35)];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:0.6]];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateHighlighted];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateSelected];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(onTimeSearchButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:titleLabel];
        [self addSubview:aHourButton];
        [self addSubview:aDayButton];
        [self addSubview:aWeekButton];
        [self addSubview:allButton];
        [self addSubview:cancelButton];
        
        
        
        
        [titleLabel release];
        [aHourButton release];
        [aDayButton release];
        [aWeekButton release];
        [allButton release];
        [cancelButton release];
        
    }
    return self;
}

- (void)onTimeSearchButton1Hour: (id)sender
{
    [timeSearchDialogViewDelegate onTimeSearchDialogView1Hour];
}
- (void)onTimeSearchButton1Day: (id)sender
{
    [timeSearchDialogViewDelegate onTimeSearchDialogView1Day];
}
- (void)onTimeSearchButton1Week: (id)sender
{
    [timeSearchDialogViewDelegate onTimeSearchDialogView1Week];
}
- (void)onTimeSearchButtonAll: (id)sender
{
    [timeSearchDialogViewDelegate onTimeSearchDialogViewAll];
}
- (void)onTimeSearchButtonCancel: (id)sender
{
    [timeSearchDialogViewDelegate onTimeSearchDialogViewCancel];
}


- (void)dealloc
{
    [super dealloc];
}

@end

