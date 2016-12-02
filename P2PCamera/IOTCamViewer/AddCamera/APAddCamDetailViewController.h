//
//  APAddCamDetailViewController.h
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-19.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"
#import "AddCameraDelegate.h"
#import "FMDatabase.h"
#import "iToast.h"
#import "IOTCAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "UIProgressDialog.h"


#define NUMBER_OF_EDITABLE_ROWS 3

extern NSMutableArray *camera_list;
extern FMDatabase *database;

extern NSString* G_loginAccountName;
extern NSString *deviceTokenString;
extern APPLICATIONACCESSMODE appAccessModeGlobal;

@interface APAddCamDetailViewController : UITableViewController<UITextFieldDelegate,CameraDelegate>
{
    NSArray *fieldLabels;
    UITextField *textFieldName;
    UITextField *textFieldUID;
    UITextField *textFieldPassword;
    UITableView *tableView;
    NSString *uid;
    BOOL isNameFieldBecomeisFirstResponder;
    BOOL isPasswordFieldBecomeFirstResponder;
    
    UIProgressDialog        *progressDialog;
    Camera                  *myCamera;
    
    
}

@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) UITextField *textFieldName;
@property (nonatomic, retain) UITextField *textFieldUID;
@property (nonatomic, retain) UITextField *textFieldPassword;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (copy) NSString *uid;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)setNameFieldBecomeFirstResponder:(BOOL)value;
- (void)setPasswordFieldBecomeFirstResponder:(BOOL)value;

@end
