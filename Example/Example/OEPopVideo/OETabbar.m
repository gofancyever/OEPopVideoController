//
//  OETabbar.m
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/9.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import "OETabbar.h"
#import "RecordButton.h"
#import "OEProgressView.h"
#define OEScreenWidth ([UIScreen mainScreen].bounds.size.width)
@interface OETabbar()<RecordButtonDelegate>

@property (nonatomic,weak) RecordButton *videoButton;
@property (nonatomic,strong) UILabel *upCancelAlertLabel;
@end

@implementation OETabbar

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupButtons];
        [self addSubview:self.progressView];
    }
    return self;
}

#pragma mark - Getter

-(OEProgressView *)progressView{
    if( _progressView == nil) {
        _progressView = [[OEProgressView alloc] initWithFrame:CGRectMake(0, 0, OEScreenWidth, 3)];
        _progressView.backgroundColor = [UIColor greenColor];
        
    }
    return _progressView;
    
}
-(UILabel *)upCancelAlertLabel{
    if (_upCancelAlertLabel == nil) {
        UILabel *upCancelAlertLabel = [[UILabel alloc] init];
        upCancelAlertLabel.frame = CGRectMake(0, 0, 60,20);
        upCancelAlertLabel.textAlignment = NSTextAlignmentCenter;
        upCancelAlertLabel.font = [UIFont systemFontOfSize:12];
        _upCancelAlertLabel = upCancelAlertLabel;
    }
    return _upCancelAlertLabel;
}



- (void)setupButtons {
    
    CGFloat baseWidth = OEScreenWidth/8;
    RecordButton *videoButton = [[RecordButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    videoButton.delegate = self;
#warning 长按手势在进行第二次触摸时不会触发began动作 所以弃用 改用代理
//    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
//    ges.minimumPressDuration = 0.1;
//    [videoButton addGestureRecognizer:ges];
    videoButton.center = CGPointMake(baseWidth*4, self.frame.size.height/2);
    self.videoButton = videoButton;
    
    UIButton *convertCamreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    convertCamreBtn.tag = OEConvert;
    convertCamreBtn.contentMode = UIViewContentModeCenter;
    [convertCamreBtn setBackgroundImage:[UIImage imageNamed:@"convert"] forState:UIControlStateNormal];
    [convertCamreBtn setBackgroundImage:[UIImage imageNamed:@"convert"] forState:UIControlStateHighlighted];
    convertCamreBtn.center = CGPointMake(baseWidth, 35);
    [convertCamreBtn addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    dismissBtn.tag = OEDismiss;
    convertCamreBtn.contentMode = UIViewContentModeScaleAspectFit;
    dismissBtn.center = CGPointMake(baseWidth*7, 35);
    [dismissBtn addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
    [dismissBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [dismissBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateHighlighted];
    
    [self addSubview:dismissBtn];
    [self addSubview:convertCamreBtn];
    [self addSubview:videoButton];
}

#pragma mark - self Delegate

-(void)recordButtonDidTouchDown {
    //进度条
    [self progressStart];
    [self showAlertLabel];
    if ([self.delegate respondsToSelector:@selector(tabbarDidRecord)]) {
        
        [self.delegate tabbarDidRecord];
    }
    
}
-(void)recordButtonDidEnded:(CGPoint)point {
    if (point.y >= 0) {//非取消状态
        if ([self.delegate respondsToSelector:@selector(tabbarDidRecordComplete)]) {
            [self.delegate tabbarDidRecordComplete];
        }
    }else{//取消状态
        if ([self.delegate respondsToSelector:@selector(tabbarDidCancelRecord)]) {
            [self.delegate tabbarDidCancelRecord];
        }
    }
    [self dismissAlertLabel];
    [self progressResume];
}
-(void)recordButtonDidMove:(CGPoint)point {
    //检测是否在按钮外
    if (point.y < 0) {
        if ([self.upCancelAlertLabel.text isEqualToString:@"↑上移取消"]) {
            [self changeAlertLabel];
        }
        self.upCancelAlertLabel.layer.position = CGPointMake(self.center.x, self.frame.origin.y + point.y-40);
    }else{
        if ([self.upCancelAlertLabel.text isEqualToString:@"松手取消"]) {
            [self showAlertLabel];
        }
    }
    
}
-(void)selectedButton:(RecordButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tabbarButtonDidClick:)]) {
        [self.delegate tabbarButtonDidClick:sender];
    }
}

#pragma mark - 上移取消提示Label

- (void)showAlertLabel {
    self.upCancelAlertLabel.textColor = [UIColor greenColor];
    self.upCancelAlertLabel.backgroundColor = [UIColor clearColor];
    self.upCancelAlertLabel.text = @"↑上移取消";
    self.upCancelAlertLabel.center = CGPointMake(self.center.x, CGRectGetMinY(self.frame)-self.frame.size.height/2);
    [self.superview addSubview:self.upCancelAlertLabel];
    [UIView animateWithDuration:0.2 animations:^{
        self.upCancelAlertLabel.alpha = 1;
    }];
    
}
- (void)dismissAlertLabel {
    self.upCancelAlertLabel.alpha = 0;
    [self.upCancelAlertLabel removeFromSuperview];
}
- (void)changeAlertLabel {
    self.upCancelAlertLabel.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.upCancelAlertLabel.textColor = [UIColor whiteColor];
        self.upCancelAlertLabel.backgroundColor = [UIColor redColor];
        self.upCancelAlertLabel.alpha = 1;
        self.upCancelAlertLabel.text = @"松手取消";
    }];
}
#pragma mark - 进度条
- (void)progressStart {
    if (self.progressDuration == 0) {
        return;
    }
    self.progressView.duration = self.progressDuration;
    [self.progressView startCompletion:^(BOOL finished) {
        if (finished){
            [self.videoButton setSelected:NO];
        }
    }];
}

- (void)progressResume {
    if (self.progressDuration == 0) {
        return;
    }
    [self.progressView resume];
}

@end
