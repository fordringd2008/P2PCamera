//
//  AddCameraController.m
//  IOTCamViewer
//
//  Created by chenchao on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"
#import "iToast.h"
#import "IOTCAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "AddCameraController.h"
#import "AddCameraDetailController.h"
#import "LANSearchDevice.h"


@implementation AddCameraController


static int bLocalSearch = 0;

- (id)init
{
    if(self=[super init])
    {
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        
        self.navigationItem.title = NSLocalizedString(@"Add device", @"");
        
        UIView *screenView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [screenView setBackgroundColor:[UIColor whiteColor]];
        self.view=screenView;
        
        [screenView release];
        
        
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, screenSize.height-50) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        [_tableView setSeparatorColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.8]];
        
        [self.view addSubview:_tableView];
        
        
        UIImageView* topImageBGView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 50)];
        [topImageBGView setBackgroundColor:[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.93]];
        [self.view addSubview:topImageBGView];
        [topImageBGView release];
        
        float   ADDCAM_BTN_STARTX=45;
        float   SCANCAM_BTN_STARTX=140;
        float   REFRESHCAM_BTN_STARTX=235;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            ADDCAM_BTN_STARTX=240;
            SCANCAM_BTN_STARTX=380;
            REFRESHCAM_BTN_STARTX=520;
        }
        addCameraButton=[[UIButton alloc] initWithFrame:CGRectMake(ADDCAM_BTN_STARTX, 5, 35, 35)];
        [addCameraButton setBackgroundImage:[UIImage imageNamed:@"addButton.png"] forState:UIControlStateNormal];
        [addCameraButton setBackgroundImage:[UIImage imageNamed:@"addButton.png"] forState:UIControlStateHighlighted];
        [addCameraButton setBackgroundImage:[UIImage imageNamed:@"addButton.png"] forState:UIControlStateSelected];
        [addCameraButton addTarget:self action:@selector(addCameraByTypingPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        scanCameraButton=[[UIButton alloc] initWithFrame:CGRectMake(SCANCAM_BTN_STARTX, 5, 35, 35)];
        [scanCameraButton setBackgroundImage:[UIImage imageNamed:@"scanQRCodeButton.png"] forState:UIControlStateNormal];
        [scanCameraButton setBackgroundImage:[UIImage imageNamed:@"scanQRCodeButton.png"] forState:UIControlStateHighlighted];
        [scanCameraButton setBackgroundImage:[UIImage imageNamed:@"scanQRCodeButton.png"] forState:UIControlStateSelected];
        [scanCameraButton addTarget:self action:@selector(addCameraByScanPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //refresh cameraButton
        UIButton* refreshButton=[[UIButton alloc] initWithFrame:CGRectMake(REFRESHCAM_BTN_STARTX, 5, 35, 35)];
        [refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton.png"] forState:UIControlStateNormal];
        [refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_selected.png"] forState:UIControlStateHighlighted];
        [refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_selected.png"] forState:UIControlStateSelected];
        [refreshButton addTarget:self action:@selector(searchCameraPressed:) forControlEvents:UIControlEventTouchUpInside];
        

        
        UIButton* backButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateHighlighted];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateSelected];
        [backButton addTarget:self action:@selector(addDeviceBackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
        
        [backButton release];
        [backBarButtonItem release];
        
        [self.view addSubview:addCameraButton];
        [self.view addSubview:scanCameraButton];
        [self.view addSubview:refreshButton];
        
        
        [addCameraButton release];
        [scanCameraButton release];
        [refreshButton release];
        

        
        device_list = [[NSMutableArray alloc] init];

        [_tableView release];
    }
    return self;
}

- (void)showListFullMesg
{    
    NSString *msg = NSLocalizedString(@"List are full, remove a device and try again", @"");
    NSString *dismiss = NSLocalizedString(@"Dismiss", @"");
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:dismiss otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)lanSearch
{
    
    if (bLocalSearch == 1) return;
    bLocalSearch = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
    
    int num = 0;
    int k = 0;
    int cnt = 0;
    
    [device_list removeAllObjects];
    
    while (num == 0 & cnt++ < 2) {
        
        LanSearch_t *pLanSearchAll =[Camera LanSearch:&num timeout:2000];
        printf("camera found(%d)\n", num);
        
        for(k = 0; k < num; k++) {
            
            printf("\tUID[%s]\n", pLanSearchAll[k].UID);
            printf("\tIP[%s]\n", pLanSearchAll[k].IP);
            printf("\tPORT[%d]\n", pLanSearchAll[k].port);
            
            
            LANSearchDevice *dev = [[LANSearchDevice alloc] init];
            dev.uid = [NSString stringWithFormat:@"%s", pLanSearchAll[k].UID];
            dev.ip = [NSString stringWithFormat:@"%s", pLanSearchAll[k].IP];
            dev.port = pLanSearchAll[k].port;
            
            [device_list addObject:dev];
            
            [dev release];
        }
        
        if(pLanSearchAll) {
            free(pLanSearchAll);
        }
    }
    
    bLocalSearch = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_tableView reloadData];
       
    });

     
}

- (void)addCameraByTypingPressed:(id)sender
{

    if ([camera_list count] >= 128) { //最大限制为128台设备.
        [self showListFullMesg];
        return;
    }
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];
    
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:YES];
    [controller setPasswordFieldBecomeFirstResponder:NO];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)addCameraByScanPressed:(id)sender
{    


    if ([camera_list count] >= 128) { //最大限制为128台设备.
        [self showListFullMesg];
        return;
    }
    
    ScanTDCodeViewController* scanTDCodeViewController=[[ScanTDCodeViewController alloc] init];
    scanTDCodeViewController.controllerDelegate=self;
    [self presentModalViewController:scanTDCodeViewController animated:YES];
    
    [scanTDCodeViewController release];
}

- (IBAction)searchCameraPressed:(id)sender 
{
    [NSThread detachNewThreadSelector:@selector(lanSearch) toTarget:self withObject:nil];
}




- (void)viewDidAppear:(BOOL)animated 
{    
    [_tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)dealloc 
{    
    [device_list release];

    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)addDeviceBackButtonSelected:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - SCanTDCodeController Delegate Methods
- (void)OnScanTDCodeGetResult:(NSString *)scanResult
{            
    [self dismissViewControllerAnimated:NO completion:nil];
       
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];   
    
    controller.uid = scanResult;
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)onScanTDCodeControllerBack
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LANSearch Delegate Methods
- (void)lanSearchController:(LANSearchController *)controller_ 
            didSearchResult:(NSString *)uid_ 
                         ip:(NSString *)ip_ 
                       port:(NSInteger)port_ 
{
    [controller_.navigationController popViewControllerAnimated:NO];    
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];    
    controller.uid = uid_;
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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

#pragma mark - AddCameraDelegate Methods
- (void)camera:(NSString *)uid_ didAddwithName:(NSString *)name_ password:(NSString *)password_
{

    Camera *camera = [[Camera alloc] initWithUID:uid_ camName:name_ viewAccount:@"admin" viewPassword:password_];
    
    [camera connect];        
      
    

    [camera_list addObject:camera];
    [camera release];
    
    NSLog(@"Add Cam %d",appAccessModeGlobal);
    // 添加设备到本地数据库.
    if(appAccessModeGlobal==APPLICATIONACCESSMODE_LOCAL)
    {
        if (database != NULL) {
            [database executeUpdate:@"INSERT INTO device(dev_uid, dev_nickname, dev_name, dev_pwd, view_acc, view_pwd) VALUES(?,?,?,?,?,?)",
             camera.uid, name_, name_, password_, @"admin", password_];
        }
    }
    
    //更新窗口消息.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"msgAddCameraAndrefreshWindow" object:nil];
    
    [[iToast makeText:NSLocalizedString(@"Add camera success", @"")] showFromView:self.view];
    
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if ([camera_list count] >= 128) { //最大限制为128台设备.
        [self showListFullMesg];
        return;
    }
    
    NSInteger row = [indexPath row];
    
    LANSearchDevice *dev = [device_list objectAtIndex:row];
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];    
    
    controller.uid = dev.uid;
    controller.hidesBottomBarWhenPushed = YES;  
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (!bLocalSearch && (device_list == nil || [device_list count] <= 0)) ? 0 : [device_list count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CameraListCell = @"CameraListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CameraListCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCell] autorelease];        
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    LANSearchDevice *dev = [device_list objectAtIndex:row];
    BOOL isDeviceExist = NO;
    
    for (Camera *camera in camera_list) {
        if ([camera.uid isEqualToString:dev.uid]) {
            isDeviceExist = YES;
            break;
        }
    }
    
    cell.textLabel.text = dev.uid;
    cell.textLabel.textColor = isDeviceExist ? [UIColor grayColor] : [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = dev.ip;
    cell.detailTextLabel.textColor = isDeviceExist ? [UIColor grayColor] : [UIColor blackColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    
    UIImageView* bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]];
    cell.backgroundView = bgView;
    [bgView release];
    
    return cell;
}

@end
