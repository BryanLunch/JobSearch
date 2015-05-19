//
//  ImageSlider.m
//  FlowSelect
//
//  Created by Bryan Ryczek on 1/31/15.
//  Copyright (c) 2015 Bryan Ryczek. All rights reserved.
//

#import "ImageSlider.h"

#define THUMB_SIZE 100
#define EFFECTIVE_THUMB_SIZE 200

@implementation ImageSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -0, -568);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    float thumbPercent = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float thumbPos = THUMB_SIZE + (thumbPercent * (bounds.size.width - (2 * THUMB_SIZE)));
    CGPoint touchPoint = [touch locationInView:self];
    return (touchPoint.x >= (thumbPos - EFFECTIVE_THUMB_SIZE) &&
            touchPoint.x <= (thumbPos + EFFECTIVE_THUMB_SIZE));
}

//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"BEGAN");
//    //[ImageArrayPreview test];
//}
//
//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"MOVED");
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"ENDED");
//}
@end
