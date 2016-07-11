//
//  RecordButton.h
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordButtonDelegate <NSObject>

-(void)recordButtonDidTouchDown;
-(void)recordButtonDidMove:(CGPoint)point;
-(void)recordButtonDidEnded:(CGPoint)point;

@end

@interface RecordButton : UIButton
- (void)startAnimation:(BOOL)top;
@property (nonatomic,weak) id<RecordButtonDelegate> delegate;
@end
