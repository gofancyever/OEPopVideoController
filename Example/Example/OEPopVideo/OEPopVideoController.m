//
//  OEPopVideoController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import "OEPopVideoController.h"
#import "GPUImage.h"



#import <objc/runtime.h>

#import "OETabbar.h"

#define OEScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define OEScreenHeight ([UIScreen mainScreen].bounds.size.width)
#define CNP_SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define CNP_IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define OEPathToMovie ([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie4.m4v"])


@interface OEPopVideoController()<OETabbarDelegate,GPUImageVideoCameraDelegate>

@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageView *filterView;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIWindow *applicationWindow;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;
@property (nonatomic,strong) OETabbar *tabbar;
@property (nonatomic,assign) NSTimeInterval nowTime;

@property (nonatomic) BOOL dismissAnimated;
@end

@implementation OEPopVideoController

- (UIWindow *)applicationWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

-(void)setVideoMaxTime:(NSTimeInterval)videoMaxTime {
    _videoMaxTime = videoMaxTime;
    if (videoMaxTime > 0){
        _nowTime = videoMaxTime;
        self.tabbar.progressDuration = self.videoMaxTime;
        
    }
}
- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
        [self setupCameraView];
        [self setupTabbar];
        [self setupPopupAnimation];
    }
    return self;
}
#pragma mark - setup
- (void)setupView {
    self.popupView = [[UIView alloc] initWithFrame:CGRectZero];
    self.popupView.backgroundColor = [UIColor whiteColor];
    self.popupView.clipsToBounds = YES;
    
    self.maskView = [[UIView alloc] initWithFrame:self.applicationWindow.bounds];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.backgroundTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGesture:)];
    //    self.backgroundTapRecognizer.delegate = self;
    [self.maskView addGestureRecognizer:self.backgroundTapRecognizer];
    [self.maskView addSubview:self.popupView];
    
}

- (void)setupCameraView {
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset352x288 cameraPosition:AVCaptureDevicePositionBack];
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    _filter = [[GPUImageSaturationFilter alloc] init];
    CGRect frame = CGRectMake(0, 70, OEScreenWidth, OEScreenWidth);
    _filterView = [[GPUImageView alloc] initWithFrame:frame];
    _filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.popupView addSubview: _filterView];
    
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_filterView];
    [_videoCamera startCameraCapture];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }];
}

- (void)setupPopupAnimation {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationWillChange)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}
- (void)setupTabbar {
    
    CGRect rect = CGRectMake(0, OEScreenHeight-70, OEScreenWidth, 70);
    OETabbar *tabbar = [[OETabbar alloc] initWithFrame:rect];
    tabbar.delegate = self;
    tabbar.backgroundColor = [UIColor blackColor];
    [self.popupView addSubview:tabbar];
    self.tabbar = tabbar;
    
}


#pragma mark - tabbar Button
- (void)dismissBtnClick {
    [self dismissPopupControllerAnimated:YES];
}

- (void)convertCamre {
    [_videoCamera rotateCamera];
}

#pragma mark - OETabBarDelegate
- (void)tabbarButtonDidClick:(UIButton *)sender {
    switch (sender.tag) {
        case OEConvert:
            [self convertCamre];
            break;
        case OEDismiss:
            [self dismissBtnClick];
            break;
        default:
            break;
    }
}
-(void)tabbarDidCancelRecord {
    
    [self cancelCamre];
    if (self.videoMaxTime>0){
        [self stopTimer];
    }
}
-(void)tabbarDidRecordComplete {
    
    if (self.videoMaxTime > 0.0 && self.timer == nil){//时间到与手势完成重复执行了stopCamre方法 判断避免重复保存
        return;
    }
    [self stopCamre];
    if (self.videoMaxTime > 0.0){
        [self stopTimer];
    }

}
-(void)tabbarDidRecord {
    [self startCamre];
    if (self.videoMaxTime>0){
//        [self.tabbar progressStart];
        [self startTimer];
    }
}
#pragma mark - notifi

- (void)orientationWillChange {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.frame = self.applicationWindow.bounds;
        CGPoint center = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height-(self.popupView.bounds.size.height * 0.5));
        self.popupView.center = center;
    }];
}

- (void)orientationChanged {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle =CNP_UIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.frame = self.applicationWindow.bounds;
        CGPoint center = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height-(self.popupView.bounds.size.height * 0.5));
        
        self.popupView.center = center;
        if (CNP_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            self.popupView.transform = transform;
        }
    }];
}


- (void)startTimer {
    if (self.videoMaxTime == 0) {
        return;
    }
    if (self.timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
}
- (void)stopTimer {
    self.nowTime = self.videoMaxTime;
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timerFired {
    self.nowTime--;
    if (self.nowTime == 1) {
        [self stopCamre];
        [self stopTimer];
    }
    
}
- (void)startCamre {
    if ([self.delegate respondsToSelector:@selector(popVideoControllerWillOutputSampleBuffer:)]) {
        _videoCamera.delegate = self;
    }
    
    if ([self.delegate respondsToSelector:@selector(popVideoControllerDidSave:)]) {
        NSURL *movieURL = [NSURL fileURLWithPath:OEPathToMovie];
        unlink([OEPathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(OEScreenWidth, OEScreenWidth)];
        _movieWriter.encodingLiveVideo = YES;
        [_filter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
    }
}
- (void)cancelCamre {
    _videoCamera.delegate = nil;
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter cancelRecording];
    _movieWriter = nil;
}

- (void)stopCamre {
    
    if ([self.delegate respondsToSelector:@selector(popVideoControllerWillOutputSampleBuffer:)]) {
       _videoCamera.delegate = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(popVideoControllerDidSave:)]) {
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecordingWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate popVideoControllerDidSave:OEPathToMovie];
            });
        }];
    }
}

CGFloat CNP_UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
    CGFloat angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}

- (void)presentPopupControllerAnimated:(BOOL)flag {
    
    // Keep a record of if the popup was presented with animation
    self.dismissAnimated = flag;
    [self calculateContentSizeThatFits:CGSizeMake(self.maskView.bounds.size.width, self.maskView.bounds.size.height) andUpdateLayout:YES];
    self.popupView.center = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
    [self.applicationWindow addSubview:self.maskView];
    self.maskView.alpha = 0;
    
    [UIView animateWithDuration:flag?0.3:0.0 animations:^{
        self.maskView.alpha = 1.0;
        self.popupView.center =  CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height-(self.popupView.bounds.size.height * 0.5));
    } completion:^(BOOL finished) {
        self.popupView.userInteractionEnabled = YES;
    }];
}

- (void)dismissPopupControllerAnimated:(BOOL)flag{
    self.dismissAnimated = flag;
    
    [UIView animateWithDuration:flag?0.3:0.0 animations:^{
        self.popupView.center = CGPointMake(self.maskView.center.x, self.maskView.frame.size.height+self.popupView.frame.size.height/2);
    } completion:^(BOOL finished) {
        self.maskView.alpha = 0.0;
        [self.maskView removeFromSuperview];
        [self deallocObj];
    }];
    
}


-(void)deallocObj {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    _delegate = nil;
    _videoCamera = nil;
    _filter = nil;
    _movieWriter = nil;
    _filterView = nil;
    
    _timer = nil;
    _popupView = nil;
    _maskView = nil;
    _applicationWindow = nil;
    _backgroundTapRecognizer = nil;
    _tabbar = nil;
}

- (CGSize)calculateContentSizeThatFits:(CGSize)size andUpdateLayout:(BOOL)update {
    
    CGSize result = CGSizeMake(0, 0);
    for (UIView *view in self.popupView.subviews)
    {
        view.autoresizingMask = UIViewAutoresizingNone;
        if (!view.hidden)
        {
            CGSize _size = view.frame.size;
            if (CGSizeEqualToSize(_size, CGSizeZero))
            {
                _size = [view sizeThatFits:size];
                _size.width = size.width;
                if (update) view.frame = CGRectMake(0, result.height, _size.width, _size.height);
            }
            else {
                if (update) {
                    view.frame = CGRectMake(0, result.height, _size.width, _size.height);
                }
            }
            result.height += _size.height;
            result.width = MAX(result.width, _size.width);
        }
    }
    if (update) self.popupView.frame = CGRectMake(0, 0, result.width, result.height);
    return result;
}



- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)handleBackgroundTapGesture:(id)sender {
    [self dismissPopupControllerAnimated:self.dismissAnimated];
}
#pragma mark - GPUImageVideoCamreaDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
        [self.delegate popVideoControllerWillOutputSampleBuffer:sampleBuffer];
}
@end
