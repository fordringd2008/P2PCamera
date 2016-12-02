//
//  APSearchCamViewController.h
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-19.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APAddCamDetailViewController.h"
#import "UIProgressDialog.h"

extern NSMutableArray *camera_list;
@interface APSearchCamViewController : UITableViewController
{
    NSMutableArray          *device_list;
    UIProgressDialog        *progressDialog;
}

@end
