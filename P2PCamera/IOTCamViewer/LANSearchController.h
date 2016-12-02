#import <UIKit/UIKit.h>

@protocol LANSearchDelegate;

@interface LANSearchController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    id<LANSearchDelegate> delegate;
    UITableView *tableView;
    
    NSMutableArray *searchResult;
}

@property (nonatomic, retain) id<LANSearchDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<LANSearchDelegate>)delegate;
- (IBAction)refresh:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)search;

@end

@protocol LANSearchDelegate

- (void) lanSearchController:(LANSearchController *)controller
             didSearchResult:(NSString *)uid
                          ip:(NSString *)ip
                        port:(NSInteger)port;

@end