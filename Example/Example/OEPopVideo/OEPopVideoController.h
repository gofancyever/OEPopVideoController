//
//  OEPopVideoController.h
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol OEPopVideoControllerDelegate <NSObject>
- (void)popVideoControllerWillOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)popVideoControllerDidSave:(NSString *)url;
@end

@interface OEPopVideoController : NSObject

- (void)presentPopupControllerAnimated:(BOOL)flag;
- (void)dismissPopupControllerAnimated:(BOOL)flag;

@property (nonatomic,assign) NSTimeInterval videoMaxTime;
@property (nonatomic,weak) id<OEPopVideoControllerDelegate> delegate;

@end
