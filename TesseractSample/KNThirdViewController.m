//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNThirdViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface KNThirdViewController ()

@end

@implementation KNThirdViewController
@synthesize textView;
@synthesize retryButton;
@synthesize saveButton;
@synthesize result,image;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  saveButton.layer.cornerRadius  = 10.0f;
  saveButton.layer.masksToBounds = YES;
  retryButton.layer.cornerRadius   = 10.0f;
  retryButton.layer.masksToBounds  = YES;
    
    textView.text = result;
}

- (void)viewDidUnload {
  [self setTextView:nil];
  [self setSaveButton:nil];
  [self setRetryButton:nil];
  [super viewDidUnload];
}

- (IBAction)dismissButtonDidTouch:(id)sender {

  // Here's how to call dismiss button on the parent ViewController
  // be careful with view hierarchy
    self.textView.text = @"";
  UIViewController * parent = [self.view containingViewController];
  if ([parent respondsToSelector:@selector(dismissSemiModalView)]) {
    [parent dismissSemiModalView];
  }

}

//- (IBAction)resizeSemiModalView:(id)sender {
//  UIViewController * parent = [self.view containingViewController];
//  if ([parent respondsToSelector:@selector(resizeSemiView:)]) {
//    [parent resizeSemiView:CGSizeMake(320, arc4random() % 280 + 180)];
//  }
//}

- (IBAction)onSaveButton:(id)sender {
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:@"MMddyyyyhhmmss"];
    NSString *fileName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSError *error;
    AppDelegate *delegate = [AppDelegate appDelegate];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",[delegate filesDirectoryPath],fileName];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.png",[delegate filesDirectoryPath],fileName];
//    NSLog(@"string to write:%@",printString);
    // Write to the file
    [result writeToFile:filePath atomically:YES
                    encoding:NSUTF8StringEncoding error:&error];
    
    NSData *pngData = UIImagePNGRepresentation(image);
    [pngData writeToFile:imagePath atomically:YES];
    
    
    if (error == nil) {
        [self dismissButtonDidTouch:nil];
    }
    
    
}

@end
