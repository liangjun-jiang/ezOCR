/* 
     File: DITableViewController.h
 Abstract: The table view that display docs of different types.
  Version: 1.4
 
  
 */

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <QuartzCore/QuartzCore.h>
#import "DirectoryWatcher.h"

@interface DITableViewController : UITableViewController <QLPreviewControllerDataSource,
                                                          QLPreviewControllerDelegate,
                                                          DirectoryWatcherDelegate>
//,
//                                                          UIDocumentInteractionControllerDelegate
//                                                          >
{
    DirectoryWatcher *docWatcher;
    NSMutableArray *documentURLs;
    UIDocumentInteractionController *docInteractionController;
}

@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, strong) NSMutableArray *documentURLs;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@end
