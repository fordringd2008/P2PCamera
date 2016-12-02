//
//  AddCameraDetailController.h
//  IOTCamViewer
//
//  Created by chenchao on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"
#import "AddCameraDelegate.h"
#import "FMDatabase.h"

@class Camera;

#define NUMBER_OF_EDITABLE_ROWS 3

extern NSMutableArray *camera_list;
extern FMDatabase *database;


@interface AddCameraDetailController : UIViewController 
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *fieldLabels;
    UITextField *textFieldName;
    UITextField *textFieldUID;
    UITextField *textFieldPassword;
    UITableView *tableView;
    NSString *uid;
    BOOL isNameFieldBecomeisFirstResponder;
    BOOL isPasswordFieldBecomeFirstResponder;
    
    id<AddCameraDelegate> delegate;
}

@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) UITextField *textFieldName;
@property (nonatomic, retain) UITextField *textFieldUID;
@property (nonatomic, retain) UITextField *textFieldPassword;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (copy) NSString *uid;
@property (nonatomic, retain) id<AddCameraDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<AddCameraDelegate>)delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)setNameFieldBecomeFirstResponder:(BOOL)value;
- (void)setPasswordFieldBecomeFirstResponder:(BOOL)value;

@end
