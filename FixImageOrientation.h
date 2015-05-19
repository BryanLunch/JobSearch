//
//  FixImageOrientation.h
//  FlowMo
//
//  Created by Bryan Ryczek on 5/13/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FixImageOrientation : NSObject

- (UIImage *) scaleAndRotateImage: (UIImage *) imageIn;

@end
