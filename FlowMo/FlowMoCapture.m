//
//  FlowMoCapture.m
//  FlowMo
//
//  Created by Bryan Ryczek on 2/10/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "FlowMoCapture.h"
#import <sys/sysctl.h>
//FACEBOOK
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FlowMoCapture ()

@end

@implementation FlowMoCapture

BOOL recordedSuccessfully;
BOOL processingComplete = NO;
//BOOL torchIsOn = NO;
int torchMode = 0;
int cameraPosition = 1;
int frontFlashToggle = 0; // 0 = No CALayer presented 1 = CALayer presented
int globalLoopDuration = 1800;
int flowMoStart = 0;
float screenBrightness;
float seconds;

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addCaptureButton];
    [self addCaptureCircle];
    [self addProcessingCircle];
    [self.view addSubview:self.captureButton];
    [self captureButtonConstraints];
    [self addSwitchCameraButton];
    [self addFlashButton];
    [self addCaptureSession];
    [self firstRunCheck];
}

#pragma mark - Capture Session Init
-(void) addCaptureSession {

//Determine Phone for camera quality
size_t size;
sysctlbyname("hw.machine", NULL, &size, NULL, 0);
char *machine = malloc(size);
sysctlbyname("hw.machine", machine, &size, NULL, 0);
NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
//NSLog(@"platform %@", platform);
//NSLog(@"iPhone Device%@",[self platformType:platform]);
NSString *iPhoneType = [self platformType:platform];
//NSLog(@"iPhoneType %@", iPhoneType);

free(machine);

//Capture Session
self.captureSession = [[AVCaptureSession alloc]init];
if ([iPhoneType isEqualToString: @"iPhone 6"] || [iPhoneType isEqualToString: @"iPhone 6 Plus"]) {
    self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
} else if ([iPhoneType isEqualToString: @"iPhone 5"] || [iPhoneType isEqualToString: @"iPhone 5c"] || [iPhoneType isEqualToString: @"iPhone 5s"]) {
    self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
} else if ([iPhoneType isEqualToString: @"iPhone 4"] || [iPhoneType isEqualToString: @"iPhone 4S"]) {
    // NSLog(@"iPhoneType %@", iPhoneType);
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
} else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported Device"
                                                    message:@"FlowMo is optimized for use with iPhone(s) 4, 4s, 5, 5s 5c, 6 and 6+. We have detected you are using an alternate device. FlowMo may not work appropriately on your device."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
}

//Add device
self.videoDevice = [self frontCamera];

[self.videoDevice lockForConfiguration:nil];
self.videoDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
self.videoDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
[self.videoDevice unlockForConfiguration];

//AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
NSError *error = nil;

//Input
AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
//AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];

if (videoInput)
{
    self.movieOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    Float64 maximumVideoLength = 3; //Max length of video, in seconds
    int32_t preferredTimescale = 30; // FPS of video
    
    CMTime maxDuration = CMTimeMakeWithSeconds(maximumVideoLength, preferredTimescale);
    //NSLog(@"maxDuration %f", CMTimeGetSeconds(maxDuration));
    
    self.movieOutput.maxRecordedDuration = maxDuration;
    //NSLog(@"maxDuration %f",CMTimeGetSeconds(self.movieOutput.maxRecordedDuration));
    
    [self.captureSession addInput:videoInput];
    // [self.captureSession addInput:audioInput];
}
else
{
    NSLog(@"Video Input Error: %@", error);
}
if (!videoInput)
{
    NSLog(@"Audio Input Error: %@", error);
}

//Output

AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
[dataOutput setAlwaysDiscardsLateVideoFrames:YES];

if ( [self.captureSession canAddOutput:dataOutput])
{
    [self.captureSession addOutput:dataOutput];
}
//NSLog(@"video settings %@", dataOutput.videoSettings);

//    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
//    [captureSession addOutput:dataOutput];
//    dataOutput.videoSettings =
//    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

//    self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
//    NSDictionary *stillImageOutputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
//    [self.stillImageOutput setOutputSettings:stillImageOutputSettings];
self.movieOutput = [[AVCaptureMovieFileOutput alloc]init];

[self.captureSession addOutput:self.movieOutput];
//    
//    self.captureConnection = [[AVCaptureConnection alloc]init];
//    self.captureConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
//    //self.captureConnection = self.previewLayer.connection;
//    if ([self.captureConnection isVideoOrientationSupported])
//    {
//        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeLeft;
//        [self.captureConnection setVideoOrientation:orientation];
//    }

    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [self.movieOutput connections] )
    {
        NSLog(@"%@", connection);
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            NSLog(@"%@", port);
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                self.captureConnection = connection;
            }
        }
    }
    NSLog(@"%hhd video orientation supported?", [videoConnection isVideoOrientationSupported]);
    
    if([videoConnection isVideoOrientationSupported])
    {
        NSLog(@"%ld", (long)[[UIDevice currentDevice] orientation]);
        NSLog(@"%ld currentVideoOrientation" , (long)videoConnection.videoOrientation);
    }
    
    
//    self.captureConnection = nil;
//    self.captureConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
//    // self.movieOutput;
//    //connection = [self.previewLayer connection];
//    if ([self.captureConnection isVideoOrientationSupported]) {
//        [self.captureConnection setVideoOrientation:[self avOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]]];
//        [self.captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//    }


    
//Preview Layer
self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
UIView *captureLayerView = [[UIView alloc]initWithFrame:(self.view.frame)];
self.previewLayer.frame = captureLayerView.bounds;
self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
[captureLayerView.layer addSublayer:self.previewLayer];
[self.view addSubview:captureLayerView];
[self.view sendSubviewToBack:captureLayerView];


//Start capture session
[self.captureSession startRunning];

}

- (void)orientationChanged:(NSNotification *)notification {
    
    //PORTRAIT = 1
    //UPSIDE DOWN = 2
    // LANDSCAPE LEFT = 3
    // LANDSCAPE RIGHT = 4
    
    if ([[UIDevice currentDevice] orientation] == 3) {
        NSLog(@"Landscape left");
        [self.captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    } else if ([[UIDevice currentDevice] orientation] == 4) {
        NSLog(@"Landscape right");
        [self.captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    } else if ([[UIDevice currentDevice] orientation] == 1) {
        NSLog(@"Portrait");
        [self.captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    } else if ([[UIDevice currentDevice] orientation] == 2) {
        NSLog(@"Upside down");
        [self.captureConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    }

    
    
    NSLog(@" %ld ORIENTATION CHANGED", (long)[[UIDevice currentDevice] orientation]);
}

//-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//        NSLog(@"Landscape left");
//      //  [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
//    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        NSLog(@"Landscape right");
//      // [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
//    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
//        NSLog(@"Portrait");
//      //  [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
//        NSLog(@"Upside down");
//      //  [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
//    }
//}


- (AVCaptureVideoOrientation) avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    
    AVCaptureVideoOrientation currentOrientation = deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        currentOrientation = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        currentOrientation = AVCaptureVideoOrientationLandscapeLeft;
    else if( deviceOrientation == UIDeviceOrientationPortrait)
        currentOrientation = AVCaptureVideoOrientationPortrait;
    else if( deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
        currentOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    return currentOrientation;
    
}

#pragma mark - Add UI Elements

-(void) addSwitchCameraButton {
    // button to toggle camera positions
    self.switchCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchCamera.translatesAutoresizingMaskIntoConstraints = NO;
    [self.switchCamera setImage:[UIImage imageNamed:@"cameraFlip.png"] forState:UIControlStateNormal];
    [self.switchCamera addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchCamera];
    [self switchCameraButtonConstraints];
}

-(void) addFlashButton {
    //Flash Button
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.flashButton setImage:[UIImage imageNamed:@"flashIconOff.png"] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(setTorchMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    [self flashButtonConstraints];
}

-(void) addCaptureButton {
    //Capture Button Setup
    self.captureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.captureButton.clipsToBounds = YES;
    self.captureButton.layer.cornerRadius = 40;
    self.captureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.captureButton.layer.borderWidth = 0.0f;
    self.captureButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    self.captureButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.captureButton.layer.shouldRasterize = YES;
    UILongPressGestureRecognizer *cameraLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(capture:)];
    cameraLongPress.minimumPressDuration = 0.3;
    [self.captureButton addGestureRecognizer:cameraLongPress];
}

-(void) addCaptureCircle {
    //    //Progress View
    self.captureCircleSession = [[Session alloc] init];
    self.captureCircleSession.state = kSessionStateStop;
    
    self.captureCircle = [[CircleProgressView alloc] init];
    //self.captureCircle.status = NSLocalizedString(@"circle-progress-view.status-not-started", nil);
    self.captureCircle.timeLimit = 3;
    self.captureCircle.elapsedTime = 0;
    self.captureCircle.progressLayer.lineWidth = 15;
    UIColor *tintColor = ([UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.15]);
    self.captureCircle.progressLayer.strokeColor = tintColor.CGColor;
    self.captureCircle.progressLayer.progressLayer.lineWidth = 15;
    self.captureCircle.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.captureCircle];
    [self captureCircleConstraints];
    [self startTimer];
    
}

-(void) addProcessingCircle {
    self.processingCircleSession = [[Session alloc]init];
    self.processingCircleSession.state = kSessionStateStop;
    
    self.processingCircle = [[CircleProgressView alloc]init];
    self.processingCircle.timeLimit = 3;
    //self.processingCircle.line
    self.processingCircle.elapsedTime = 0;
    self.processingCircle.progressLayer.lineWidth = 5;
    UIColor *tintColor = ([UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.15]);
    //self.captureCircle.status = NSLocalizedString(@"circle-progress-view.status-in-progress", nil);
    self.processingCircle.progressLayer.strokeColor = tintColor.CGColor;
    self.processingCircle.progressLayer.progressLayer.lineWidth = 5;
    self.processingCircle.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.processingCircle];
    [self processingCircleConstraints];
    [self startProcessingTimer];
}

-(void) addUploadVideoButton {
    //    //Upload Video Button Setup
    //    self.uploadVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.uploadVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    //    [self.uploadVideoButton setImage:[UIImage imageNamed:@"uploadVideo.png"] forState:UIControlStateNormal];
    //    [self.uploadVideoButton addTarget:self action:@selector(showVideoPicker) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:self.uploadVideoButton];
    //    [self uploadVideoButtonConstraints];
}

#pragma mark - Touch Screen to Focus Camera
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    [self focus:(CGPoint)point];
}

- (void) focus:(CGPoint) point;
{
        if([self.videoDevice isFocusPointOfInterestSupported] &&
           [self.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
            if([self.videoDevice lockForConfiguration:nil]) {
                [self.videoDevice setFocusPointOfInterest:CGPointMake(focusPoint.x,focusPoint.y)];
                [self.videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                if ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                     [self.videoDevice setExposurePointOfInterest:CGPointMake(focusPoint.x,focusPoint.y)];
                    [self.videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                [self.videoDevice unlockForConfiguration];
            }
        }
}


#pragma mark - Camera Setup Methods
//ENSURES LOAD TO CAMERA OF CHOICE
- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *videoDevice in devices) {
        if ([videoDevice position] == AVCaptureDevicePositionBack) {
            self.processingSplit = 0.038;
            return videoDevice;
        }
    }
    return nil;
}

- (void) setTorchMode {
    if ([self.videoDevice hasTorch]) {
        if (torchMode == 0) {
            [self.flashButton setImage:[UIImage imageNamed:@"flashIconOn"] forState:UIControlStateNormal];
            torchMode++;
        } else if (torchMode == 1){
            [self.flashButton setImage:[UIImage imageNamed:@"flashIconAuto"] forState:UIControlStateNormal];
            torchMode++;
        } else {
            [self.flashButton setImage:[UIImage imageNamed:@"flashIconOff"] forState:UIControlStateNormal];
            torchMode = 0;
        }
    }
}

-(void) turnTorchOn {
    [self.videoDevice lockForConfiguration:nil];
    
    if (torchMode == 0) {
        [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
    } else if (torchMode == 1){
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        flowMoStart = flowMoStart + 40;
        globalLoopDuration = globalLoopDuration + 40;
    } else {
        [self.videoDevice setTorchMode:AVCaptureTorchModeAuto];
        flowMoStart = flowMoStart + 40;
        globalLoopDuration = globalLoopDuration + 40;
    }
    [self.videoDevice unlockForConfiguration];
}

- (void) frontFlashOn {
    if (torchMode == 1 || torchMode == 2) {
        
        flowMoStart = flowMoStart+60;
        globalLoopDuration = globalLoopDuration+60;
        
        screenBrightness = [UIScreen mainScreen].brightness;
        [UIScreen mainScreen].brightness = 1.0;
        
        self.flashLayer = self.view.layer;
        self.sublayer = [CALayer layer];
        self.sublayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.sublayer.opacity = 0.85;
        self.sublayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.flashLayer insertSublayer:self.sublayer above:self.flashLayer];
        frontFlashToggle++;
    }
    //else if (torchMode == 2) {
    //        self.flashLayer = self.view.layer;
    //        self.sublayer = [CALayer layer];
    //        self.sublayer.backgroundColor = [UIColor whiteColor].CGColor;
    //        self.sublayer.opacity = 0.85;
    //        self.sublayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //        [self.flashLayer insertSublayer:self.sublayer above:self.flashLayer];
    //        frontFlashToggle++;
    //    }
}

-(void) frontFlashOff {
    [self.sublayer removeFromSuperlayer];
    frontFlashToggle = 0;
}

- (void)swapFrontAndBackCameras:(id)sender {
    // Assume the session is already running
    
    NSArray *inputs = self.captureSession.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device ;
        if ([device hasMediaType : AVMediaTypeVideo ] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if ( position == AVCaptureDevicePositionFront ) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                self.processingSplit = 0.046;
                cameraPosition = 1;
                
            } else if  (position == AVCaptureDevicePositionBack) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                self.processingSplit = 0.038;
                cameraPosition = 2;
            }
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.captureSession beginConfiguration];
            
            [self.captureSession removeInput: input];
            [self.captureSession addInput: newInput];
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.captureSession commitConfiguration];
            break ;
        }
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (void)deallocCamera {
    AVCaptureInput* input = [self.captureSession.inputs objectAtIndex:0];
    [self.captureSession removeInput:input];
    AVCaptureVideoDataOutput* output = [self.captureSession.outputs objectAtIndex:0];
    [self.captureSession removeOutput:output];
    [self.captureSession stopRunning];
}


#pragma mark - Gesture Recognizers

-(IBAction)capture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
        [self.videoDevice unlockForConfiguration];
        [self.movieOutput stopRecording]; //AVCaptureFileOutputRecordingDelegate METHOD. CALLS  "captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:" METHOD.
   
        if(frontFlashToggle == 1) {
        [self frontFlashOff];
        [UIScreen mainScreen].brightness = screenBrightness;
        }
        [self actionButtonClick];
        [self processingActionButtonClick];
    } else if (sender.state == UIGestureRecognizerStateBegan) {
            
            if (cameraPosition == 1) {
                    
                    [self turnTorchOn];
                
            } else if (cameraPosition == 2)
                
                {
                    [self frontFlashOn];
                }
        self.processingCircle.elapsedTime = 0;
        [self actionButtonClick];
        [self.movieOutput startRecordingToOutputFileURL:[self tempFileURL] recordingDelegate:self];
        self.captureButton.enabled = NO;
    }
 }

#pragma mark - Upload Video from File Methods


-(void)showVideoPicker
{
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    
        self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    
        [self presentViewController:self.imagePicker animated:NO completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:self.imagePicker completion:nil];
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSLog(@"upload video URL %@", videoURL);
    //[self generateImageSequence: videoURL];
    
}


//-(void) imagePickerController: (UIImagePickerController *) picker
//didFinishPickingMediaWithInfo: (NSDictionary *) info
//{
//
//
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//
//    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo)
//    {
//
//        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
//
//        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
//        // NSLog(@"%@",moviePath);
//
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
//        }
//    }
//
//
//    [self dismissModalViewControllerAnimated:YES];
//
//  //  [picker release];
//
//
//}


#pragma mark - Video Capture & Image Generation & Present ImageArrayPreview
- (NSURL *) tempFileURL
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@",
                            NSTemporaryDirectory(), @"output.mov"];
    //NSLog(@"output path %@", outputPath);
    NSURL *outputURL = [[NSURL alloc]initFileURLWithPath:outputPath];
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:outputPath])
    {
        [manager removeItemAtPath:outputPath error:nil];
    }
    //NSLog (@"OutputURL %@", outputURL.description);
    return outputURL;
}


-(void)               captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error

{
    recordedSuccessfully = YES;
   

    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo]
                    objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
            recordedSuccessfully = [value boolValue];
        // Logging the problem anyway:
        NSLog(@"A problem occurred while recording: %@", error);
    }
   
    //[self saveVideoToCameraRoll:(NSURL *)outputFileURL];
    [self generateImageSequence: outputFileURL];
}

-(float)generateImageSequence:(NSURL *)outputFileURL
{
    
    NSURL *url = outputFileURL;
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:[NSDictionary dictionaryWithObject:@"YES" forKey:AVURLAssetPreferPreciseDurationAndTimingKey]]; //Change Object to @"NO" to turn off precise access.
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    self.imageGenerator.requestedTimeToleranceAfter=kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceBefore=kCMTimeZero;
    
//    NSMutableArray *thumbTimes=[NSMutableArray arrayWithCapacity:urlAsset.duration.value];
    NSMutableArray *thumbTimes = [[NSMutableArray alloc]init];
    NSInteger loopDuration = urlAsset.duration.value;

    if (loopDuration > globalLoopDuration) {
        loopDuration = globalLoopDuration;
    }
    
    
    for(int t=flowMoStart; t < loopDuration; t=t+20) {
            CMTime thumbTime = CMTimeMake(t, urlAsset.duration.timescale);
        //  NSLog(@"Time Scale : %d ", urlAsset.duration.timescale);
        NSValue *timeValue=[NSValue valueWithCMTime:thumbTime];
        [thumbTimes addObject:timeValue];
    }
    
    //NSLog(@"ThumbTimes %@ %lu", thumbTimes, (unsigned long)thumbTimes.count);
    if (!self.imageArray) {
        self.imageArray = [[NSMutableArray alloc] initWithCapacity:thumbTimes.count];
        self.movieArray = [[NSMutableArray alloc] initWithCapacity:thumbTimes.count];
    }
    else {
        [self.imageArray removeAllObjects];
        [self.movieArray removeAllObjects];
    }
    
    //[self determineSeconds:(float)thumbTimes.count];
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:thumbTimes
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error)
     {
         // NSString *requestedTimeString = (NSString *) CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
         // NSString *actualTimeString = (NSString *) CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
         //         NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
         
         if (result == AVAssetImageGeneratorSucceeded) {
             //NSLog(@"thumbtimes.count %d", thumbTimes.count);
             //[self processCounter:(float)thumbTimes.count];
             
             //NSLog(@"SUCCESS!");
             
            [self.imageArray addObject:[UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationRight]];
             [self.movieArray addObject:[UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp]];
             //             NSLog(@"thumbTimes:%@",thumbTimes);
             //NSLog(@"thumbTimes.count = %lu imageArray.count = %lu", (unsigned long)thumbTimes.count, (unsigned long)self.imageArray.count);
             
                          if (thumbTimes.count == self.imageArray.count) {
                            
                              [self presentImageArrayPreview: outputFileURL];
                              
                            //[self presentTutorial];
                          }
         }
         if (result == AVAssetImageGeneratorFailed) {
             NSLog(@"Failed with error: %@", [error localizedDescription]);
         }
         if (result == AVAssetImageGeneratorCancelled) {
             NSLog(@"Canceled");
         }
         
     }];
    
    flowMoStart = 0;
    globalLoopDuration = 1800;

    return (float)thumbTimes.count;
    
}

-(void)presentImageArrayPreview:(NSURL *)outputFileURL {
    recordedSuccessfully = NO;
    [self processingActionButtonClick];
    ImageArrayPreview *imageArrayPreview = [[ImageArrayPreview alloc] init];
    imageArrayPreview.imageArray = self.imageArray;
    imageArrayPreview.movieArray = self.movieArray;
    imageArrayPreview.outputURL = outputFileURL;
    [self presentViewController:imageArrayPreview animated:NO completion:nil];
    self.captureButton.enabled = YES;
}




#pragma mark - Constraint Methods for Buttons
//Capture Button Constraints
-(void)cancelButtonConstraints {
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"cancelButton":self.cancelButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @30,
                               @"buttonWidth": @132,
                               @"verticalConstraint": @0,
                               @"horizontalConstraint":@0};
    
    
    // 2. Define the redView Size
    NSArray *cancelButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelButton(buttonHeight)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];
    
    NSArray *cancelButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancelButton(buttonWidth)]"
                                                                                options:0
                                                                                metrics:metrics                                                                      views:viewsDictionary];
    [self.cancelButton addConstraints:cancelButtonConstraint_H];
    [self.cancelButton addConstraints:cancelButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *cancelButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelButton]-verticalConstraint-|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    
    NSArray *cancelButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[cancelButton]"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    [self.view addConstraints:cancelButtonConstraint_POS_H];
    [self.view addConstraints:cancelButtonConstraint_POS_V];
}


-(void)captureButtonConstraints {
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"captureButton":self.captureButton};
    NSDictionary *metrics = @{ @"buttonHeight": @80,
                               @"buttonWidth": @80,
                               @"verticalConstraint": @15,
                               @"horizontalConstraint":[NSNumber numberWithFloat:(self.view.frame.size.width/2)-(80/2)]};
    
    
    // 2. Define the redView Size
    NSArray *captureButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureButton(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
    
    NSArray *captureButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[captureButton(buttonWidth)]"
                                                                                 options:0
                                                                                 metrics:metrics                                                                      views:viewsDictionary];
    [self.captureButton addConstraints:captureButtonConstraint_H];
    [self.captureButton addConstraints:captureButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *captureButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureButton]-verticalConstraint-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    
    NSArray *captureButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[captureButton]"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    [self.view addConstraints:captureButtonConstraint_POS_H];
    [self.view addConstraints:captureButtonConstraint_POS_V];
}


-(void)captureCircleConstraints {

    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"captureCircle":self.captureCircle};
    NSDictionary *metrics = @{ @"buttonHeight": @85,
                               @"buttonWidth": @85,
                               @"verticalConstraint": @12.5,
                               @"horizontalConstraint":[NSNumber numberWithFloat:(self.view.frame.size.width/2)-(85/2)]};


    // 2. Define the redView Size
    NSArray *captureCircleConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureCircle(buttonHeight)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];

    NSArray *captureCircleConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[captureCircle(buttonWidth)]"
                                                                                options:0
                                                                                metrics:metrics                                                                      views:viewsDictionary];
    [self.captureCircle addConstraints:captureCircleConstraint_H];
    [self.captureCircle addConstraints:captureCircleConstraint_V];

    // 3. Define the redView Position
    NSArray *captureCircleConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureCircle]-verticalConstraint-|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];

    NSArray *captureCircleConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[captureCircle]"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    [self.view addConstraints:captureCircleConstraint_POS_H];
    [self.view addConstraints:captureCircleConstraint_POS_V];
}

-(void)processingCircleConstraints {
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"processingCircle":self.processingCircle};
    NSDictionary *metrics = @{ @"buttonHeight": @75, //IF YOU CHANGE HEIGHT OF BUTTON, CHANGE MATCHING # IN horizontalConstraint BELOW
                               @"buttonWidth": @75,
                               @"verticalConstraint": @17.5,
                               @"horizontalConstraint":[NSNumber numberWithFloat:(self.view.frame.size.width/2)-(75/2)]};
    
    
    // 2. Define the redView Size
    NSArray *processingCircleConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[processingCircle(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
    
    NSArray *processingCircleConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[processingCircle(buttonWidth)]"
                                                                                 options:0
                                                                                 metrics:metrics                                                                      views:viewsDictionary];
    [self.processingCircle addConstraints:processingCircleConstraint_H];
    [self.processingCircle addConstraints:processingCircleConstraint_V];
    
    // 3. Define the redView Position
    NSArray *processingCircleConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[processingCircle]-verticalConstraint-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    
    NSArray *processingCircleConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[processingCircle]"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    [self.view addConstraints:processingCircleConstraint_POS_H];
    [self.view addConstraints:processingCircleConstraint_POS_V];
}

-(void)flashButtonConstraints {
    
    
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"flashButton":self.flashButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @40,
                               @"buttonWidth": @31,
                               @"verticalConstraint": @15,
                               @"horizontalConstraint":@15};
    
    
    // 2. Define the redView Size
    NSArray *flashButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[flashButton(buttonHeight)]"
                                                                                      options:0
                                                                                      metrics:metrics
                                                                                        views:viewsDictionary];
    
    NSArray *flashButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[flashButton(buttonWidth)]"
                                                                                      options:0
                                                                                      metrics:metrics                                                                      views:viewsDictionary];
    [self.flashButton addConstraints:flashButtonConstraint_H];
    [self.flashButton addConstraints:flashButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *flashButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalConstraint-[flashButton]"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    
    NSArray *flashButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[flashButton]"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    [self.view addConstraints:flashButtonConstraint_POS_H];
    [self.view addConstraints:flashButtonConstraint_POS_V];
}

-(void)switchCameraButtonConstraints {
    
    
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"switchCameraButton":self.switchCamera};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @32,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@15};
    
    
    // 2. Define the redView Size
    NSArray *switchCameraButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[switchCameraButton(buttonHeight)]"
                                                                                      options:0
                                                                                      metrics:metrics
                                                                                        views:viewsDictionary];
    
    NSArray *switchCameraButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[switchCameraButton(buttonWidth)]"
                                                                                      options:0
                                                                                      metrics:metrics                                                                      views:viewsDictionary];
    [self.switchCamera addConstraints:switchCameraButtonConstraint_H];
    [self.switchCamera addConstraints:switchCameraButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *switchCameraButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalConstraint-[switchCameraButton]"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    
    NSArray *switchCameraButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[switchCameraButton]-horizontalConstraint-|"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    [self.view addConstraints:switchCameraButtonConstraint_POS_H];
    [self.view addConstraints:switchCameraButtonConstraint_POS_V];
}

-(void)uploadVideoButtonConstraints {
    
    
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"uploadVideoButton":self.uploadVideoButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @35,
                               @"buttonWidth": @35,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@15};
    
    
    // 2. Define the redView Size
    NSArray *uploadVideoButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[uploadVideoButton(buttonHeight)]"
                                                                                      options:0
                                                                                      metrics:metrics
                                                                                        views:viewsDictionary];
    
    NSArray *uploadVideoButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[uploadVideoButton(buttonWidth)]"
                                                                                      options:0
                                                                                      metrics:metrics                                                                      views:viewsDictionary];
    [self.uploadVideoButton addConstraints:uploadVideoButtonConstraint_H];
    [self.uploadVideoButton addConstraints:uploadVideoButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *uploadVideoButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[uploadVideoButton]-verticalConstraint-|"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    
    NSArray *uploadVideoButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[uploadVideoButton]"
                                                                                          options:0
                                                                                          metrics:metrics
                                                                                            views:viewsDictionary];
    [self.view addConstraints:uploadVideoButtonConstraint_POS_H];
    [self.view addConstraints:uploadVideoButtonConstraint_POS_V];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Timer

- (void)startTimer {
    if ((!self.captureCircleTimer) || (![self.captureCircleTimer isValid])) {
        
        self.captureCircleTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                                   target:self
                                                                 selector:@selector(poolTimer)
                                                                 userInfo:nil
                                                                  repeats:YES];
    }
}

- (void)poolTimer
{
    if ((self.captureCircleSession) && (self.captureCircleSession.state == kSessionStateStart))
    {
        // NSLog(@"%f elapsed time", self.captureCircle.elapsedTime);
        self.captureCircle.elapsedTime = self.captureCircleSession.progressTime;
    }
}


#pragma mark - User Interaction
- (void)actionButtonClick {
    
    if (self.captureCircleSession.state == kSessionStateStop) {
        
        self.captureCircleSession.startDate = [NSDate date];
        self.captureCircleSession.finishDate = nil;
        self.captureCircleSession.state = kSessionStateStart;
        
        UIColor *tintColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.5];
        //self.captureCircle.status = NSLocalizedString(@"circle-progress-view.status-in-progress", nil);
        self.captureCircle.tintColor = tintColor;
        self.captureCircle.elapsedTime = 0;
        
        //[self.actionButton setTitle:NSLocalizedString(@"progress-view-controller.action-button.title-stop", nil) forState:UIControlStateNormal];
        //self.actionButton setTintColor:tintColor];
    }
    else {
        self.captureCircleSession.finishDate = [NSDate date];
        self.captureCircleSession.state = kSessionStateStop;
        
        //self.captureCircle.status = NSLocalizedString(@"circle-progress-view.status-not-started", nil);
        self.captureCircle.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        self.captureCircle.elapsedTime = self.captureCircleSession.progressTime;
        //[self reset];
    }
}

-(void) reset {
    self.captureCircle.elapsedTime = 0;
    
}

#pragma mark - Processing Timer
- (void)startProcessingTimer {
    if ((!self.processingCircleTimer) || (![self.processingCircleTimer isValid])) {
        
        self.processingCircleTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                                      target:self
                                                                    selector:@selector(poolProcessingTimer)
                                                                    userInfo:nil
                                                                     repeats:YES];
    }
}

- (void)poolProcessingTimer
{
    if ((self.processingCircleSession) && (self.processingCircleSession.state == kSessionStateStart))
    {
        //NSLog(@"%f elapsed time", self.processingCircle.elapsedTime);
        self.processingCircle.elapsedTime = self.processingCircleSession.progressTime;
    }
}

#pragma mark - User Interaction
- (void)processingActionButtonClick {
    
    if (self.processingCircleSession.state == kSessionStateStop) {
        
        self.processingCircleSession.startDate = [NSDate date];
        self.processingCircleSession.finishDate = nil;
        self.processingCircleSession.state = kSessionStateStart;
        
        UIColor *tintColor = [UIColor colorWithRed:255/255 green:0/255 blue:0/255 alpha:1];
        //self.processingCircle.status = NSLocalizedString(@"circle-progress-view.status-in-progress", nil);
        self.processingCircle.tintColor = tintColor;
        self.processingCircle.elapsedTime = 0;
        
        //[self.actionButton setTitle:NSLocalizedString(@"progress-view-controller.action-button.title-stop", nil) forState:UIControlStateNormal];
        //self.actionButton setTintColor:tintColor];
    }
    else {
        self.processingCircleSession.finishDate = [NSDate date];
        self.processingCircleSession.state = kSessionStateStop;
        
        //self.processingCircle.status = NSLocalizedString(@"circle-progress-view.status-not-started", nil);
        self.processingCircle.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
        self.processingCircle.elapsedTime = self.processingCircleSession.progressTime;
        //[self processingReset];
    }
}

-(void) processingReset {
    self.processingCircle.elapsedTime = 0;
    
}

#pragma mark - Determine Device Type
- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4"; //Verizon iPhone 4
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5"; //iPhone 5 (GSM)
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";//iPhone 5 (GSM+CDMA)
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";//iPhone 5c (GSM)
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";//iPhone 5c (GSM+CDMA)"
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";//iPhone 5s (GSM)
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";//iPhone 5s (GSM+CDMA)
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

#pragma mark - General Setup
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Tutorial Methods

-(void)firstRunCheck
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![[defaults objectForKey:@"firstRun"]isEqualToString:@"YES"])
        //if(![[defaults objectForKey:@"firstRun"]isEqualToString:@"NO"])
    {
        [self flowMoTutorial];
    }else {
    
    }
}

-(void)presentTutorial {
    NSLog(@"Method:presentTutorial");
    Tutorial *tutorial = [[Tutorial alloc]init];
    //tutorial.tutorialArray = self.tutorialArray;
    [self presentViewController:tutorial animated:NO completion:nil];
}


-(void)flowMoTutorial {
    
    UIImage *clearImage = [[UIImage alloc]init]; // Init blank UIImage
    
    self.captureButton.hidden = YES;
    self.switchCamera.hidden = YES;
    
    self.tutorialArray = [[NSMutableArray alloc] init];
    
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-19.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-20.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-21.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-22.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-13.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-19.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-20.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-21.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-15.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-17.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-18.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-15.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-17.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-18.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-13.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-22.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide6-12.png"]];
    
    self.tutorialSlideGraphic = [[NSMutableArray alloc] init];
    
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-1.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-1.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-1.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-1.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-2.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-2.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-2.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-2.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-2.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-3.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-3.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-3.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-3.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-4.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-4.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-4.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-4.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-4.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-5.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-5.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-5.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-5.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-6.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-6.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-6.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-6.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-7.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-7.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-7.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-7.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-8.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-8.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-8.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-8.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-8.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-9.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-9.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-9.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-9.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-10.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-10.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-10.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-10.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-11.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-11.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-11.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-11.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-12.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-13.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-13.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-13.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-13.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-13.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-14.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-14.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-14.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-14.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-14.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-15.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-15.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-15.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-15.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-15.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-16.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-16.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-16.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-16.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-17.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-17.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-17.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-17.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-17.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-18.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-18.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-18.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-18.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-18.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-19.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-19.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-19.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-19.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-20.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-20.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-20.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-20.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-20.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-21.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-21.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-21.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-22.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-22.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlide5-22.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSlideGraphic addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    
    //ITEM# IN
    NSLog(@"tutorialarray count %lul", (unsigned long)self.tutorialArray.count);
    NSLog(@"tutorialarray count %lul", (unsigned long)self.tutorialSlideGraphic.count);
    
    //TRANSLUCENT WHITE BACKGROUND FOR TUTORIAL TEXT
    self.tutorialLayer = self.view.layer;
    self.sublayer = [CALayer layer];
    float yVal = self.view.frame.size.height*0.01;
    float hVal = self.view.frame.size.height*0.80;
    CGFloat yValue = yVal;
    CGFloat heightValue = hVal;
    NSLog(@"yValue %f", yValue);
    NSLog(@"heightValue %f", heightValue);
    self.sublayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.sublayer.opacity = 0.4;
    self.sublayer.frame = CGRectMake(5, yValue, self.view.frame.size.width-10, hVal);
    
    self.sublayer2 = [CALayer layer];
    float xVal1 = self.view.frame.size.width*(40/320);
    float yVal1 = self.view.frame.size.height*(530/568);
    float wVal1 = self.view.frame.size.width*(240/320);
    float hVal1 = self.view.frame.size.height*(40/568);
    CGFloat yValue1 = yVal1;
    CGFloat xValue1 = xVal1;
    CGFloat hValue1 = hVal1;
    CGFloat wValue1 = wVal1;
    self.sublayer2.backgroundColor = [UIColor whiteColor].CGColor;
    self.sublayer2.opacity = 0.4;
    self.sublayer2.frame = CGRectMake(xValue1, yValue1, wValue1, hValue1);
    
    
    self.tutorialView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialSlideCLEAR"]];
    self.tutorialView.frame = CGRectMake(0,-35,self.view.frame.size.width,self.view.frame.size.height);
    self.tutorialView.backgroundColor = [UIColor clearColor];
    self.tutorialView.alpha = 1;
    self.tutorialView.contentMode = UIViewContentModeScaleAspectFill;
    [self.tutorialView setUserInteractionEnabled:TRUE];
    
    self.tutorialSlideGraphicView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialSlide5-1.png"]];
    self.tutorialSlideGraphicView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    self.tutorialSlideGraphicView.backgroundColor = [UIColor clearColor];
    
    self.tutorialSlider = [[ImageSlider alloc]init];
    //UIImage *clearImage = [[UIImage alloc]init]; // Init blank UIImage
    [self.tutorialSlider setThumbImage:clearImage forState:UIControlStateNormal];//Hides tutorialSlider tracking icon
    [self.tutorialSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];//Hides tutorialSlider track
    [self.tutorialSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];//Hides tutorialSlider track
    self.tutorialSlider.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 0);
    self.tutorialSlider.minimumValue = 0.0;
    self.tutorialSlider.maximumValue = self.tutorialArray.count-1;
    self.tutorialSlider.continuous = YES;
    self.tutorialSlider.value = 0.0;
    [self.tutorialSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.tutorialView addSubview:self.tutorialSlider];
    [self.view insertSubview:self.tutorialView belowSubview:self.captureButton];//So that when tutorial reaches end captureButton will be "pressable"
    [self.view insertSubview:self.tutorialSlideGraphicView belowSubview:self.captureButton];
    
    self.cancelButton = [[UIButton alloc]init];
    //self.cancelButton.frame = CGRectMake(10, 20, 132, 30);
    [self.cancelButton setImage:[UIImage imageNamed:@"skipTutorialButton.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismissTutorial) forControlEvents:UIControlEventTouchDown];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tutorialLayer insertSublayer:self.sublayer2 above:self.tutorialView.layer];
    
    //[self cancelButtonConstraints];
    
    //        CALayer *sublayer = [CALayer layer];
    //        sublayer.backgroundColor = [UIColor blueColor].CGColor;
    //        sublayer.shadowOffset = CGSizeMake(0, 3);
    //        sublayer.shadowRadius = 5.0;
    //        sublayer.shadowColor = [UIColor blackColor].CGColor;
    //        sublayer.shadowOpacity = 0.8;
    //        sublayer.frame = CGRectMake(30, 30, 128, 192);
    //        [tutorialLayer addSublayer:sublayer];
    
    //[self.view.layer addSublayer:tutorialLayer1];
    
}

-(IBAction)sliderValueChanged:(UISlider *)tutorialSlider
{
    NSInteger currentImageIndex = (self.tutorialSlider.value);
    NSLog(@"CII %ld", (long)currentImageIndex);
    //self.imageView.image = [self.tutorialArray objectAtIndex:currentImageIndex];
    [self.tutorialView setImage:[self.tutorialArray objectAtIndex:currentImageIndex]];
    [self.tutorialSlideGraphicView setImage:[self.tutorialSlideGraphic objectAtIndex:currentImageIndex]];
    
    if(currentImageIndex >= 5) {
        [self.sublayer2 removeFromSuperlayer];
    }
    if(currentImageIndex >= 50) {
        [self.tutorialView addSubview:self.cancelButton];
        [self cancelButtonConstraints];
    }
    if(currentImageIndex <= 50) {
        [self.sublayer removeFromSuperlayer];
        //[self.sublayer1 removeFromSuperlayer];
    }
    if((currentImageIndex >= 50) && (currentImageIndex <= 70))  {
        [self.tutorialLayer insertSublayer:self.sublayer below:self.tutorialView.layer];
    }
    
    if((currentImageIndex <= 89)) {
        self.captureButton.hidden = YES;
        self.switchCamera.hidden = YES;
    }
    
    if(currentImageIndex >= 90) {
        self.captureButton.hidden = NO;
        self.switchCamera.hidden = NO;
    }
    if(currentImageIndex >=93) {
        [self.sublayer removeFromSuperlayer];
    }
}

-(void)dismissTutorial {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"firstRun"];
    
    self.captureButton.hidden = NO;
    self.switchCamera.hidden = NO;
    [self.tutorialView removeFromSuperview];
    [self.tutorialSlider removeFromSuperview];
    [self.tutorialSlideGraphicView removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self.tutorialArray removeAllObjects];
    [self.sublayer removeFromSuperlayer];
    [self.sublayer1 removeFromSuperlayer];
}

//-(void) saveVideoToCameraRoll:(NSURL *)outputFileURL {
//      NSLog(@"%hhd", recordedSuccessfully);
//      if (recordedSuccessfully)
//     {   //VideoPreviewLayer *vidPreview = [[VideoPreviewLayer alloc] init];
////            vidPreview.view.frame = self.view.frame;
////             [self createThumbnailForVideoURL:outputFileURL];
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//
//            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
//                                        completionBlock:^(NSURL *assetURL, NSError *error)
//             {
//                 UIAlertView *alert;
//                 if (!error)
//                 {
//                     alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
//                                                        message:@"The movie was successfully saved to your photos library"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
//                 }
//                 else
//                 {
//                     alert = [[UIAlertView alloc] initWithTitle:@"Error Saving Video"
//                                                        message:@"The movie was not saved to your photos library"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
//                 }
//
//                 [alert show];
//
//
//             }
//             ];
//     }
//
//}

//-(float)determineseconds:(float)thumbTimes and:(NSString *)camera{
//
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//            appDelegate.seconds = (self.processingSplit * thumbTimes);
//            NSLog(@"Seconds %f",seconds);
//            return seconds;
//        }

//-(float)determineSeconds:(float)thumbTimes
//{   NSLog(@"split %f thumbtimes %f", self.processingSplit, thumbTimes);
//    float seconds = (self.processingSplit * thumbTimes);
//    NSLog(@"Seconds %f",seconds);
//    self.processingView.animationDuration = [NSNumber numberWithFloat:seconds];
//    NSLog(@"aniDUR %@", self.processingView.animationDuration);
//    //self.processingView.animationDuration = [NSNumber numberWithFloat:5];
//    return seconds;
//
////    Do math to get seconds
////    convert to a float
////    set this property self.progressView.anmationDuration
////    self.progressView.anmationDuration = [NSNumber numberWithFloat:5];
////    If it won't let you set the property, us NSUserDefaults to set the duration variable
//}


@end
