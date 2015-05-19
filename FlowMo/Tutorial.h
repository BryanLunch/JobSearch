//
//  Tutorial.h
//  FlowMo
//
//  Created by Bryan Ryczek on 2/20/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlowMoCapture.h"
#import "ImageSlider.h"


@interface Tutorial : UIViewController

//@property (nonatomic, strong) NSMutableArray *imageArray;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIImage *sliderImage;
@property (strong, nonatomic) ImageSlider *imageSlider;
@property (strong, nonatomic) UILabel *tutorialTextView;
@property (strong, nonatomic) NSMutableArray *tutorialText;
@property (nonatomic, strong) NSMutableArray *tutorialArray;

@end
