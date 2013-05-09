/* 
     File: DITableViewController.m
 
 
 */

#import "DITableViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "TextViewController.h"

/* UIDocumentInteractionController only suppport two actons: print & copy
http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIDocumentInteractionControllerDelegate_protocol/DeprecationAppendix/AppendixADeprecatedAPI.html#//apple_ref/occ/intfm/UIDocumentInteractionControllerDelegate/documentInteractionController:canPerformAction:
*/


@interface DITableViewController (private)
- (NSString *)applicationDocumentsDirectory;
@end


@interface DITableViewController()<UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate>
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
        self.docInteractionController.delegate = self;
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
    
    self.title = @"Files";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    self.searchBar.delegate = self;
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    if (self.documentURLs.count > 0)
//        title = @"Documents folder";
//    
//    return title;
//}

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
        
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil) {
            //[self displayMailComposerSheet];
            // We must always check whether the current device is configured for sending emails
            if ([mailClass canSendMail]) {
                [self displayMailComposerSheet:fileURL];
            }
        }
        
//        if ([iKonicMailComposeViewController canSendMail]) {
//            NSString *fileName = [[fileURL path] lastPathComponent];
//            iKonicMailComposeViewController *mailViewController = [[iKonicMailComposeViewController alloc] init];
//            [mailViewController setSubject:fileName];
//            // we should decrypt the file first, then make it as attachement
//            NSData *encryptedData = [NSData dataWithContentsOfURL:fileURL];
//            NSError *error;
//            if (![RNDecryptor decryptData:encryptedData withPassword:[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"passwordString"] error:&error]) {
//                DebugLog(@"couldn't decry the data : %@", [error description]);
//            } else {
//                NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"passwordString"] error:&error];
//                [mailViewController addAttachmentData:decryptedData fileName:fileName];
//            }
//            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
//            }
//            [self presentViewController:mailViewController animated:YES completion:nil];
//            
//        }
//        else {
//            [MBProgressHUD ];
//        }
        
//		self.docInteractionController.URL = fileURL;
//		[self.docInteractionController presentOptionsMenuFromRect:longPressGesture.view.frame
//                                                           inView:longPressGesture.view
//                                                         animated:YES];
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
    cell.textLabel.text = [[fileURL path] lastPathComponent];
    NSInteger iconCount = [docInteractionController.icons count];
    if (iconCount > 0)
    {
        cell.imageView.image = (docInteractionController.icons)[iconCount - 1];
    }
    
    static NSDateFormatter *dateFormatter = nil;
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
 
    //let's change to the downloaded date
//    cell.detailTextLabel.text = fileAttributes[NSFileModificationDate];
    
    // attach to our view any gesture recognizers that the UIDocumentInteractionController provides
    //cell.imageView.userInteractionEnabled = YES;
    
    //cell.contentView.gestureRecognizers = self.docInteractionController.gestureRecognizers;
    //
    // or
    // add a custom gesture recognizer in lieu of using the canned ones
    
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
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"]))
        {
            [self.documentURLs addObject:fileURL];
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


-(void)displayMailComposerSheet:(NSURL *)fileURL
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *fileName = [[fileURL path] lastPathComponent];
    [picker setSubject:fileName];
    NSData *myData = [NSData dataWithContentsOfURL:fileURL];
    [picker addAttachmentData:myData mimeType:@"text/html" fileName:fileName];
    
    // Fill out the email body text
    NSString *iTunesLink = @"http://itunes.apple.com/gb/app/whats-on-reading/id347859140?mt=8"; // Link to iTune App link
    NSString *emailBody = [NSString stringWithFormat:@"Text extrated from image by <a href = '%@'>EZOCR iOS app </a>!",iTunesLink];
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
//            feedbackMsg.text = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
//            feedbackMsg.text = @"Result: Mail saved";
            break;
        case MFMailComposeResultSent:
//            feedbackMsg.text = @"Result: Mail sent";
            break;
        case MFMailComposeResultFailed:
//            feedbackMsg.text = @"Result: Mail sending failed";
            break;
        default:
//            feedbackMsg.text = @"Result: Mail not sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
