//
//  OEProgressView.m
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import "OEProgressView.h"
#define OEScreenWidth ([UIScreen mainScreen].bounds.size.width)
@implementation OEProgressView

- (void)startCompletion:(void (^ __nullable)(BOOL finished))completion {
    
    //动画有显示 视觉不同步
    [UIView animateWithDuration:self.duration-0.5 animations:^{
        self.bounds = CGRectMake(0, 0, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        completion(finished);
        self.bounds = CGRectMake(0, 0, OEScreenWidth, self.frame.size.height);
        
    }];
    
}
- (void)resume {
   self.bounds = CGRectMake(0, 0, OEScreenWidth, self.frame.size.height);
}

@end
