//
//  RecordButton.m
//  LearnOpenGLESWithGPUImage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import "RecordButton.h"


@interface RecordButton()
@property (nonatomic,strong) UIBezierPath *path;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@end
@implementation RecordButton


-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
   
        self.shapeLayer = [CAShapeLayer layer];
        [self setupLayer:self.shapeLayer];
        [self.layer addSublayer:self.shapeLayer];

    }
    return self;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self startAnimation:selected];
}

- (void)setupLayer:(CAShapeLayer *)layer {
    layer.transform = CATransform3DMakeScale(1, 1, 1);
    layer.cornerRadius = self.frame.size.width/2;
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.borderWidth = 2;
    layer.borderColor = [[UIColor greenColor] CGColor];
}
- (void)startAnimation:(BOOL)selected {
    if (selected) {
        self.shapeLayer.cornerRadius = 0;
        self.shapeLayer.backgroundColor = [UIColor redColor].CGColor;
        self.shapeLayer.borderWidth = 0;
        self.shapeLayer.borderColor = [UIColor clearColor].CGColor;
        self.shapeLayer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
    }else{
        [self setupLayer:self.shapeLayer];
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selected = YES;
    if ([self.delegate respondsToSelector:@selector(recordButtonDidTouchDown)]) {
        [self.delegate recordButtonDidTouchDown];
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(recordButtonDidMove:)]) {
        [self.delegate recordButtonDidMove:point];
    }
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
    self.selected = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(recordButtonDidEnded:)]) {
        [self.delegate recordButtonDidEnded:point];
    }
}


@end
