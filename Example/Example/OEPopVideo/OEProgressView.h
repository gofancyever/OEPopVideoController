//
//  OEProgressView.h
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OEProgressView : UIView

@property (nonatomic,assign) NSTimeInterval duration;

- (void)startCompletion:(void (^ __nullable)(BOOL finished))completion;

- (void)resume;

@end

