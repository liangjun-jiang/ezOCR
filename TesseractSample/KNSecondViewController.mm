//
//  KNSecondViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNSecondViewController.h"
#import "KNThirdViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#include "baseapi.h"
#include "environ.h"
#import "pix.h"

//http://www.catamount.com/forums/viewtopic.php?f=21&t=967

//@interface UIImage (CS_Extensions)
//- (UIImage *)imageAtRect:(CGRect)rect;
//- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
//- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
//- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
//- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
//- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
//
//@end;
//
////
////  UIImage-Extensions.m
////
////  Created by Hardy Macia on 7/1/09.
////  Copyright 2009 Catamount Software. All rights reserved.
////
//
//
//CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
//
//@implementation UIImage (CS_Extensions)
//
//-(UIImage *)imageAtRect:(CGRect)rect
//{
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
//    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
//    CGImageRelease(imageRef);
//    
//    return subImage;
//    
//}
//
//- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
//    
//    UIImage *sourceImage = self;
//    UIImage *newImage = nil;
//    
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//    
//    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
//        
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        
//        if (widthFactor > heightFactor)
//            scaleFactor = widthFactor;
//        else
//            scaleFactor = heightFactor;
//        
//        scaledWidth  = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        
//        // center the image
//        
//        if (widthFactor > heightFactor) {
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        } else if (widthFactor < heightFactor) {
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//    
//    
//    // this is actually the interesting part:
//    
//    UIGraphicsBeginImageContext(targetSize);
//    
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width  = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    
//    [sourceImage drawInRect:thumbnailRect];
//    
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    if(newImage == nil) NSLog(@"could not scale image");
//    
//    
//    return newImage ;
//}
//
//
//- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
//    
//    UIImage *sourceImage = self;
//    UIImage *newImage = nil;
//    
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//    
//    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
//        
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        
//        if (widthFactor < heightFactor)
//            scaleFactor = widthFactor;
//        else
//            scaleFactor = heightFactor;
//        
//        scaledWidth  = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        
//        // center the image
//        
//        if (widthFactor < heightFactor) {
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        } else if (widthFactor > heightFactor) {
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//    
//    
//    // this is actually the interesting part:
//    
//    UIGraphicsBeginImageContext(targetSize);
//    
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width  = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    
//    [sourceImage drawInRect:thumbnailRect];
//    
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    if(newImage == nil) NSLog(@"could not scale image");
//    
//    
//    return newImage ;
//}
//
//
//- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
//    
//    UIImage *sourceImage = self;
//    UIImage *newImage = nil;
//    
//    //   CGSize imageSize = sourceImage.size;
//    //   CGFloat width = imageSize.width;
//    //   CGFloat height = imageSize.height;
//    
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    
//    //   CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//    
//    // this is actually the interesting part:
//    
//    UIGraphicsBeginImageContext(targetSize);
//    
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width  = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    
//    [sourceImage drawInRect:thumbnailRect];
//    
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    if(newImage == nil) NSLog(@"could not scale image");
//    
//    
//    return newImage ;
//}
//
//
//- (UIImage *)imageRotatedByRadians:(CGFloat)radians
//{
//    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
//}
//
//- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
//{
//    // calculate the size of the rotated view's containing box for our drawing space
//    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
//    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
//    rotatedViewBox.transform = t;
//    CGSize rotatedSize = rotatedViewBox.frame.size;
//    
//    // Create the bitmap context
//    UIGraphicsBeginImageContext(rotatedSize);
//    CGContextRef bitmap = UIGraphicsGetCurrentContext();
//    
//    // Move the origin to the middle of the image so we will rotate and scale around the center.
//    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
//    
//    //   // Rotate the image context
//    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
//    
//    // Now, draw the rotated/scaled image into the context
//    CGContextScaleCTM(bitmap, 1.0, -1.0);
//    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//    
//}
//
//@end;

@interface UIImage(grayScaleImage)

@end

@implementation UIImage(grayScaleImage)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

- (UIImage *)convertToGrayscale {
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}


@end
@implementation KNSecondViewController
@synthesize navBar, imageView, overlayViewController, capturedImages;
@synthesize progressHud;
@synthesize processButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // but is copied to the Documents directory on the first run.
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
        
        NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // If the expected store doesn't exist, copy the default store.
        if (![fileManager fileExistsAtPath:dataPath]) {
            // get the path to the app bundle (with the tessdata dir)
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
            if (tessdataPath) {
                [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
            }
        }
        
        setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
        
        // init the tesseract engine.
        tesseract = new tesseract::TessBaseAPI();
        tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng");
      
        
      // You can optionally listen to notifications
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(semiModalPresented:)
                                                   name:kSemiModalDidShowNotification
                                                 object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(semiModalDismissed:)
                                                   name:kSemiModalDidHideNotification
                                                 object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(semiModalResized:)
                                                   name:kSemiModalWasResizedNotification
                                                 object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    self.tabBarItem.image = [UIImage imageNamed:@"second"];
    self.tabBarItem.title = @"OCR";
    
    // Take note that you need to take ownership of the ViewController that is being presented
    semiVC = [[KNThirdViewController alloc] initWithNibName:@"KNThirdViewController" bundle:nil];

    
    self.overlayViewController =
    [[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil];
    
    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.overlayViewController.delegate = self;
    self.capturedImages = [NSMutableArray array];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // camera is not on this device, don't show the camera button
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.processButton.enabled = NO;
    self.processButton.hidden = YES;
    self.processButton.layer.cornerRadius  = 10.0f;
    self.processButton.layer.masksToBounds = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if (![self.progressHud isHidden])
        [self.progressHud hide:NO];
    self.progressHud = nil;
}



- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if (self.capturedImages.count > 0)
        [self.capturedImages removeAllObjects];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.overlayViewController.imagePickerController animated:YES];
    }
}

- (IBAction)photoLibraryAction:(id)sender
{
	[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [self.capturedImages addObject:picture];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // we took a single shot
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
            processButton.enabled = YES;
            processButton.hidden = NO;
        }
        else
        {
            // we took multiple shots, use the list of images for animation
            self.imageView.animationImages = self.capturedImages;
            
            if (self.capturedImages.count > 0)
                // we are done with the image list until next time
                [self.capturedImages removeAllObjects];
            
            self.imageView.animationDuration = 5.0;    // show each captured photo for 5 seconds
            self.imageView.animationRepeatCount = 0;   // animate forever (show all photos)
            [self.imageView startAnimating];
        }
    
        
    }
}

- (IBAction)onProcessing:(id)sender
{
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.labelText = @"Processing OCR";
    
    
    [self.view addSubview:self.progressHud];
//     imageView.image = [self imageFromcroppedArea:imageView.cropAreaInImage];
//    UIImage *image = [self.imageView.image imageAtRect:imageView.cropAreaInImage];
//    [self.progressHud showWhileExecuting:@selector(processOcrAt:) onTarget:self withObject:[self imageFromcroppedArea:imageView.cropAreaInImage] animated:YES];
     [self.progressHud showWhileExecuting:@selector(processOcrAt:) onTarget:self withObject:self.imageView.image animated:YES];
//    self.imageView.image = image;
}

#pragma mark - Optional notifications

- (void) semiModalResized:(NSNotification *) notification {
  if(notification.object == self){
//    NSLog(@"The view controller presented was been resized");
//      semiVC.textView.text = resu
  }
}

- (void)semiModalPresented:(NSNotification *) notification {
  if (notification.object == self) {
//    NSLog(@"This view controller just shown a view with semi modal annimation");
  }
}
- (void)semiModalDismissed:(NSNotification *) notification {
  if (notification.object == self) {
//    NSLog(@"A view controller was dismissed with semi modal annimation");
      semiVC.textView.text = @"";
      
  }
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    delete tesseract;
    tesseract = nil;
}

- (void)processOcrAt:(UIImage *)image
{
    // convert to gray to make OCR better
    [self setTesseractImage:[image convertToGrayscale]];
    
    tesseract->Recognize(NULL);
    char* utf8Text = tesseract->GetUTF8Text();
    
    [self performSelectorOnMainThread:@selector(ocrProcessingFinished:)
                           withObject:[NSString stringWithUTF8String:utf8Text]
                        waitUntilDone:NO];
}

- (void)ocrProcessingFinished:(NSString *)result
{
    [self.progressHud hide:YES];
//    [[[UIAlertView alloc] initWithTitle:@"Result"
//                                message:[NSString stringWithFormat:@"Recognized:\n%@", result]
//                               delegate:nil
//                      cancelButtonTitle:nil
//                      otherButtonTitles:@"OK", nil] show];
    semiVC.result = result;
    
    [self presentSemiViewController:semiVC withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(YES),
     KNSemiModalOptionKeys.animationDuration : @(2.0),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
	 }];
}

- (void)setTesseractImage:(UIImage *)image
{
    free(pixels);
    
    CGSize size = [image size];
    int width = size.width;
    int height = size.height;
	
	if (width <= 0 || height <= 0)
		return;
	
    // the pixels will be painted to this array
    pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
	
	// we're done with the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    tesseract->SetImage((const unsigned char *) pixels, width, height, sizeof(uint32_t), width * sizeof(uint32_t));
}

// conver to grayscale
// http://iosdevelopertips.com/graphics/convert-an-image-uiimage-to-grayscale.html
//- (UIImage *)convertImageToGrayScale:(UIImage *)image
//{
//    // Create image rectangle with current image width/height
//    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
//    
//    // Grayscale color space
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    
//    // Create bitmap content with current image size and grayscale colorspace
//    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
//    
//    // Draw image into current context, with specified rectangle
//    // using previously defined context (with grayscale colorspace)
//    CGContextDrawImage(context, imageRect, [image CGImage]);
//    
//    // Create bitmap image info from pixel data in current context
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    
//    // Create a new UIImage object
//    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
//    
//    // Release colorspace, context and bitmap information
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    CFRelease(imageRef);
//    
//    // Return the new grayscale image
//    return newImage;
//}
//
//
//// this does the trick to have tesseract accept the UIImage.
//// http://stackoverflow.com/questions/13511102/ios-tesseract-ocr-image-preperation
//- (UIImage *)gs_convert_image:(UIImage *)src_img
//{
//    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
//    /*
//     * Note we specify 4 bytes per pixel here even though we ignore the
//     * alpha value; you can't specify 3 bytes per-pixel.
//     */
//    size_t d_bytesPerRow = src_img.size.width * 4;
//    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
//    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
//                                                  src_img.size.height,
//                                                  8, d_bytesPerRow,
//                                                  d_colorSpace,
//                                                  kCGImageAlphaNoneSkipFirst);
//    
//    UIGraphicsPushContext(context);
//    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
//    CGContextTranslateCTM(context, 0.0, src_img.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    // Use UIImage's drawInRect: instead of the CGContextDrawImage function, otherwise you'll have issues when the source image is in portrait orientation.
//    [src_img drawInRect:CGRectMake(0.0, 0.0, src_img.size.width, src_img.size.height)];
//    UIGraphicsPopContext();
//    
//    /*
//     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
//     * we can perform whatever image processing here.
//     */
//    
//    
//    // After we've processed the raw data, turn it back into a UIImage instance.
//    CGImageRef new_img = CGBitmapContextCreateImage(context);
//    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
//                                new_img];
//    
//    CGImageRelease(new_img);
//    CGContextRelease(context);
//    CGColorSpaceRelease(d_colorSpace);
//    free(imgData);
//    return convertedImage;
//}

//- (UIImage *)imageFromcroppedArea:(CGRect)bounds {
//    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imageView.image CGImage], bounds);
//    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    return croppedImage;
//}
//
//#define radians(degrees) (degrees * M_PI/180)
//-(UIImage*)rotateImage:(UIImage*)image
//{
//    
//    UIGraphicsBeginImageContext(image.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, CGRectMake(0 , 0, image.size.width , image.size.height), [image CGImage]);
//    
//    
//    CGContextRotateCTM (context, radians(90));
//    
//    CGImageRef cgImage = nil;
//    
//    cgImage = CGBitmapContextCreateImage(context);
//    
//    UIImage *img = [UIImage imageWithCGImage:cgImage];
//    
//    
//    return img;
//    
//}
@end
