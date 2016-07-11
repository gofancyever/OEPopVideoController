//
//  OETabbar.h
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/9.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OEProgressView;
typedef NS_ENUM(NSInteger, OEButtonType) {
    OEConvert,
    OEDismiss
};

@protocol OETabbarDelegate <NSObject>

- (void)tabbarButtonDidClick:(UIButton *)sender;
- (void)tabbarDidRecord;
- (void)tabbarDidRecordComplete;
- (void)tabbarDidCancelRecord;

@end

@interface OETabbar : UIView
@property (nonatomic,strong) OEProgressView *progressView;
@property (nonatomic,assign) NSTimeInterval progressDuration;
@property (nonatomic,weak)id<OETabbarDelegate> delegate;
- (void)progressResume;
- (void)progressStart;


@end
