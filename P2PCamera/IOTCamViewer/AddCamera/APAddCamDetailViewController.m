//
//  APAddCamDetailViewController.m
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-19.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "APAddCamDetailViewController.h"



@implementation APAddCamDetailViewController

@synthesize fieldLabels;
@synthesize textFieldName, textFieldUID, textFieldPassword;
@synthesize uid;
@synthesize tableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    if(self=[super initWithStyle:style])
    {
        
        NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Name", @""), NSLocalizedString(@"UID", @""), NSLocalizedString(@"Password", @""), nil];
        self.fieldLabels = array;
        [array release];
        
        
        self.navigationItem.title = NSLocalizedString(@"Add device", @"");
        
        UIButton* saveButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton.png"] forState:UIControlStateNormal];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton.png"] forState:UIControlStateHighlighted];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton.png"] forState:UIControlStateSelected];
        [saveButton addTarget:self action:@selector(saveAddCameraInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc] initWithCustomView:saveButton];
        
        self.navigationItem.rightBarButtonItem=saveButtonItem;
        [saveButton release];
        [saveButtonItem release];
        
        
        
        UIButton* cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateHighlighted];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateSelected];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelButtonItem=[[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        
        [self.navigationItem setLeftBarButtonItem:cancelButtonItem];
        
        [cancelButton release];
        [cancelButtonItem release];
        
        

    }
    return self;
}


- (void)dealloc {
    
    [self.tableView release];
    [self.fieldLabels release];
    [self.textFieldName release];
    [self.textFieldUID release];
    [self.textFieldPassword release];
    [super dealloc];
}
- (NSString *)URLEncodedString:(NSString *)string
{
    NSString *result = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)string,
                                                                          NULL,
                                                                          CFSTR("\"\\.-_!~|{}^!*'();:@&=+$,/?%#[]"),
                                                                          kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (isNameFieldBecomeisFirstResponder) {
        [self.textFieldName becomeFirstResponder];
    }
    
    if (isPasswordFieldBecomeFirstResponder) {
        [self.textFieldPassword becomeFirstResponder];
    }
    
    [super viewDidAppear:animated];
}
- (void)setNameFieldBecomeFirstResponder:(BOOL)value {
    
    isNameFieldBecomeisFirstResponder = value;
}

- (void)setPasswordFieldBecomeFirstResponder:(BOOL)value {
    
    isPasswordFieldBecomeFirstResponder = value;
}



- (void)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAddCameraInfo:(id)sender {
    
    NSString *name = textFieldName.text;
    NSString *uid_ = textFieldUID.text;
    NSString *password = textFieldPassword.text;
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    uid_ = [uid_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
    if (uid_ == nil || [uid_ length] != 20) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera UID length must be 20 characters", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if (name == nil || [name length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera Name can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if (password == nil || [password length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera Password can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if ([name length] > 0 && [uid_ length] == 20 && [password length] > 0) {
        
        for (Camera *cam in camera_list) {
            
            if ([cam.uid isEqualToString:uid_]) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"This device UID is already exists", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                return;
            }
            if([cam.name isEqualToString:name])
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"This device name is already exists", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
        }
        
        

        [self startConnectCamera];
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"The name, uid and password field can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - AddCameraDelegate Methods
- (void)startConnectCamera
{
    NSString *name_ = textFieldName.text;
    NSString *uid_ = textFieldUID.text;
    NSString *password_ = textFieldPassword.text;
    
    myCamera = [[Camera alloc] initWithUID:uid_ camName:name_ viewAccount:@"admin" viewPassword:password_];
    myCamera.cameraDelegate=self;
    [myCamera connect];
    
    progressDialog=[[UIProgressDialog alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [progressDialog setProgressShowString:NSLocalizedString(@"Connecting device...",@"")];
    
    [progressDialog show];


}

- (void)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == textFieldName) {
        [textFieldUID becomeFirstResponder];
    }
    
    if (textField == textFieldUID) {
        [textFieldPassword becomeFirstResponder];
    }
    
    return YES;
}



#pragma mark - Table DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return NUMBER_OF_EDITABLE_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger row = [indexPath row];
    
    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    
    static NSString *AddCameraCellIdentifier = @"AddCameraCellIdentifier";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:
                             AddCameraCellIdentifier];
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:AddCameraCellIdentifier] autorelease];
        
        cell.textLabel.text = [fieldLabels objectAtIndex:row];
        
        if (row == 0) {
            
            textFieldName = [[UITextField alloc] initWithFrame: CGRectMake(115, 11, screenSize.width-120, 25)];
            textFieldName.placeholder = NSLocalizedString(@"Camera Name", @"");
            textFieldName.clearsOnBeginEditing = NO;
            textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textFieldName setDelegate:self];
            [textFieldName addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldName];
            
        } else if (row == 1) {
            
            textFieldUID = [[UITextField alloc] initWithFrame: CGRectMake(115, 11, screenSize.width-120, 25)];
            textFieldUID.placeholder = NSLocalizedString(@"Camera UID", @"");
            textFieldUID.clearsOnBeginEditing = NO;
            textFieldUID.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textFieldUID setDelegate:self];
            [textFieldUID addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldUID];
            
            
        } else if (row == 2) {
            
            textFieldPassword = [[UITextField alloc] initWithFrame: CGRectMake(115, 11, screenSize.width-120, 25)];
            textFieldPassword.placeholder = NSLocalizedString(@"Camera Password", @"");
            textFieldPassword.clearsOnBeginEditing = NO;
            textFieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
            textFieldPassword.secureTextEntry = YES;
            [textFieldPassword setDelegate:self];
            [textFieldPassword addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldPassword];
            
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (row) {
            
        case 0:
        {
            if (self.textFieldName.text.length == 0) {
                self.textFieldName.text = @"Camera";
                //self.textFieldName.text = NSLocalizedString(@"Camera", @"");
            }
            
            textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
            break;
            
        case 1:
        {
            textFieldUID.text = self.uid;
            textFieldUID.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
            break;
            
        case 2:
        {
            textFieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark - Text Field Delegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 99) {
        
        NSUInteger len = [textField.text length] + [string length] - range.length;
        
        if (len <= 20)
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        
        return NO;
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow) {
        [textField.window makeKeyAndVisible];
    }
}
#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

//CameraDelegate
- (void)camera:(Camera *)_camera connect_updateConnectIndex4SessionStates:(NSInteger)states
{
    if(_camera==myCamera)
    {

        if(states==CONNECTION_STATE_CONNECTED)
        {
            NSString *name_ = textFieldName.text;
            NSString *uid_ = textFieldUID.text;
            NSString *password_ = textFieldPassword.text;
            
            if(progressDialog){
                [progressDialog dismiss];
            }
            
           
            
            
            [camera_list addObject:myCamera];
            [myCamera release];
            
            // 添加设备到本地数据库.
            if(appAccessModeGlobal==APPLICATIONACCESSMODE_LOCAL)
            {
                if (database != NULL) {
                    [database executeUpdate:@"INSERT INTO device(dev_uid, dev_nickname, dev_name, dev_pwd, view_acc, view_pwd) VALUES(?,?,?,?,?,?)",
                     myCamera.uid, name_, name_, password_, @"admin", password_];
                }
            }
            else if(appAccessModeGlobal==APPLICATIONACCESSMODE_NETWORK)
            {
                
                // 添加设备到服务器数据库.
                dispatch_queue_t addDeviceQueue = dispatch_queue_create("device-addServerDB", NULL);
                dispatch_async(addDeviceQueue, ^{
                    if (( uid_!= nil)&&(name_!=nil)&&(password_!=nil)) {
                        NSError *error = nil;
                        
                        NSString* addString=[NSString stringWithFormat:@"http://www.p2picamera.com/UserAccount/deviceEdit.php?cmd=insert&deviceName=%@&deviceUID=%@&devicePwd=%@",[self URLEncodedString:name_],uid_,[self URLEncodedString:password_]];
                        //NSLog(@"Add camera String: %@\n",addString);
                        
                        
                        NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:addString] encoding:NSUTF8StringEncoding error:&error];
                        
                        NSLog(@"ADD TO DB SERVER:%@", registerResult);
                    }
                });
                dispatch_release(addDeviceQueue);
                
            }
            
            // register to apns server
            dispatch_queue_t addRegQueue = dispatch_queue_create("apns-addReg_client", NULL);
            dispatch_async(addRegQueue, ^{
                if (deviceTokenString != nil) {
                    NSError *error = nil;
                    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
                    NSString *hostString = @"http://www.p2picamera.com/iPhonePush/apns.php";
                    NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@";
                    NSString *getURLString = [NSString stringWithFormat:argsString, hostString, deviceTokenString, uid_, appidString];
                    NSLog(@"%@", getURLString);
                    NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
                    
                    NSLog(@"%@", registerResult);
                }
            });
            dispatch_release(addRegQueue);
            
            
            //更新窗口消息.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"msgAddCameraAndrefreshWindow" object:nil];
            

        }
        else if(states==CONNECTION_STATE_WRONG_PASSWORD)
        {
            if(progressDialog){
                [progressDialog dismiss];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect Failed", @"") message:NSLocalizedString(@"This camera connect failed,because of wrong password.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            if(progressDialog){
                [progressDialog dismiss];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect Failed", @"") message:NSLocalizedString(@"This camera connect failed,please check your device.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alert show];
        }
        
    }

}
- (void)camera:(Camera *)_camera connect_updateConnectSessionStates:(NSInteger)states
{
   
    if(_camera==myCamera)
    {

        if(states==CONNECTION_STATE_CONNECTING)
        {
            return;
        }
        
        if(states!=CONNECTION_STATE_CONNECTED)
        {
            if(progressDialog){
                [progressDialog dismiss];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect Failed", @"") message:NSLocalizedString(@"This camera connect failed,please check your device.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }

}



@end
