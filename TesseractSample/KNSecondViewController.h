//
//  KNSecondViewController.h
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"
#import "ImageCropView.h"

@class MBProgressHUD;

namespace tesseract {
    class TessBaseAPI;
};


@class KNThirdViewController;

@interface KNSecondViewController : UIViewController <OverlayViewControllerDelegate, UIPopoverControllerDelegate>{
  KNThirdViewController * semiVC;
    
    MBProgressHUD *progressHud;
    
    tesseract::TessBaseAPI *tesseract;
    uint32_t *pixels;
}

@property (nonatomic, assign) IBOutlet UINavigationBar *navBar;
@property (nonatomic, assign) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) IBOutlet UIButton *processButton;


@property (nonatomic, strong) OverlayViewController *overlayViewController;

@property (nonatomic, strong) NSMutableArray *capturedImages;
@property (nonatomic, strong) UIPopoverController *popOverController;

// toolbar buttons
- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;

@property (nonatomic, strong) MBProgressHUD *progressHud;

- (void)setTesseractImage:(UIImage *)image;


@end
