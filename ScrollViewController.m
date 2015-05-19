//
//  ScrollViewController.m
//  FlowMo
//
//  Created by Bryan Ryczek on 4/30/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "ScrollViewController.h"
#import "FlowMoCapture.h"

@interface ScrollViewController ()

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
//    NSInteger numberOfViews = 2;
//    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
//    scrollView.pagingEnabled = YES;
//    
//    FlowMoCapture *flowMoCapture = [[FlowMoCapture alloc] init];
//    [self addChildViewController:flowMoCapture];
//    [scrollView addSubview:flowMoCapture.view];
//    [flowMoCapture didMoveToParentViewController:self];
//    
//    AddFriendsViewController *friendsViewController = [[AddFriendsViewController alloc]init];
//    //CViewController *cViewController = [[CViewController alloc]init];
//    CGRect frame = friendsViewController.view.frame;
//    frame.origin.x = 320;
//    friendsViewController.view.frame = frame;
//    [self addChildViewController:friendsViewController];
//    [scrollView addSubview:friendsViewController.view];
//    [friendsViewController didMoveToParentViewController:self];
    
//    UIView *cameraView = flowMoCapture.view;
//    UIView *addFriendsView = friendsViewController.view;
//    [scrollView addSubview:cameraView];
//    //[friendsView addSubview:nextView];
//    [scrollView addSubview:addFriendsView];
    
//   
//    for (int i = 0; i < numberOfViews; i++) {
//        CGFloat xOrigin = i * self.view.frame.size.width;
//        UIView *nextView = flowMoCapture.view;
//        nextView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
//        [scrollView addSubview:nextView];
//    }
    
    
//    [self.view addSubview:scrollView];

    // Do any additional setup after loading the view.
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
