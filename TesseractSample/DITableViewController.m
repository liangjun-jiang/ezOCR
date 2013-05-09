/* 
     File: DITableViewController.m
 
 
 */

#import "DITableViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#import "TextViewController.h"
#import "PhotoViewController.h"

/* UIDocumentInteractionController only suppport two actons: print & copy
http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIDocumentInteractionControllerDelegate_protocol/DeprecationAppendix/AppendixADeprecatedAPI.html#//apple_ref/occ/intfm/UIDocumentInteractionControllerDelegate/documentInteractionController:canPerformAction:
*/


@interface DITableViewController (private)
- (NSString *)applicationDocumentsDirectory;
@end


@interface DITableViewController()<UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray	*filteredListContent;
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
}

@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;
@end

#define kRowHeight 58.0f

//NSString* PluralizeTimeUnits(NSString *unit, int n)
//{
//    NSString *futureFormat = NSLocalizedString(@"RelativeDateFutureFormat", @"in %i %@");
//    NSString *pastFormat = NSLocalizedString(@"RelativeDatePastFormat", @"%i %@ ago");
//    
//    NSString *format = ((n < 0) ? futureFormat : pastFormat);
//    int count = ABS(n);
//    
//    // construct a key for the localized time unit, like SingularHour, or PluralMinute, etc.
//    NSString *unitKey = [NSString stringWithFormat:@"%@%@", (count == 1) ? @"Singular" : @"Plural", unit];
//    NSString *unitText = NSLocalizedString(unitKey, nil);
//    return [NSString stringWithFormat:format, count, unitText];
//}
//
//#define MAX_HOURS 6
//
//NSString* RelativeDateString(NSDate *date)
//{
//    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
//    NSInteger flags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit;
//    NSDateComponents *components = [cal components:flags fromDate:date toDate:[NSDate date] options:0];
//    
//    if (MAX_HOURS < components.hour) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.timeStyle = NSDateFormatterShortStyle;
//        return [[formatter stringFromDate:date] uppercaseString];
//    } else if (components.hour) {
//        return PluralizeTimeUnits(@"Hour", components.hour);
//    } else if (components.minute) {
//        return PluralizeTimeUnits(@"Minute", components.minute);
//    } else {
//        return PluralizeTimeUnits(@"Second", components.second);
//    }
//}


@implementation DITableViewController

@synthesize docWatcher, documentURLs, docInteractionController;
@synthesize filteredListContent, savedSearchTerm, searchDisplayController, searchBar, savedScopeButtonIndex, searchWasActive;


#pragma mark -
#pragma mark View Controller

//NSDate *DayFromDate(NSDate *date)
//{
//    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
//    NSDate *day;
//    [cal rangeOfUnit:NSDayCalendarUnit startDate:&day interval:NULL forDate:date];
//    return day;
//}



- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
//        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"History";
    
//    self.tabBarItem.image = [UIImage imageNamed:@"first"];
//    self.tabBarItem.title = @"History";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor blackColor];
//    self.searchBar.scopeButtonTitles = @[@"File Name", @"File Type"]; 
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchDisplayController = [[UISearchDisplayController alloc]
                                    initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    // start monitoring the document directory…
    self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    
    self.documentURLs = [NSMutableArray array];
    
    // scan for existing documents
    [self directoryDidChange:self.docWatcher];
    
    // create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray array];

}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
}

- (void)viewDidUnload
{
    self.documentURLs = nil;
    self.docWatcher = nil;
    
    self.filteredListContent = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.filteredListContent count];
    }
    else
    {
        return self.documentURLs.count;
    }
    

}

- (NSString *)formattedFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
    if (size == 0) 
		formattedStr = @"Empty";
	else 
		if (size > 0 && size < 1024) 
			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        else 
            if (size >= 1024 && size < pow(1024, 2)) 
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            else 
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                else 
                    if (size >= pow(1024, 3)) 
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
	
	return formattedStr;
}

// if we installed a custom UIGestureRecognizer (i.e. long-hold), then this would be called
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForRowAtPoint:[longPressGesture locationInView:self.tableView]];
		 
		NSURL *fileURL = (self.documentURLs)[cellIndexPath.row];
        
        NSString *imagePath = [[fileURL path] stringByReplacingOccurrencesOfString:@".txt" withString:@".png"];
        NSData *pngData = [NSData dataWithContentsOfFile:imagePath];
        PhotoViewController  *photoViewController = [[PhotoViewController alloc] init];
        photoViewController.hidesBottomBarWhenPushed = YES;
        photoViewController.image = [UIImage imageWithData:pngData];
        [self.navigationController pushViewController:photoViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSURL *fileURL;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        fileURL = self.filteredListContent[indexPath.row];
    }
    else
    {
        fileURL = (self.documentURLs)[indexPath.row];

    }
    
    [self setupDocumentControllerWithURL:fileURL];
	
    // layout the cell
    NSString *fileName = [[fileURL path] lastPathComponent];
    cell.textLabel.text = fileName;
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    NSError *error;
    NSString *fileURLString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:&error];
    NSInteger fileSize = [fileAttributes[NSFileSize] intValue];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[dateFormatter stringFromDate:fileAttributes[NSFileModificationDate]],
                                 [self formattedFileSize:fileSize]];//, docInteractionController.UTI];
    cell.detailTextLabel.numberOfLines = 2;
    
    NSString *imagePath = [fileURLString stringByReplacingOccurrencesOfString:@".txt" withString:@".png"];
    static NSData *pngData;
    if (pngData == nil) {
        pngData = [NSData dataWithContentsOfFile:imagePath];
    }
    cell.imageView.image = [UIImage imageWithData:pngData scale:0.2];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell.imageView addGestureRecognizer:longPressGesture];
    cell.imageView.userInteractionEnabled = YES;    // this is by default NO, so we need to turn it on

    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

// tableview cell editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //todo: remove the item from the document directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL success = [fileManager removeItemAtURL:self.documentURLs[indexPath.row] error:&error];
        if (success) {
            [self.documentURLs removeObjectAtIndex:indexPath.row];
            [tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        } else {
//            DebugLog(@"something wrong ");
        }
        
       
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSURL *fileURL= [self.documentURLs objectAtIndex:indexPath.row];
    TextViewController *textViewController = [[TextViewController alloc] initWithFileURL:fileURL];
    textViewController.hidesBottomBarWhenPushed = YES;
    [[self navigationController] pushViewController:textViewController animated:YES];
    

    
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


#pragma mark -
#pragma mark QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 0;
    numToPreview = ([self.searchDisplayController isActive])?self.filteredListContent.count:self.documentURLs.count;
    
    return numToPreview;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
    // we delete the tmp directory
//    NSString *tempPath = NSTemporaryDirectory();
//    NSError *error;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:tempPath error:&error];
//    
//    // since we only support 4 type files. We need to do a better job here
//    NSArray *extensions = @[@"pdf",@"PDF",@"jpg",@"png",@"docx",@"xlsx",@"pptx",@"doc",@"xls",@"ppt"];
//    NSArray *files = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@",extensions]];
//    if (!error && [files count] > 0) {
//        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSError *removeError;
//            DebugLog(@"file obj: %@",obj);
//            NSString *filePath = [NSString stringWithFormat:@"%@%@", tempPath, obj];
//            [fileManager removeItemAtPath:filePath error:&removeError];
//            if (error) {
//                DebugLog(@"remove file error: %@",[error description]);
//            }
//        }];
//    } else {
//        DebugLog(@"locate file error: %@",[error description]);
//    }
    // we don't do anything!
    
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return ([self.searchDisplayController isActive])?self.filteredListContent[idx]:self.documentURLs[idx];
}


#pragma mark -
#pragma mark File system support

- (NSString *)applicationDocumentsDirectory
{
    AppDelegate *delegate = [AppDelegate appDelegate];
	return [delegate filesDirectoryPath];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
	{
        if( [curFileName rangeOfString:@".txt"].location != NSNotFound){
        
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"]))
        {
            [self.documentURLs addObject:fileURL];
        }
    }
        __block NSFileManager *fileManager = [NSFileManager defaultManager];
        [self.documentURLs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSError *error;
             NSDictionary *fileAttributes1 = [fileManager attributesOfItemAtPath:[obj1 path] error:&error];
            NSDictionary *fileAttributes2 = [fileManager attributesOfItemAtPath:[obj2 path] error:&error];
            return [fileAttributes1[NSFileModificationDate] compare:fileAttributes2[NSFileModificationDate]];
        }];
	}
	
	[self.tableView reloadData];
}

#pragma mark - search delegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*
     Update the filtered array based on the search text and scope.
     */
    
    [self.filteredListContent removeAllObjects]; // First clear the filtered array.
    
    /*
     Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    
    for (NSURL *fileUrl in self.documentURLs)
    {
        NSString *fileName = [fileUrl lastPathComponent];
        
        NSRange range = [fileName rangeOfString:searchText options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        if (range.location != NSNotFound) {
            [self.filteredListContent addObject:fileUrl];
        }
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



@end
