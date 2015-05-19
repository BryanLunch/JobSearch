//
//  Tutorial.m
//  FlowMo
//
//  Created by Bryan Ryczek on 2/20/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "Tutorial.h"

@interface Tutorial ()

@end

@implementation Tutorial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tutorialArray = [[NSMutableArray alloc] initWithCapacity:90];
    
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide1-1.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide1-2.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide1-3.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide1-4.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-1.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-2.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-3.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-4.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-5.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-6.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-7.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-8.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-9.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-10.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-11.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-12.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-13.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-14.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-15.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-16.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-17.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-18.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-19.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-20.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-21.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide2-22.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-1.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-2.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-3.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-4.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-5.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-6.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-7.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-8.png"]];
                          [self.tutorialArray addObject:[UIImage imageNamed:@"TutorialSlide3-9.png"]];
    
    NSLog(@"imagearray contents %@", self.tutorialArray);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageSlider = [[ImageSlider alloc]init];
    self.imageSlider.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 31);
    self.imageSlider.minimumValue = 0.0;
    self.imageSlider.maximumValue = self.tutorialArray.count;
    self.imageSlider.continuous = YES;
    self.imageSlider.value = 0.0;
    [self.imageSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventAllTouchEvents];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    //self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.alpha = 1.0;
    self.sliderImage = [self.tutorialArray objectAtIndex:0];

    self.cancelButton = [[UIButton alloc]init];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setImage:[UIImage imageNamed:@"xIconWhite50x50.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(returnToCamera) forControlEvents:UIControlEventTouchUpInside];
    

    double delayInSeconds = .01; //Design Flaw: Without delay image array will not load properly.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.imageView setImage:[self.tutorialArray objectAtIndex:0]];
        [self.view addSubview:self.imageSlider];
        [self.view addSubview:self.imageView];
        [self.view addSubview:self.cancelButton];
        //[self.view addSubview:self.tutorialTextView];
        [self cancelButtonConstraints];
    });

}

-(void)returnToCamera {
    [[self presentingViewController]dismissViewControllerAnimated:NO completion:nil];
    }
                   
- (IBAction)sliderValueChanged:(UISlider *)imageSlider {
    
//    self.tutorialText = [[NSMutableArray alloc]init];
//    [self.tutorialText addObject:@"WELCOME"];
//    [self.tutorialText addObject:@"WELCOME TO"];
//    [self.tutorialText addObject:@"WELCOME TO FlowMo"];
//    [self.tutorialText addObject:@"FlowMo"];
//    [self.tutorialText addObject:@"FlowMo IS A"];
//    [self.tutorialText addObject:@"FlowMo IS A FUN WAY"];
//    [self.tutorialText addObject:@"TO CAPTURE GREAT PHOTOS!"];
//    [self.tutorialText addObject:@"TO CAPTURE GREAT PHOTOS!*"];
//    [self.tutorialText addObject:@"TO CAPTURE GREAT PHOTOS!* \n *More coming soon!"];
//    [self.tutorialText addObject:@"11"];
//    [self.tutorialText addObject:@"12"];
//    [self.tutorialText addObject:@"13"];
//    [self.tutorialText addObject:@"14"];
    
    NSInteger currentImageIndex = (self.imageSlider.value);
    //Change image with SliderValueChange
   
    //self.imageView.image = [self.tutorialArray objectAtIndex:currentImageIndex];
    [self.imageView setImage:[self.tutorialArray objectAtIndex:currentImageIndex]];
    //NSLog(@"sliderValueChanged %f", self.imageSlider.value);
    
    //Change text with TextValueChange
    self.tutorialTextView.text = [self.tutorialText objectAtIndex:currentImageIndex];
    [self.tutorialTextView setText:[self.tutorialText objectAtIndex:currentImageIndex]];
    NSLog(@"textChanged %@", self.tutorialTextView.text);
}

-(void)cancelButtonConstraints {
                       
                       // 1. Create a dictionary of views
                       NSDictionary *viewsDictionary = @{@"cancelButton":self.cancelButton};
                       // 1a. Create a metrics dictionary to be referenced in the constraint arrays
                       NSDictionary *metrics = @{ @"buttonHeight": @30,
                                                  @"buttonWidth": @30,
                                                  @"verticalConstraint": @20,
                                                  @"horizontalConstraint":@15};
                       
                       
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
    
                        //3. Define the redView Position
                       NSArray *cancelButtonConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalConstraint-[cancelButton]"
                                                                                                       options:0
                                                                                                       metrics:metrics
                                                                                                         views:viewsDictionary];
                       
                       NSArray *cancelButtonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancelButton]-horizontalConstraint-|"
                                                                                                       options:0
                                                                                                       metrics:metrics
                                                                                                         views:viewsDictionary];
                      [self.view addConstraints:cancelButtonConstraint_POS_H];
                      [self.view addConstraints:cancelButtonConstraint_POS_V];
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
