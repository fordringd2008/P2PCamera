//
//  AddCameraDetailController.m
//  IOTCamViewer
//
//  Created by chenchao on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddCameraDetailController.h"

@implementation AddCameraDetailController

@synthesize fieldLabels;
@synthesize textFieldName, textFieldUID, textFieldPassword;
@synthesize uid;
@synthesize tableView;
@synthesize delegate;

- (void)viewDidLoad
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
    
    /*
     textFieldName.frame = CGRectMake(115, 9, 180, 25);
     textFieldName.placeholder = NSLocalizedString(@"Camera Name", @"");
     [textFieldName addTarget:self action:@selector(textFieldDone:)
     forControlEvents:UIControlEventEditingDidEndOnExit];
     
     textFieldUID.frame = CGRectMake(115, 9, 180, 25);
     textFieldUID.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
     textFieldUID.placeholder = NSLocalizedString(@"Camera UID", @"");
     [textFieldUID addTarget:self action:@selector(textFieldDone:)
     forControlEvents:UIControlEventEditingDidEndOnExit];
     
     textFieldPassword.frame = CGRectMake(115, 9, 180, 25);
     textFieldPassword.placeholder = NSLocalizedString(@"Camera Password", @"");
     textFieldPassword.secureTextEntry = YES;
     [textFieldPassword addTarget:self action:@selector(textFieldDone:)
     forControlEvents:UIControlEventEditingDidEndOnExit];
     */
    
    [super viewDidLoad];
}

#pragma mark - View lifecycle

- (void)dealloc {
    
    self.delegate = nil;
    
    [self.tableView release];
    [self.fieldLabels release];
    [self.textFieldName release];
    [self.textFieldUID release];
    [self.textFieldPassword release];
    [super dealloc];
}

- (void)viewDidUnload {
    
    self.tableView = nil;
    self.fieldLabels = nil;
    self.textFieldName = nil;
    self.textFieldUID = nil;
    self.textFieldPassword = nil;
    [super viewDidUnload];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<AddCameraDelegate>)delegate_ {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        [self setDelegate:delegate_];
    }
    
    return self;
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAddCameraInfo:(id)sender {
    
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
        
        [self.delegate camera:uid_ didAddwithName:name password:password];
        [self.navigationController popViewControllerAnimated:YES];

    
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"The name, uid and password field can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)textFieldDone:(id)sender 
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

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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


@end
