/*
     File: TextViewController.m 
 Abstract: The view controller for hosting the UITextView features of this sample. 
  Version: 2.10 
  
 
  
 */

#import "TextViewController.h"


@implementation TextViewController

@synthesize textView, fileURL;

-(id)initWithFileURL:(NSURL *)fileUrl
{
    
//    self = [super initWithNibName:@"TextViewController" bundle:nil];
    self =  [super init];
    if (self) {
        self.fileURL = fileUrl;
    }
    
    return self;
}

- (void)setupTextView
{
	self.textView = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.textView.textColor = [UIColor blackColor];
	self.textView.font = [UIFont fontWithName:@"Arial" size:18.0];
	self.textView.delegate = self;
	self.textView.backgroundColor = [UIColor whiteColor];
	
    NSData *data = [NSData dataWithContentsOfURL:self.fileURL];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  	self.textView.text = text;
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	self.textView.scrollEnabled = YES;
	
	// this will cause automatic vertical resize when the table is resized
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
//	[self.view addSubview: self.textView];
}

- (void)loadView
{
    
    [self setupTextView];
    self.view = self.textView;
    
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = [[self.fileURL path] lastPathComponent];
//	[self setupTextView];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.textView = nil;
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{
	// the keyboard is showing so resize the table's height
	CGRect keyboardRect = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
	CGRect keyboardRect = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)saveAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
	//
	[self.textView resignFirstResponder];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayMailComposerSheet)];
 	self.navigationItem.rightBarButtonItem = shareItem;	// this will remove the "save" button
    
    NSError *error;
    [self.textView.text writeToURL:self.fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
//    if (error == nil) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
															target:self
															action:@selector(saveAction:)];
	self.navigationItem.rightBarButtonItem = saveItem;
}

-(void)displayMailComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
//    NSString *fileName = [[fileURL path] lastPathComponent];
//    [picker setSubject:fileName];
//    NSData *myData = [NSData dataWithContentsOfURL:fileURL];
//    [picker addAttachmentData:myData mimeType:@"text/html" fileName:fileName];
    
    NSString *body = self.textView.text;
    // Fill out the email body text
    NSString *iTunesLink = @"http://itunes.apple.com/gb/app/whats-on-reading/id347859140?mt=8"; // Link to iTune App link
    NSString *signature = [NSString stringWithFormat:@"Text extrated from image by <a href = '%@'>EZOCR iOS app </a>!",iTunesLink];
    [picker setMessageBody:[NSString stringWithFormat:@"%@ </br>-------</br>%@",body,signature] isHTML:YES];
    [self presentViewController:picker animated:YES completion:nil];
//    [self presentModalViewController:picker animated:YES];
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
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
}

@end

