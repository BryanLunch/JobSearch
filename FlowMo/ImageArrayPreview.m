//
//  ImageArrayPreview.m
//  FlowSelect
//
//  Created by Bryan Ryczek on 1/27/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "ImageArrayPreview.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>



@interface ImageArrayPreview ()

@end

@implementation ImageArrayPreview

BOOL ScratchModeOn = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    [delegate.window insertSubview:self.imageView aboveSubview:self.view];

//    self.videoPlayerButton = [[UIButton alloc]init];
//    self.videoPlayerButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.videoPlayerButton setImage:[UIImage imageNamed:@"whiteVideoIcon50x50.png"] forState:UIControlStateNormal];
//    [self.videoPlayerButton addTarget:self action:@selector(saveVideoToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    double delayInSeconds = .01; //Design Flaw: Without delay image array will not load properly.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addImageSlider];
        [self addImageView];
        [self addScratchModeInit];
        [self addCancelButton];
        [self addSaveButton];
        [self addForwardButton];
        [self addBackwardButton];
        [self addMessengerButton];
        [self firstRunCheck];
        //[self.view addSubview:self.videoPlayerButton];
        //[self videoPlayerButtonConstraints];
        //[self imageSliderConstraints];
        
    });
    
}

#pragma mark - viewDidLoad Methods

-(void)addImageView {
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.imageView.alpha = 1.0;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setImage:[self.imageArray objectAtIndex:0]];
    self.sliderImage = [self.imageArray objectAtIndex:0];
    [self.view addSubview:self.imageView];
}

-(void)addImageSlider {
    self.imageSlider = [[ImageSlider alloc]init];
    //self.imageSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageSlider.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 31);
    self.imageSlider.minimumValue = 0.0;
    self.imageSlider.maximumValue = self.imageArray.count-1;
    self.imageSlider.continuous = YES;
    self.imageSlider.value = 0.0;
    [self.imageSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //[self.imageSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UI]
    [self.view addSubview:self.imageSlider];
    
    self.scratchModeLongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(scratchModeLongPress:)];
    self.scratchModeLongPress.minimumPressDuration = 1.0;
    [self.view addGestureRecognizer:self.scratchModeLongPress];
    
    }

-(void) addCancelButton {
    self.cancelButton = [[UIButton alloc]init];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setImage:[UIImage imageNamed:@"returnToCamera.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(returnToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    [self cancelButtonConstraints];
}

-(void) addSaveButton {
    self.saveButton = [[UIButton alloc]init];
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveButton setImage:[UIImage imageNamed:@"cameraSave.png"] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveImageFromImageArray) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self saveButtonConstraints];

}

-(void) addForwardButton {
    NSLog(@"FORWARD");
    self.forwardButton = [[UIButton alloc]init];
    self.forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.forwardButton setImage:[UIImage imageNamed:@"frameForward"] forState:UIControlStateNormal];
    [self.forwardButton addTarget:self action:@selector(sliderValueForward) forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer *forwardButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(forwardButtonLongPress:)];
    forwardButtonLongPress.minimumPressDuration = 0.3;
    [self.forwardButton addGestureRecognizer:forwardButtonLongPress];
    
    [self.view addSubview:self.forwardButton];
    [self forwardButtonConstraints];
    
}

-(void) addBackwardButton {
    NSLog(@"BACKWARD");
    self.backwardButton = [[UIButton alloc]init];
    self.backwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backwardButton setImage:[UIImage imageNamed:@"frameBackward"] forState:UIControlStateNormal];
    [self.backwardButton addTarget:self action:@selector(sliderValueBackward) forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer *backwardButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backwardButtonLongPress:)];
    backwardButtonLongPress.minimumPressDuration = 0.3;
    [self.backwardButton addGestureRecognizer:backwardButtonLongPress];
    
    [self.view addSubview:self.backwardButton];
    [self backwardButtonConstraints];
}

-(void) addScratchModeInit {
//    self.scratchModeButton = [[UIButton alloc]init];
//    self.scratchModeButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.scratchModeButton setImage:[UIImage imageNamed:@"scratchModeIcon.png"] forState:UIControlStateNormal];
//    [self.scratchModeButton addTarget:self action:@selector(toggleScratchMode) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.scratchModeButton];
//    [self scratchModeButtonConstraints];
    self.scratchModeArray = [[NSMutableArray alloc]init];
    self.scratchModeIconView = [[UIImageView alloc]init];
    self.scratchModeIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scratchModeIconView setImage:[UIImage imageNamed:@"scratchMode.png" ]];

    }

#pragma mark - Scratch Mode Methods

-(IBAction)scratchModeLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self scratchModeReturnButtons];
        //[self.scratchModeTimer invalidate];
        NSLog(@"DONE SCRATCHIN");
        [self.scratchModeIconView removeFromSuperview];
        if (ScratchModeOn == YES); {
            ScratchModeOn = NO;
        }
        [self.audioRecorder stopRecording];
        //[self.audioRecorder playTapped];
        [self process];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
 
        NSInteger currentImageIndex = (self.imageSlider.value);
        
        UIImage *localImage = [self.imageArray objectAtIndex:currentImageIndex];
        self.sliderImage = localImage;
        [self.imageView setImage:localImage];
        float currentX = [sender locationInView:self.view].x;
        self.imageSlider.value = (currentX/CGRectGetWidth(self.view.frame))*self.imageSlider.maximumValue;

    }
    else if (sender.state == UIGestureRecognizerStateBegan) {
        [self scratchModeRemoveButtons];
        [self.view addSubview:self.scratchModeIconView];
        [self scratchModeIconViewConstraints];
        NSLog(@"SCRATCHIN");
        ScratchModeOn = YES;
        self.scratchModeX = [sender locationInView:self.view].x;
        [self scratchModeTimer];
        
        self.audioRecorder = [[AudioRecorder alloc]init];
        [self.audioRecorder recorderSetup];
        [self.audioRecorder recordPauseTapped];
        
    }
}

- (void) scratchModeRemoveButtons {
    [self.forwardButton removeFromSuperview];
    [self.backwardButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self.saveButton removeFromSuperview];
}

-(void) scratchModeReturnButtons {
    [self.view addSubview:self.forwardButton];
    [self forwardButtonConstraints];
    [self.view addSubview:self.backwardButton];
    [self backwardButtonConstraints];
    [self.view addSubview:self.cancelButton];
    [self cancelButtonConstraints];
    [self.view addSubview:self.saveButton];
    [self saveButtonConstraints];
}

- (void) scratchModeTimer {
    
    self.scratchModeTimer = [NSTimer scheduledTimerWithTimeInterval:0.03333333 //WILL PLAY AT 30 FPS
                                                             target:self
                                                           selector:@selector(generateScratchModeSequence:)
                                                           userInfo:nil
                                                            repeats:NO];
    
}

-(void)generateScratchModeSequence:(UISlider *)imageSlider {
    //[self.imageArray addObject:[UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationRight]];
    
    NSInteger currentImageIndex = (self.imageSlider.value);
    UIImage *localImage = [self.movieArray objectAtIndex:currentImageIndex];
    [self.scratchModeArray addObject:localImage];
   // NSLog(@"scratchmode array %lu", (unsigned long)self.scratchModeArray.count);
    
    if (ScratchModeOn == YES) {
        
        self.scratchModeTimer = [NSTimer scheduledTimerWithTimeInterval:0.03333333 //WILL PLAY AT 30 FPS
                                                                 target:self
                                                               selector:@selector(generateScratchModeSequence:)
                                                               userInfo:nil
                                                                repeats:NO];
        
    }
}

#pragma mark - Asset Writer Methods

- (void)process
{
   // NSMutableArray *frames = [[NSMutableArray alloc] init];
//    
      UIImage *firstImage = [self.scratchModeArray objectAtIndex:0];
//    UIImage *icon2 = [UIImage imageNamed:@"icon2"];
//    UIImage *icon3 = [UIImage imageNamed:@"icon3"];
    
    NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:firstImage.size.width andHeight:firstImage.size.height];
    self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];
//    for (NSInteger i = 0; i < 10; i++) {
//        //[frames addObject:icon1];
//        [frames addObject:icon2];
//        [frames addObject:icon3];
//    }
    
    [self.movieMaker createMovieFromImages:[self.scratchModeArray copy] withCompletion:^(NSURL *fileURL){
      //  [self addAudioToFileAtPath:<#(NSString *)#> toPath:<#(NSString *)#>]
        [self playCapture:fileURL];
    }];
}

//- (void) addAudioToFileAtPath:(NSString *)filePath toPath:(NSURL *) outputFilePath {
//    AVMutableComposition *mixComposition = [AVMutableComposition composition]; // RETURN A NEW COMPOSITION
//    
//    NSString *audioInputFileName = @"audiofileName"; //PASS IN FILE NAME
//    NSString *audioInputFilePath = [[NSBundle mainBundle] pathForResource:audiofileName ofType:.mp4];
//    NSURL *audioInputFileURL = [NSURL fileURLWithPath:audioInputFilePath];
//    
//    NSString *videoInputFileName = @"videofileName"; //PASS IN FILE NAME
//    NSString *videoInputFilePath = [Utilities documentsPath:videoInputFileName];
//    NSURL *videoInputFileURL = [NSURL fileURLWithPath:videoInputFilePath];
//    
//    NSString *outputFileName = @"outputfileName"; //PASS IN FILE NAME
//    NSString *outputFilePath = [Utilities documentsPath:outputFileName];
//    NSURL *outputFileURL = [NSURL fileURLWithPath:outputFilePath];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
//        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
//    
//    CMTime nextClipStartTime = kCMTimeZero;
//    
//    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputFileURL options:nil];
//    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
//    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
//    
//    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputFileURL options:nil];
//    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
//    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
//    
//    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//    assetExport.outputFileType = @"com.apple.quicktime-movie";
//    assetExport.outputURL = outputFileURL;
//    
//    [assetExport exportAsynchronouslyWithCompletionHandler:^(void) {
//        [self saveVideoToAlbum:outputFilePath];
//    }];
//}


- (void)viewMovieAtUrl:(NSURL *)fileURL
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [playerController.view setFrame:self.view.bounds];
    [self presentMoviePlayerViewControllerAnimated:playerController];
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    [self.view addSubview:playerController.view];
}

- (void)playCapture:(NSURL *)videoURL
{
//    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mov"];
//    NSLog(@"%@", filePath);
//    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self.player.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:self.player];
    self.player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.player.moviePlayer.shouldAutoplay = YES;
    [self.player.moviePlayer setFullscreen:YES animated:NO];
    self.player.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.player.moviePlayer play];
    
    NSLog(@"endPlayingMovie");
}




#pragma mark - FlowMo Scrubbing Methods

- (IBAction)sliderValueChanged:(UISlider *)imageSlider {
   
    NSInteger currentImageIndex = (self.imageSlider.value);
    //NSLog(@"currentimageindex %f", self.imageSlider.value);
    //self.sliderImage = [self.imageArray objectAtIndex:currentImageIndex];
    //[self.imageView setImage:[self.imageArray objectAtIndex:currentImageIndex]];
    //create local instance of imageview
    UIImage *localImage = [self.imageArray objectAtIndex:currentImageIndex];
    self.sliderImage = localImage;
    [self.imageView setImage:localImage];
    
//    if (ScratchModeOn == YES) {
//        [self scratchModeTimer];
//    }
}

-(IBAction)forwardButtonLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.forwardButtonTimer invalidate];
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"BEGAN");
        [self forwardTimer];
    }
}

- (void)forwardTimer {
    
        self.forwardButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.03333333 //WILL PLAY AT 30 FPS
                                                                   target:self
                                                                 selector:@selector(sliderValueForward)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
}

-(void)sliderValueForward {
    [self.imageSlider setValue:self.imageSlider.value+1];
    [self sliderValueChanged:(UISlider *)self.imageSlider];
}

-(IBAction)backwardButtonLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.backwardButtonTimer invalidate];
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        [self backwardTimer];
    }
}

-(void)backwardTimer {
    self.backwardButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.03333333 //WILL PLAY AT 30 FPS
                                                               target:self
                                                             selector:@selector(sliderValueBackward)
                                                             userInfo:nil
                                                              repeats:YES];

}

-(void)sliderValueBackward {
    [self.imageSlider setValue:self.imageSlider.value-1];
    [self sliderValueChanged:(UISlider *)self.imageSlider];
}

#pragma mark - Save to CameraRoll Methods

-(void) saveVideoToCameraRoll {
   
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library writeVideoAtPathToSavedPhotosAlbum:self.outputURL
                                    completionBlock:^(NSURL *assetURL, NSError *error)
         {
             UIAlertView *alert;
             if (!error)
             {
                 alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
                                                    message:@"The movie was successfully saved to your photos library"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
             }
             else
             {
                 alert = [[UIAlertView alloc] initWithTitle:@"Error Saving Video"
                                                    message:@"The movie was not saved to your photos library"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
             }
             
             [alert show];
             
             
         }
         ];
    
    
}

-(void)saveImageFromImageArray {
    NSLog(@"save Image");
    //    [UIPasteboard generalPasteboard].image = self.sliderImage;
    NSLog(@"%@", self.sliderImage);
    UIImageWriteToSavedPhotosAlbum(self.sliderImage, nil, nil, nil);
    
    CATextLayer *savedText = [CATextLayer layer];
    [savedText setFont:@"Helvetica-Bold"];
    [savedText setFontSize:16];
    [savedText setFrame:CGRectMake(self.view.frame.size.width-76,self.view.frame.size.height-80,78,25)];
    [savedText setString:@"SAVED!"];
    //savedText.backgroundColor = [UIColor grayColor].CGColor;
    savedText.opacity = 1;
    [savedText setAlignmentMode:kCAAlignmentCenter];
    [savedText setForegroundColor:[[UIColor whiteColor] CGColor]];
    //savedText.frame = CGRectMake(0,300,self.view.frame.size.width,100);
    [self.view.layer addSublayer:savedText];
    //[savedText setHidden:YES];
    
    CABasicAnimation *fadeInAndOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 0.5;
    fadeInAndOut.autoreverses = YES;
    fadeInAndOut.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAndOut.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAndOut.repeatCount = 0;
    fadeInAndOut.fillMode = kCAFillModeBoth;
    fadeInAndOut.removedOnCompletion = NO;
    [savedText addAnimation:fadeInAndOut forKey:@"myanimation"];
}

#pragma mark - Facebook Messenger Methods
-(void) addMessengerButton {
    CGFloat buttonWidth = 50;
    self.facebookButton = [FBSDKMessengerShareButton circularButtonWithStyle:FBSDKMessengerShareButtonStyleWhite
                                                                    width:buttonWidth];
    
    self.facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.facebookButton addTarget:self action:@selector(SendImageWithMessenger) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.facebookButton];
    [self facebookButtonConstraints];
    
}

-(void) SendImageWithMessenger {
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        NSInteger currentImageIndex = (self.imageSlider.value);
        UIImage *image = [self.imageArray objectAtIndex:currentImageIndex];
        FixImageOrientation *fixOrientation = [[FixImageOrientation alloc] init];
        UIImage *rotatedImage = [fixOrientation scaleAndRotateImage:image];
         //[self scaleAndRotateImage:image];
        // UIImage *image = [UIImage imageNamed:@"selfie_pic"];
        
        [FBSDKMessengerSharer shareImage:rotatedImage withOptions:nil];
    }
}


#pragma mark - Helper Methods
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

-(void)firstRunCheck
{
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![[defaults objectForKey:@"hasImageArrayTutorialRun"]isEqualToString:@"YES"])
    //if(![[defaults objectForKey:@"firstRun1"]isEqualToString:@"NO"])
    {
        self.saveButton.hidden = YES;
        [self imageArrayTutorial];
        
    } else {
        
    }
}


#pragma mark - Back to Camera

-(void)returnToCamera {
    
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Inactive Methods

- (IBAction)sliderTap:(UIGestureRecognizer *)sliderTap {
    NSInteger currentImageIndex = (self.imageSlider.value);
    
    [self.imageView setImage:[self.imageArray objectAtIndex:currentImageIndex]];
}



#pragma mark AutoLayout Constraints

-(void)imageSliderConstraints {
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageSlider
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageSlider
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageSlider
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
}

-(void)facebookButtonConstraints {
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"facebookButton":self.facebookButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @50,
                               @"buttonWidth": @50,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@15};
    
    
    // 2. Define the redView Size
    NSArray *facebookButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[facebookButton(buttonHeight)]"
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:viewsDictionary];
    
    NSArray *facebookButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[facebookButton(buttonWidth)]"
                                                                              options:0
                                                                              metrics:metrics                                                                      views:viewsDictionary];
    [self.facebookButton addConstraints:facebookButtonConstraint_H];
    [self.facebookButton addConstraints:facebookButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *facebookButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[facebookButton]-verticalConstraint-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:viewsDictionary];
    
    NSArray *facebookButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[facebookButton]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:viewsDictionary];
    [self.view addConstraints:facebookButtonConstraint_POS_H];
    [self.view addConstraints:facebookButtonConstraint_POS_V];
}


-(void)saveButtonConstraints {
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"saveButton":self.saveButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @35,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@15};
    
    
    // 2. Define the redView Size
    NSArray *saveButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[saveButton(buttonHeight)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    NSArray *saveButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[saveButton(buttonWidth)]"
                                                                             options:0
                                                                             metrics:metrics                                                                      views:viewsDictionary];
    [self.saveButton addConstraints:saveButtonConstraint_H];
    [self.saveButton addConstraints:saveButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *saveButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[saveButton]-verticalConstraint-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
    
    NSArray *saveButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[saveButton]-horizontalConstraint-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
    [self.view addConstraints:saveButtonConstraint_POS_H];
    [self.view addConstraints:saveButtonConstraint_POS_V];
}

-(void)tutorialSliderViewConstraints {
    
    float height = self.view.frame.size.height*0.078125;
    float verticalConstraint = self.view.frame.size.height*0.07291667;
    NSLog(@"height %f", height);
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"tutorialSliderView":self.tutorialSliderView};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": [NSNumber numberWithFloat:(height)],
                               @"buttonWidth": @276,
                               @"verticalConstraint": [NSNumber numberWithFloat:(verticalConstraint)],
                               @"horizontalConstraint":@20};
    
    
    // 2. Define the redView Size
    NSArray *tutorialSliderViewConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tutorialSliderView(buttonHeight)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];
    
    NSArray *tutorialSliderViewConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[tutorialSliderView(buttonWidth)]"
                                                                                options:0
                                                                                metrics:metrics                                                                      views:viewsDictionary];
    [self.tutorialSliderView addConstraints:tutorialSliderViewConstraint_H];
    [self.tutorialSliderView addConstraints:tutorialSliderViewConstraint_V];
    
    // 3. Define the redView Position
    NSArray *tutorialSliderViewConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tutorialSliderView]-verticalConstraint-|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    
    NSArray *tutorialSliderViewConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[tutorialSliderView]"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    [self.view addConstraints:tutorialSliderViewConstraint_POS_H];
    [self.view addConstraints:tutorialSliderViewConstraint_POS_V];
}


-(void)cancelButtonConstraints {
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"cancelButton":self.cancelButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @35,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @15,
                               @"horizontalConstraint":@10};
    
    
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
    NSArray *cancelButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalConstraint-[cancelButton]"
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

-(void)videoPlayerButtonConstraints {
    NSLog(@"videoPlayer Button Constraints!");
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"videoPlayerButton":self.videoPlayerButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @50,
                               @"buttonWidth": @50,
                               @"verticalConstraint": @10,
                               @"horizontalConstraint":@10};
    
    
    // 2. Define the redView Size
    NSArray *videoPlayerButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[videoPlayerButton(buttonHeight)]"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:viewsDictionary];
    
    NSArray *videoPlayerButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[videoPlayerButton(buttonWidth)]"
                                                                                    options:0
                                                                                    metrics:metrics                                                                      views:viewsDictionary];
    [self.videoPlayerButton addConstraints:videoPlayerButtonConstraint_H];
    [self.videoPlayerButton addConstraints:videoPlayerButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *videoPlayerButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[videoPlayerButton]-verticalConstraint-|"
                                                                                        options:0
                                                                                        metrics:metrics
                                                                                          views:viewsDictionary];
    
    NSArray *videoPlayerButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[videoPlayerButton]"
                                                                                        options:0
                                                                                        metrics:metrics
                                                                                          views:viewsDictionary];
    [self.view addConstraints:videoPlayerButtonConstraint_POS_H];
    [self.view addConstraints:videoPlayerButtonConstraint_POS_V];
}

-(void)forwardButtonConstraints {
    NSLog(@"forward Button Constraints!");
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"forwardButton":self.forwardButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @35,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@172};
    
    
    // 2. Define the redView Size
    NSArray *forwardButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[forwardButton(buttonHeight)]"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    
    NSArray *forwardButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[forwardButton(buttonWidth)]"
                                                                                     options:0
                                                                                     metrics:metrics                                                                      views:viewsDictionary];
    [self.forwardButton addConstraints:forwardButtonConstraint_H];
    [self.forwardButton addConstraints:forwardButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *forwardButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[forwardButton]-verticalConstraint-|"
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:viewsDictionary];
    
    NSArray *forwardButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[forwardButton]"
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:viewsDictionary];
    [self.view addConstraints:forwardButtonConstraint_POS_H];
    [self.view addConstraints:forwardButtonConstraint_POS_V];
}

-(void)backwardButtonConstraints {
    NSLog(@"backward Button Constraints!");
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"backwardButton":self.backwardButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @35,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@104};
    
    
    // 2. Define the redView Size
    NSArray *backwardButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[backwardButton(buttonHeight)]"
                                                                                 options:0
                                                                                 metrics:metrics
                                                            views:viewsDictionary];
    
    NSArray *backwardButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[backwardButton(buttonWidth)]"
                                                                                 options:0
                                                                                 metrics:metrics                                                                      views:viewsDictionary];
    [self.backwardButton addConstraints:backwardButtonConstraint_H];
    [self.backwardButton addConstraints:backwardButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *backwardButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[backwardButton]-verticalConstraint-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    
    NSArray *backwardButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[backwardButton]"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    [self.view addConstraints:backwardButtonConstraint_POS_H];
    [self.view addConstraints:backwardButtonConstraint_POS_V];
}

-(void)scratchModeButtonConstraints {
    NSLog(@"scratchMode Button Constraints!");
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"scratchModeButton":self.scratchModeButton};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @53,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@10};
    
    
    // 2. Define the redView Size
    NSArray *scratchModeButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[scratchModeButton(buttonHeight)]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:viewsDictionary];
    
    NSArray *scratchModeButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[scratchModeButton(buttonWidth)]"
                                                                                  options:0
                                                                                  metrics:metrics                                                                      views:viewsDictionary];
    [self.scratchModeButton addConstraints:scratchModeButtonConstraint_H];
    [self.scratchModeButton addConstraints:scratchModeButtonConstraint_V];
    
    // 3. Define the redView Position
    NSArray *scratchModeButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[scratchModeButton]-verticalConstraint-|"
                                                                                      options:0
                                                                                      metrics:metrics
                                                                                        views:viewsDictionary];
    
    NSArray *scratchModeButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalConstraint-[scratchModeButton]"
                                                                                      options:0
                                                                                      metrics:metrics
                                                                                        views:viewsDictionary];
    [self.view addConstraints:scratchModeButtonConstraint_POS_H];
    [self.view addConstraints:scratchModeButtonConstraint_POS_V];
}

-(void)scratchModeIconViewConstraints {
    NSLog(@"scratchMode Button Constraints!");
    
    // 1. Create a dictionary of views
    NSDictionary *viewsDictionary = @{@"scratchModeIconView":self.scratchModeIconView};
    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
    NSDictionary *metrics = @{ @"buttonHeight": @53,
                               @"buttonWidth": @44,
                               @"verticalConstraint": @20,
                               @"horizontalConstraint":@10};
    
    
    // 2. Define the redView Size
    NSArray *scratchModeIconViewConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[scratchModeIconView(buttonHeight)]"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:viewsDictionary];
    
    NSArray *scratchModeIconViewConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[scratchModeIconView(buttonWidth)]"
                                                                                     options:0
                                                                                     metrics:metrics                                                                      views:viewsDictionary];
    [self.scratchModeIconView addConstraints:scratchModeIconViewConstraint_H];
    [self.scratchModeIconView addConstraints:scratchModeIconViewConstraint_V];
    
    // 3. Define the redView Position
    NSArray *scratchModeIconViewConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalConstraint-[scratchModeIconView]"
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:viewsDictionary];
    
    NSArray *scratchModeIconViewConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[scratchModeIconView]-horizontalConstraint-|"
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:viewsDictionary];
    [self.view addConstraints:scratchModeIconViewConstraint_POS_H];
    [self.view addConstraints:scratchModeIconViewConstraint_POS_V];
}


#pragma mark - Tutorial Methods
-(void)imageArrayTutorial {
    
    self.tutorialSliderArray = [[NSMutableArray alloc] initWithCapacity:90];
    
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider1.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider1.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider1.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider1.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider2.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider2.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider2.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider2.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider3.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider3.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider3.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider3.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider4.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider4.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider4.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider4.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider5.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider5.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider5.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider6.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider6.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider6.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider6.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider7.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider7.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider7.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider7.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider8.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider8.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider8.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider8.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider9.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider9.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider9.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider10.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider10.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider10.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider11.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider11.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider11.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider11.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider12.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider12.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider12.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider13.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider13.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider13.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider14.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider14.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider14.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider14.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider15.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider15.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider16.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider16.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider16.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider16.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider17.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider17.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider17.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider18.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider18.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider18.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider18.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider19.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider19.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider19.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider19.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider19.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider20.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider20.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider20.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider21.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider21.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider21.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider21.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider22.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider22.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider22.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlider22.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialSliderArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    
    self.tutorialArray = [[NSMutableArray alloc] init];
    
    
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-13.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-15.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide7-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-13.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-15.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide8-16.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide15-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide16-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-1.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-2.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-3.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-4.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-5.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-6.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-7.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-8.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-9.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-10.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-11.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-12.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-13.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide17-14.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    
    
    NSLog(@"tutorialarray count %lul", (unsigned long)self.tutorialArray.count);
    NSLog(@"tutorialSliderarray count %lul", (unsigned long)self.tutorialSliderArray.count);
    
    self.tutorialLayer = self.view.layer;
    self.sublayer = [CALayer layer];
    self.sublayer.backgroundColor = [UIColor whiteColor].CGColor;
    float yVal = self.view.frame.size.height*0.15;
    float hVal = self.view.frame.size.height*0.69;
    CGFloat yValue = yVal;
    CGFloat heightValue = hVal;
    NSLog(@"yValue %f", yValue);
    NSLog(@"heightValue %f", heightValue);
    self.sublayer.opacity = 0.4;
    self.sublayer.frame = CGRectMake(5, yValue, self.view.frame.size.width-10, heightValue);
    
    self.tutorialView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialSlideCLEAR.png"]];
    self.tutorialView.contentMode =  UIViewContentModeScaleAspectFill;
    self.tutorialView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    self.tutorialView.backgroundColor = [UIColor clearColor];
    self.tutorialView.alpha = 1;
    [self.tutorialView setUserInteractionEnabled:TRUE];
    
    self.tutorialSliderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialSlider1.png"]];
    
    //self.tutorialSliderView.frame = CGRectMake(20,446,278,45);
    self.tutorialSliderView.backgroundColor = [UIColor clearColor];
    self.tutorialSliderView.alpha = 1;
    [self.tutorialSliderView setUserInteractionEnabled:TRUE];
    self.tutorialSliderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLog(@"tutorialSliderView image %@", self.tutorialSliderView.image);
    
    self.tutorialSlider = [[ImageSlider alloc]init];
    UIImage *clearImage = [[UIImage alloc]init]; // Init blank UIImage
    [self.tutorialSlider setThumbImage:clearImage forState:UIControlStateNormal];
    [self.tutorialSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
    [self.tutorialSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
    self.tutorialSlider.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 0);
    self.tutorialSlider.minimumValue = 0.0;
    self.tutorialSlider.maximumValue = self.tutorialSliderArray.count-1;
    self.tutorialSlider.continuous = YES;
    self.tutorialSlider.value = 0.0;
    [self.tutorialSlider addTarget:self action:@selector(tutorialSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tutorialCancelButton = [[UIButton alloc]init];
    self.tutorialCancelButton.frame = CGRectMake(10, 20, 132, 30);
    [self.tutorialCancelButton setImage:[UIImage imageNamed:@"skipTutorialButton.png"] forState:UIControlStateNormal];
    [self.tutorialCancelButton addTarget:self action:@selector(dismissTutorial) forControlEvents:UIControlEventTouchDown];
    
    
    [self.view addSubview:self.tutorialSliderView];
    [self tutorialSliderViewConstraints];
    [self.view addSubview:self.tutorialView];
    [self.view addSubview:self.tutorialSlider];
    [self.tutorialLayer insertSublayer:self.sublayer2 below:self.tutorialView.layer];
    [self.tutorialLayer insertSublayer:self.sublayer3 below:self.tutorialView.layer];
    
}

-(IBAction)tutorialSliderValueChanged:(UISlider *)tutorialSlider
{
    
    NSInteger currentImageIndex = (self.tutorialSlider.value);
    NSLog(@"CII %ld", (long)currentImageIndex);
    [self.tutorialView setImage:[self.tutorialArray objectAtIndex:currentImageIndex]];
    [self.tutorialSliderView setImage:[self.tutorialSliderArray objectAtIndex:currentImageIndex]];
    
    
    if(currentImageIndex >= 10) {
        [self.view addSubview:self.tutorialCancelButton];
    }
    if(currentImageIndex <= 1) {
        [self.sublayer removeFromSuperlayer];
    }
    if(currentImageIndex >= 1) {
    }
    if((currentImageIndex >= 2) && (currentImageIndex <= 17))  {
        [self.tutorialLayer insertSublayer:self.sublayer below:self.tutorialView.layer];
    }
    
    if(currentImageIndex <= 47){
        self.saveButton.hidden = YES;
    }
    if(currentImageIndex >= 47)
    {
        self.saveButton.hidden = NO;
    }
    if(currentImageIndex >= 78)
    {
        [self dismissTutorial];
    }
}

-(void)dismissTutorial {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"hasImageArrayTutorialRun"];
    
    self.saveButton.hidden = NO;
    [self.tutorialView removeFromSuperview];
    [self.tutorialSliderView removeFromSuperview];
    [self.tutorialSlider removeFromSuperview];
    [self.tutorialCancelButton removeFromSuperview];
    [self.tutorialSliderArray removeAllObjects];
    [self.tutorialArray removeAllObjects];
    [self.sublayer removeFromSuperlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
