//
//  ViewController.h
//  TesseractSample
//
//  Created by Ângelo Suzuki on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

namespace tesseract {
    class TessBaseAPI;
};

@interface ViewController : UIViewController
{
    MBProgressHUD *progressHud;
    
    tesseract::TessBaseAPI *tesseract;
    uint32_t *pixels;
}

@property (nonatomic, strong) MBProgressHUD *progressHud;

- (void)setTesseractImage:(UIImage *)image;

@end
