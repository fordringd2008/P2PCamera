//
//  rootController.m
//  IOTCamViewer
//
//  Created by 百堅 蕭 on 12/4/24.
//  Copyright (c) 2012年 Throughtek Co., Ltd. All rights reserved.
//

#import "rootController.h"

@interface rootController ()

@end

@implementation rootController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    
    NSLog(@"willAnimateRotationToInterfaceOrientation");
}

@end
