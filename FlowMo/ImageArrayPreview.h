//
//  ImageArrayPreview.h
//  FlowSelect
//
//  Created by Bryan Ryczek on 1/27/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FlowMoCapture.h"
#import "ImageSlider.h"
#import "CEMovieMaker.h"
#import "AudioRecorder.h"
#import "FixImageOrientation.h"


@interface ImageArrayPreview : UIViewController <UIGestureRecognizerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) ImageSlider *imageSlider;
@property (strong, nonatomic) AudioRecorder *audioRecorder;

@property (nonatomic, weak) NSMutableArray *imageArray;
@property (nonatomic, weak) NSMutableArray *movieArray;
//@property (weak, nonatomic) IBOutlet UISlider *imageSlider;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *videoPlayerButton;
@property (strong, nonatomic) UIImage *sliderImage;
@property (nonatomic, strong) MPMoviePlayerViewController *player;

@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *backwardButton;
@property (strong, nonatomic) NSTimer *forwardButtonTimer;
@property (strong, nonatomic) NSTimer *backwardButtonTimer;
@property (strong, nonatomic) UIButton *scratchModeButton;

@property (assign) float scratchModeX;

//FACEBOOK
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIImage *facebookImage;


//SCRATCH MODE!
@property (strong, nonatomic) NSMutableArray *scratchModeArray;
@property (strong, nonatomic) NSTimer *scratchModeTimer;
@property (strong, nonatomic) NSTimer *stopScratchModeTimer;
@property (strong, nonatomic) UILongPressGestureRecognizer *scratchModeLongPress;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *AudioPlayer;
@property (strong, nonatomic) UIImageView *scratchModeIconView;
//SCRATCH MODE MOVIE MAKER
@property (strong, nonatomic) CEMovieMaker *movieMaker;
@property (strong, nonatomic) NSURL *audioURL;


//TUTORIAL
@property (strong, nonatomic) ImageSlider *tutorialSlider;
@property (strong, nonatomic) UIImageView *tutorialSliderView;
@property (strong, nonatomic) UIImageView *tutorialView;
@property (nonatomic, strong) NSMutableArray *tutorialArray;
@property (nonatomic, strong) NSMutableArray *tutorialSliderArray;
@property (strong, nonatomic) UIButton *tutorialCancelButton;
@property (strong, nonatomic) CALayer *tutorialLayer;
@property (strong, nonatomic) CALayer *sublayer;
@property (strong, nonatomic) CALayer *sublayer1;
@property (strong, nonatomic) CALayer *sublayer2;
@property (strong, nonatomic) CALayer *sublayer3;
@property (strong, nonatomic) CALayer *sublayer4;

-(UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
