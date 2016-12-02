//
//  UICheckBox.m
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-7.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import "UICheckBox.h"

@implementation UICheckBox

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    if (self= [super initWithFrame:frame])
    {
      

        UIFont* buttonFont=[UIFont fontWithName:@"Arial" size:16];
        
        
        boxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 18, 18)];
        [boxImageView setImage:[UIImage imageNamed:@"checkBox_bg.png"]];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [titleLabel setTextColor:[UIColor grayColor]];
        [titleLabel setText:title];
        [titleLabel setFont:buttonFont];        
        [titleLabel setFrame:CGRectMake(25,0,85, 20)];
        
        //添加字体下划线
        CGRect frame1=CGRectMake(0, 19, 85, 1);

        frame1.size.height = 1;
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:frame1];
        lineLabel1.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        [titleLabel addSubview:lineLabel1];
        [lineLabel1 release];
        
        

        
        

        
        [self addSubview:boxImageView];
        [self addSubview:titleLabel];
        
        [boxImageView release];
        [titleLabel release];
        
        [self addTarget:self action:@selector(onCheckBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        self.tag=0;
        
    }
    return self;
}

- (void)dealloc{

    [super dealloc];
}

- (void)onCheckBoxSelected:(id)sender
{
    printf("checkbox ----------\n");
    if (self.tag==0)
    {
        [boxImageView setImage:[UIImage imageNamed:@"checkBox_Selected_bg.png"]];
        self.tag=1;
    }else if(self.tag==1)
    {
        [boxImageView setImage:[UIImage imageNamed:@"checkBox_bg.png"]];
        self.tag=0;
    }
}



@end
