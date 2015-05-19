//
//  AudioRecorder.h
//  FlowMo
//
//  Created by Bryan Ryczek on 5/10/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

//@property (strong, nonatomic) IBOutlet UIButton *recordPauseButton;
//@property (strong, nonatomic) IBOutlet UIButton *stopButton;
//@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSURL *audioURL;

- (void) recorderSetup;
- (void) recordPauseTapped;
- (void) stopRecording;
- (void) playTapped;

@end
