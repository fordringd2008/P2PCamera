//
//  APSearchCamViewController.m
//  P2PCamera
//
//  Created by CHENCHAO on 14-6-19.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "APSearchCamViewController.h"

#import "Camera.h"
#import "LANSearchDevice.h"
#import "IOTCAPIs.h"
#import "AVIOCTRLDEFs.h"

static int bLocalSearch = 0;



@implementation APSearchCamViewController

- (id)initWithStyle:(UITableViewStyle)style
{

    if (self = [super initWithStyle:style])
    {
        
        self.navigationItem.title = NSLocalizedString(@"Add device", @"");
        
        UIButton* backButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateHighlighted];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateSelected];
        [backButton addTarget:self action:@selector(addDeviceBackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
        
        [backButton release];
        [backBarButtonItem release];
        
         progressDialog=[[UIProgressDialog alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [progressDialog setProgressShowString:NSLocalizedString(@"Searching local device...",@"")];
        
         device_list = [[NSMutableArray alloc] init];
        
        [self startLanSearching];
        

    }
    return self;
}
- (void)dealloc
{
    [device_list release];
    [super dealloc];
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
        [self.tableView reloadData];
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
        
        [self.tableView reloadData];
        [progressDialog dismiss];
        
    });
    
    
}
- (void)startLanSearching
{
    [progressDialog show];
    
    [NSThread detachNewThreadSelector:@selector(lanSearch) toTarget:self withObject:nil];
}



- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)addDeviceBackButtonSelected:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ([camera_list count] >= 128) { //最大限制为128台设备.
        [self showListFullMesg];
        return;
    }
    
    NSInteger row = [indexPath row];
    
    LANSearchDevice *dev = [device_list objectAtIndex:row];
    
    APAddCamDetailViewController *controller = [[APAddCamDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.uid = dev.uid;
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

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
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    
    UIImageView* bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]];
    cell.backgroundView = bgView;
    [bgView release];
    
    return cell;
}






@end
