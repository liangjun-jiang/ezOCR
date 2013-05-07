//
//  KNThirdViewController.h
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNThirdViewController : UIViewController{
    NSString *result;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)dismissButtonDidTouch:(id)sender;
- (IBAction)onSaveButton:(id)sender;

@end
