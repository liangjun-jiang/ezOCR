/*
     File: OverlayViewController.m 
 Abstract: The secondary view controller managing the overlap view to the camera.
  
  Version: 1.2 
  
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "OverlayViewController.h"

enum
{
	kOneShot,       // user wants to take a delayed single shot
	kRepeatingShot  // user wants to take repeating shots
};

@interface OverlayViewController ( )

@property (assign) SystemSoundID tickSound;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *timedButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
 
@property (nonatomic, strong) NSTimer *tickTimer;
@property (nonatomic, strong) NSTimer *cameraTimer;

// camera page (overlay view)
- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)timedTakePhoto:(id)sender;

@end

@implementation OverlayViewController

@synthesize delegate;

#pragma mark -
#pragma mark OverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:
                                                    [[NSBundle mainBundle] pathForResource:@"tick"
                                                                                    ofType:@"aiff"]],
                                                    &_tickSound);

        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
    }
    return self;
}

- (void)viewDidUnload
{
    self.takePictureButton = nil;
    self.startStopButton = nil;
    self.timedButton = nil;
    self.cancelButton = nil;
    
    self.cameraTimer = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{	
    
    AudioServicesDisposeSystemSoundID(_tickSound);

    
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // user wants to use the camera interface
        //
        self.imagePickerController.showsCameraControls = NO;
        
        if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0)
        {
            // setup our custom overlay view for the camera
            //
            // ensure that our custom view's frame fits within the parent frame
            CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
            CGRect newFrame = CGRectMake(0.0,
                                         CGRectGetHeight(overlayViewFrame) -
                                         self.view.frame.size.height - 10.0,
                                         CGRectGetWidth(overlayViewFrame),
                                         self.view.frame.size.height + 10.0);
            self.view.frame = newFrame;
            [self.imagePickerController.cameraOverlayView addSubview:self.view];
        }
    }
}

// called when the parent application receives a memory warning
- (void)didReceiveMemoryWarning
{
    // we have been warned that memory is getting low, stop all timers
    //
    [super didReceiveMemoryWarning];
    
    // stop all timers
    [self.cameraTimer invalidate];
    _cameraTimer = nil;
    
    [self.tickTimer invalidate];
    _tickTimer = nil;
}

// update the UI after an image has been chosen or picture taken
//
- (void)finishAndUpdate
{
    [self.delegate didFinishWithCamera];  // tell our delegate we are done with the camera

    // restore the state of our overlay toolbar buttons
    self.cancelButton.enabled = YES;
    self.takePictureButton.enabled = YES;
    self.timedButton.enabled = YES;
    self.startStopButton.enabled = YES;
    self.startStopButton.title = @"Start";
}


#pragma mark -
#pragma mark Camera Actions

- (IBAction)done:(id)sender
{
    // dismiss the camera
    //
    // but not if it's still taking timed pictures
    if (![self.cameraTimer isValid])
        [self finishAndUpdate];
}

// this will take a timed photo, to be taken 5 seconds from now
//
- (IBAction)timedTakePhoto:(id)sender
{
    // these controls can't be used until the photo has been taken
    self.cancelButton.enabled = NO;
    self.takePictureButton.enabled = NO;
    self.timedButton.enabled = NO;
    self.startStopButton.enabled = NO;

    if (self.cameraTimer != nil)
        [self.cameraTimer invalidate];
    _cameraTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                   target:self
                                                 selector:@selector(timedPhotoFire:)
                                                 userInfo:[NSNumber numberWithInt:kOneShot]
                                                  repeats:YES];

    // start the timer to sound off a tick every 1 second (sound effect before a timed picture is taken)
    if (self.tickTimer != nil)
        [self.tickTimer invalidate];
    _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(tickFire:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}

- (IBAction)startStop:(id)sender
{
    if ([self.cameraTimer isValid])
    {
        // stop and reset the timer
        [self.cameraTimer invalidate];
        _cameraTimer = nil;

        [self finishAndUpdate];
    }
    else
    {
        // start the timer to take a photo every 1.5 seconds
        //
        // CAUTION: for the purpose of this sample, we will continue to take pictures indefinitely.
        // Be aware we will run out of memory quickly.  You must decide the proper threshold
        // number of photos allowed to take from the camera.
        //
        // One solution to avoid memory constraints is to save each taken photo to disk rather
        // than keeping all of them in memory.
        //
        // In low memory situations sometimes our "didReceiveMemoryWarning" method will be called
        // in which case we can recover some memory and keep the app running.
        //
        self.startStopButton.title = @"Stop";
        self.cancelButton.enabled = NO;
        self.timedButton.enabled = NO;
        self.takePictureButton.enabled = NO;

        _cameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.5   // fire every 1.5 seconds
                                                       target:self
                                                     selector:@selector(timedPhotoFire:)
                                                     userInfo:[NSNumber numberWithInt:kRepeatingShot]
                                                      repeats:YES];
        [self.cameraTimer fire];	// start taking pictures right away
    }
}


#pragma mark -
#pragma mark Timer

// gets called by our repettive timer to take a picture
- (void)timedPhotoFire:(NSTimer *)timer
{
    [self.imagePickerController takePicture];
    
    NSInteger cameraAction = [self.cameraTimer.userInfo integerValue];
    switch (cameraAction)
    {
        case kOneShot:
        {
            // timer fired for a delayed single shot
            [self.cameraTimer invalidate];
            _cameraTimer = nil;
            
            [self.tickTimer invalidate];
            _tickTimer = nil;
            
            break;
        }
            
        case kRepeatingShot:
        {
            // timer fired for a repeating shot
            break;
        }
    }
}

// gets called by our delayed camera shot timer to play a tick noise
- (void)tickFire:(NSTimer *)timer
{
	AudioServicesPlaySystemSound(self.tickSound);
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    // give the taken picture to our delegate
    if (self.delegate)
        [self.delegate didTakePicture:image];
    
    if (![self.cameraTimer isValid])
        [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}

@end

