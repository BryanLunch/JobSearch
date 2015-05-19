//
//  FlowMoCapture.h
//  FlowMo
//
//  Created by Bryan Ryczek on 2/10/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AppDelegate.h"
#import "CircleProgressView.h"
#import "Session.h"
#import "ImageArrayPreview.h"
#import "Tutorial.h"
#import "ImageSlider.h"


@interface FlowMoCapture : UIViewController <UIGestureRecognizerDelegate, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate>
{
@public
    BOOL tutorialActivate;
}



@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *movieArray;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *switchCamera;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *uploadVideoButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
//@property (strong, nonatomic) NSTimer *timer; //For progress view
//@property (nonatomic, strong) DACircularProgressView *progressView;
//@property (strong, nonatomic) NSTimer *processingTimer; // for image processing timer
//@property (nonatomic, strong) DACircularProcessingView *processingView;

@property (strong, nonatomic) CircleProgressView *captureCircle;
@property (strong, nonatomic) NSTimer *captureCircleTimer;
@property (nonatomic, strong) Session *captureCircleSession;

@property (strong, nonatomic) CircleProgressView *processingCircle;
@property (strong, nonatomic) NSTimer *processingCircleTimer;
@property (nonatomic, strong) Session *processingCircleSession;

@property (readwrite, nonatomic) CGFloat processingSplit;
//TUTORIAL
@property (strong, nonatomic) ImageSlider *tutorialSlider;//
@property (strong, nonatomic) UIImageView *tutorialView;//
@property (strong, nonatomic) UIImageView *tutorialSlideGraphicView;
@property (nonatomic, strong) NSMutableArray *tutorialArray;//
@property (nonatomic, strong) NSMutableArray *tutorialSlideGraphic;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) CALayer *tutorialLayer;
@property (strong, nonatomic) CALayer *flashLayer;
@property (strong, nonatomic) CALayer *sublayer;
@property (strong, nonatomic) CALayer *sublayer1;
@property (strong, nonatomic) CALayer *sublayer2;





-(IBAction)capture:(id)sender;

@end
