//
//  LANSearchController.m
//  IOTCamViewer
//
//  Created by chenchao on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IOTCAPIs.h"
#import "Camera.h"
#import "LANSearchController.h"
#import "LANSearchDevice.h"

@class LANSearchDevice;

@implementation LANSearchController

@synthesize tableView;
@synthesize delegate;

- (void)search {
    
    int num, k;
    
    [searchResult removeAllObjects];
    
    
    LanSearch_t *pLanSearchAll = [Camera LanSearch:&num timeout:2000];
	printf("num[%d]\n", num);
    
	for(k = 0; k < num; k++) {
        
        
		printf("UID[%s]\n", pLanSearchAll[k].UID);
		printf("IP[%s]\n", pLanSearchAll[k].IP);
		printf("PORT[%d]\n", pLanSearchAll[k].port);
        
        LANSearchDevice *dev = [[LANSearchDevice alloc] init];
        dev.uid = [NSString stringWithFormat:@"%s", pLanSearchAll[k].UID];
        dev.ip = [NSString stringWithFormat:@"%s", pLanSearchAll[k].IP];
        dev.port = pLanSearchAll[k].port;
        
        [searchResult addObject:dev];
        
        [dev release];
	}
    
	if(pLanSearchAll != NULL) {
		free(pLanSearchAll);
	}
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<LANSearchDelegate>)delegate_ {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        [self setDelegate:delegate_];
    }
    
    return self;
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refresh:(id)sender {
    
    [self search];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    self.navigationItem.title = @"LAN Search";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    
    searchResult = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    searchResult = nil;
    tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self search];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    [tableView release];
    [searchResult release];
    [super dealloc];
}

#pragma mark - Table DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    //return 1;
    return [searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CameraListCell = @"CameraListCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCell] autorelease];
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    LANSearchDevice *dev = [searchResult objectAtIndex:row];
    
    cell.textLabel.text = dev.uid;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = dev.ip;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]];
    
    return cell;
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    LANSearchDevice *dev = [searchResult objectAtIndex:row];
    [self.delegate lanSearchController:self didSearchResult:dev.uid ip:dev.ip port:dev.port];
}

@end
