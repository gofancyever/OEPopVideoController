# OEPopVideoController
##基于GPUImage实现的类似微信小视频录制功能
![](https://github.com/ofEver/OEPopVideoController/blob/master/ScreenShots/OEVideo2.gif)<br>
![](https://github.com/ofEver/OEPopVideoController/blob/master/ScreenShots/OEVideo3.gif)<br>
###How use：
<h5>	1 将 OEPopVideo 文件夹拖入到你的工程 <br>
	2 执行pod install 添加GPUImage库<br>
	3 导入头文件<code> #import "OEPopVideoController.h"</code>
	4 使用：
</h5>

<pre>
-(IBAction)openVideoController:(id)sender {
	//创建 OEPopVideoController 对象
    OEPopVideoController *videoController = [[OEPopVideoController alloc] init];
    //设置 进度条时间 默认无限制
    videoController.videoMaxTime = 4;
    //设置代理得到视频数据
    videoController.delegate = self;
    //弹出
    [videoController presentPopupControllerAnimated:YES];
}
\#pragma mark - OEPopVideoControllerDelegate
//打包好的视频连接
-(void)popVideoControllerDidSave:(NSString *)url{
    [self savePhoneLibrary:url];
}
//原始数据 做自定义处理
-(void)popVideoControllerWillOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
}
</code></pre>
#####如果对你有帮助别忘了 Star 如遇bug或意见欢迎Fork and 我的邮箱：pomyven@gmail.com
####录像功能需真机演示
