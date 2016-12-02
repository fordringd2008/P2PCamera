//
//  AddCameraController.h
//  IOTCamViewer
//
//  Created by chenchao on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddCameraDelegate.h"
#import "LANSearchController.h"
#import "AddCameraDetailController.h"
#import "ScanTDCodeViewController.h"

extern NSString* G_loginAccountName;
extern NSString *deviceTokenString;
extern APPLICATIONACCESSMODE appAccessModeGlobal;

@interface AddCameraController : UIViewController
<ScanTDCodeControllerDelegate,LANSearchDelegate, AddCameraDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIButton *addCameraButton;
    UIButton *scanCameraButton;
    UIButton *searchCameraButton;
    UITableView *_tableView;
    NSMutableArray *device_list;
}


- (void)addCameraByTypingPressed:(id)sender;
- (void)addCameraByScanPressed:(id)sender;
- (IBAction)searchCameraPressed:(id)sender;

@end
