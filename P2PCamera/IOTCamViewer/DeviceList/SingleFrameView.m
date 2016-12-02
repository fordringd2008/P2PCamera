//
//  FHSignalFrameView.m
//  apexisCam
//
//  Created by apexis on 13-1-12.
//  Copyright (c) 2013年 apexis. All rights reserved.
//

#define CONNECTION_STATE_NONE 0
#define CONNECTION_STATE_CONNECTING 1
#define CONNECTION_STATE_CONNECTED 2
#define CONNECTION_STATE_DISCONNECTED 3
#define CONNECTION_STATE_UNKNOWN_DEVICE 4
#define CONNECTION_STATE_WRONG_PASSWORD 5
#define CONNECTION_STATE_TIMEOUT 6
#define CONNECTION_STATE_UNSUPPORTED 7
#define CONNECTION_STATE_CONNECT_FAILED 8

#import "SingleFrameView.h"
#import "WindowMessage.h"

@implementation SingleFrameView

@synthesize singleFrameViewIndex;
@synthesize singleTouchPointDelegate;


- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        
        backGroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [statusImageView setImage:[UIImage imageNamed:@"videoClip.png"]];
        [statusImageView setUserInteractionEnabled:NO];
        
        UILabel* titleBGLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,frame.size.height-20,frame.size.width,20)];
        [titleBGLabel setBackgroundColor:[UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:0.8]];
        [titleBGLabel setUserInteractionEnabled:NO];
        
        UIFont* font=[UIFont fontWithName:@"Verdana" size:12];
        UIFont* notifyFont=[UIFont fontWithName:@"Verdana-Bold" size:10];
        signalViewNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,frame.size.height-20,frame.size.width,20)];
        [signalViewNameLabel setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0]];
        [signalViewNameLabel setFont:font];
        [signalViewNameLabel setTextAlignment:NSTextAlignmentCenter];
        [signalViewNameLabel setTextColor:[UIColor whiteColor]];
        [signalViewNameLabel setText:@""];
        [signalViewNameLabel setUserInteractionEnabled:NO];
        
        statusImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"singleImageStatus_red.png"]];
        [statusImageView setFrame:CGRectMake(8, frame.size.height-14, 8, 8)];
        [statusImageView setUserInteractionEnabled:NO];
        
        [self addSubview:backGroundImageView];
        [self addSubview:titleBGLabel];
        [self addSubview:signalViewNameLabel];
        [self addSubview:statusImageView];
        
        [backGroundImageView release];
        [statusImageView release];
        [titleBGLabel release];
        [signalViewNameLabel release];
        
        //长按事件
        UILongPressGestureRecognizer *longPress =[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handleLongPressedEventForView:)];
        longPress.delegate = self;
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
        [longPress release];
        
        
        notifyButton=[[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-15, 1, 15, 15)];
        [notifyButton setUserInteractionEnabled:NO];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        [notifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [notifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateHighlighted];
        [notifyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [notifyButton.titleLabel setContentMode:UIViewContentModeCenter];
        [notifyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [notifyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        notifyButton.contentEdgeInsets = UIEdgeInsetsMake(0.5,2, 0, 0);
  
        [notifyButton.titleLabel setFont:notifyFont];
        [notifyButton setHidden:YES];
        [self addSubview:notifyButton];
        [notifyButton release];
        

        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2-12, frame.size.height/2-12,25,25)];
        activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
        [activityIndicatorView setUserInteractionEnabled:NO];
        activityIndicatorView.hidesWhenStopped=YES;
        [self addSubview:activityIndicatorView];
        [activityIndicatorView release];


        
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}

- (void)setNetworkConnectedStatus: (int)status
{

    if(status==CONNECTION_STATE_CONNECTED)
    {
        [statusImageView setImage:[UIImage imageNamed:@"singleImageStatus_green.png"]];
        [statusImageView setUserInteractionEnabled:NO];
        [activityIndicatorView stopAnimating];
    }
    else if(status==CONNECTION_STATE_CONNECTING)
    {
        [statusImageView setImage:[UIImage imageNamed:@"singleImageStatus_red.png"]];
        [statusImageView setUserInteractionEnabled:NO];
        [activityIndicatorView stopAnimating];
        [activityIndicatorView startAnimating];
    }
    else if(status==CONNECTION_STATE_WRONG_PASSWORD)
    {

        [statusImageView setImage:[UIImage imageNamed:@"singleImageStatus_red.png"]];
        [statusImageView setUserInteractionEnabled:NO];
        [activityIndicatorView stopAnimating];
        
        [[WindowMessage makeText:NSLocalizedString(@"password error", @"")] showFromView:self];
    }
    else
    {
        [statusImageView setImage:[UIImage imageNamed:@"singleImageStatus_red.png"]];
        [statusImageView setUserInteractionEnabled:NO];
        [activityIndicatorView stopAnimating];
    }
    
    
}
- (void)setDeviceName: (NSString*)devName
{

    [signalViewNameLabel setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0]];
    [signalViewNameLabel setTextAlignment:NSTextAlignmentCenter];
    [signalViewNameLabel setTextColor:[UIColor whiteColor]];
    [signalViewNameLabel setText:devName];
    [signalViewNameLabel setUserInteractionEnabled:NO];
    
}
- (void)setRemoteNotificationsWithNumber: (NSInteger)number
{

    
    if(number<=0)
    {
        [notifyButton setHidden:YES];
    }
    else if((number>0)&&(number<10))
    {
        [notifyButton setFrame:CGRectMake(self.frame.size.width-15, 1, 15, 15)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1_bg.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1_bg.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1_bg.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateHighlighted];
        [notifyButton setHidden:NO];
    }
    else if((number>=10)&&(number<100))
    {
        [notifyButton setFrame:CGRectMake(self.frame.size.width-22, 1, 22, 15)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify10_bg.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify10_bg.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify10_bg.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateHighlighted];
        [notifyButton setHidden:NO];
    }
    else if((number>=100)&&(number<1000))
    {
        [notifyButton setFrame:CGRectMake(self.frame.size.width-27, 1, 27, 15)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify100_bg.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify100_bg.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify100_bg.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateHighlighted];
        [notifyButton setHidden:NO];
        
    }else if((number>=1000)&&(number<10000))
    {
        [notifyButton setFrame:CGRectMake(self.frame.size.width-34, 1, 34, 15)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateHighlighted];
        [notifyButton setHidden:NO];
    }
    else
    {
        [notifyButton setFrame:CGRectMake(self.frame.size.width-34, 1, 34, 15)];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateNormal];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateSelected];
        [notifyButton setBackgroundImage:[UIImage imageNamed:@"notify1000_bg.png"] forState:UIControlStateHighlighted];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",9999] forState:UIControlStateNormal];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",9999] forState:UIControlStateSelected];
        [notifyButton setTitle:[NSString stringWithFormat:@"%d",9999] forState:UIControlStateHighlighted];
        [notifyButton setHidden:NO];
    }
    


}
-(void)updateImage:(NSString*)imagePath
{
    

    
    if(imagePath!=nil)
    {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
        if(fileExists)
        {
            UIImage* imageFile=[[UIImage alloc] initWithContentsOfFile:imagePath];
            [backGroundImageView setImage:imageFile];
            [imageFile release];
        }
        else
        {
             [backGroundImageView setImage:[UIImage imageNamed:@"videoClip.png"]];
        }
       
       
    
    }

}



//触摸事件实现....
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.singleTouchPointDelegate respondsToSelector:@selector(onSingleTouchPointSelected:)])
    {
            [self.singleTouchPointDelegate onSingleTouchPointSelected:touches];
    }

}

- (void)handleLongPressedEventForView:(UILongPressGestureRecognizer *)gestureRecognizer
{

    if([self.singleTouchPointDelegate respondsToSelector:@selector(onLongPressTouchSelected:)])
    {
        [self.singleTouchPointDelegate onLongPressTouchSelected:gestureRecognizer];
    }
}



@end

