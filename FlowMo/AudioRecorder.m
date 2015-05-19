//
//  AudioRecorder.m
//  FlowMo
//
//  Created by Bryan Ryczek on 5/10/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "AudioRecorder.h"

@implementation AudioRecorder

- (void)recorderSetup
{
    
    NSLog(@"RECORDER SETUP!");
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor grayColor];
//    [stopButton setEnabled:NO];
//    [playButton setEnabled:NO];
    
    //setup audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    
    NSURL *audioOutputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    //setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil]; //Signifies that we will both record and playback audio from the session. Also sets playback speaker as "External" Speakers
    
    //AVAudioRecorder uses dictionary-based settings for its configuration
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    //init the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:audioOutputFileURL settings:recordSetting error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
  //  [self addRecordPauseButton];
 //   [self addStopButton];
  //  [self addPlayButton];
    
}


- (void) recordPauseTapped {
    NSLog(@"RECORD-PAUSE");
    if (self.player.playing) {
        [self.player stop];
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        
        //Start recording
        [self.recorder record];
 //       [self.recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        //Pause Recording
        [self.recorder pause];
//        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
 //   [stopButton setEnabled:YES];
 //   [playButton setEnabled:NO];
}

- (void) stopRecording {
    [self.recorder stop];
//    ImageArrayPreview *imageArrayPreview = [[ImageArrayPreview alloc]init];
//    imageArrayPreview.audioURL = self.recorder.url;
//    NSLog(@"%@", imageArrayPreview.audioURL);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void) playTapped {
    if (!self.recorder.recording) {
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self]; //HANDLES INTERRUPTIONS & THE PLAYBACK COMPLETED EVENT
        [self.player play];    }
}

#pragma mark - Delegate Methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
//    
//    [stopButton setEnabled:NO];
//    [playButton setEnabled:YES];
}

//-(void) addRecordPauseButton {
//    self.recordPauseButton = [[UIButton alloc]init];
//    self.recordPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.recordPauseButton setImage:[UIImage imageNamed:@"frameForward.png"] forState:UIControlStateNormal];
//    [self.recordPauseButton addTarget:self action:@selector(recordPauseTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.recordPauseButton];
//    [self recordPauseButtonConstraints];
//
//}

//-(void) addStopButton {
//    self.stopButton = [[UIButton alloc]init];
//    self.stopButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.stopButton setImage:[UIImage imageNamed:@"backToCamera.png"] forState:UIControlStateNormal];
//    [self.stopButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.stopButton];
//    [self stopButtonConstraints];
//
//}

//-(void) addPlayButton {
//    self.playButton = [[UIButton alloc]init];
//    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.playButton setImage:[UIImage imageNamed:@"scratchModeIcon.png"] forState:UIControlStateNormal];
//    [self.playButton addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.playButton];
//    [self playButtonConstraints];
//
//}


//- (void) recordPauseButtonConstraints {
//    
//    // 1. Create a dictionary of views
//    NSDictionary *viewsDictionary = @{@"recordPauseButton":self.recordPauseButton};
//    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
//    NSDictionary *metrics = @{ @"buttonHeight": @35,
//                               @"buttonWidth": @44,
//                               @"verticalConstraint": @20,
//                               @"horizontalConstraint":@15};
//    
//    
//    // 2. Define the redView Size
//    NSArray *recordPauseButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recordPauseButton(buttonHeight)]"
//                                                                                     options:0
//                                                                                     metrics:metrics
//                                                                                       views:viewsDictionary];
//    
//    NSArray *recordPauseButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[recordPauseButton(buttonWidth)]"
//                                                                                     options:0
//                                                                                     metrics:metrics                                                                      views:viewsDictionary];
//    [self.recordPauseButton addConstraints:recordPauseButtonConstraint_H];
//    [self.recordPauseButton addConstraints:recordPauseButtonConstraint_V];
//    
//    // 3. Define the redView Position
//    NSArray *recordPauseButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recordPauseButton]-verticalConstraint-|"
//                                                                                         options:0
//                                                                                         metrics:metrics
//                                                                                           views:viewsDictionary];
//    
//    NSArray *recordPauseButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[recordPauseButton]-horizontalConstraint-|"
//                                                                                         options:0
//                                                                                         metrics:metrics
//                                                                                           views:viewsDictionary];
//    [self.view addConstraints:recordPauseButtonConstraint_POS_H];
//    [self.view addConstraints:recordPauseButtonConstraint_POS_V];
//    
//}
//
//- (void) playButtonConstraints {
//    
//    // 1. Create a dictionary of views
//    NSDictionary *viewsDictionary = @{@"playButton":self.playButton};
//    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
//    NSDictionary *metrics = @{ @"buttonHeight": @35,
//                               @"buttonWidth": @44,
//                               @"verticalConstraint": @20,
//                               @"horizontalConstraint":@115};
//    
//    
//    // 2. Define the redView Size
//    NSArray *playButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[playButton(buttonHeight)]"
//                                                                              options:0
//                                                                              metrics:metrics
//                                                                                views:viewsDictionary];
//    
//    NSArray *playButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[playButton(buttonWidth)]"
//                                                                              options:0
//                                                                              metrics:metrics                                                                      views:viewsDictionary];
//    [self.playButton addConstraints:playButtonConstraint_H];
//    [self.playButton addConstraints:playButtonConstraint_V];
//    
//    // 3. Define the redView Position
//    NSArray *playButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[playButton]-verticalConstraint-|"
//                                                                                  options:0
//                                                                                  metrics:metrics
//                                                                                    views:viewsDictionary];
//    
//    NSArray *playButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[playButton]-horizontalConstraint-|"
//                                                                                  options:0
//                                                                                  metrics:metrics
//                                                                                    views:viewsDictionary];
//    [self.view addConstraints:playButtonConstraint_POS_H];
//    [self.view addConstraints:playButtonConstraint_POS_V];
//    
//}
//
//- (void) stopButtonConstraints {
//    
//    // 1. Create a dictionary of views
//    NSDictionary *viewsDictionary = @{@"stopButton":self.stopButton};
//    // 1a. Create a metrics dictionary to be referenced in the constraint arrays
//    NSDictionary *metrics = @{ @"buttonHeight": @35,
//                               @"buttonWidth": @44,
//                               @"verticalConstraint": @20,
//                               @"horizontalConstraint":@215};
//    
//    
//    // 2. Define the redView Size
//    NSArray *stopButtonConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[stopButton(buttonHeight)]"
//                                                                              options:0
//                                                                              metrics:metrics
//                                                                                views:viewsDictionary];
//    
//    NSArray *stopButtonConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[stopButton(buttonWidth)]"
//                                                                              options:0
//                                                                              metrics:metrics                                                                      views:viewsDictionary];
//    [self.stopButton addConstraints:stopButtonConstraint_H];
//    [self.stopButton addConstraints:stopButtonConstraint_V];
//    
//    // 3. Define the redView Position
//    NSArray *stopButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[stopButton]-verticalConstraint-|"
//                                                                                  options:0
//                                                                                  metrics:metrics
//                                                                                    views:viewsDictionary];
//    
//    NSArray *stopButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[stopButton]-horizontalConstraint-|"
//                                                                                  options:0
//                                                                                  metrics:metrics
//                                                                                    views:viewsDictionary];
//    [self.view addConstraints:stopButtonConstraint_POS_H];
//    [self.view addConstraints:stopButtonConstraint_POS_V];
//    
//}


//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


@end
