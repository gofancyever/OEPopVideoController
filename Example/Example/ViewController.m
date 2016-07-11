//
//  ViewController.m
//  Example
//
//  Created by apple on 16/7/11.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

#import "ViewController.h"
#import "OEPopVideoController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "MBProgressHUD+MJ.h"

@interface ViewController ()<OEPopVideoControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)openVideoController:(id)sender {
    OEPopVideoController *videoController = [[OEPopVideoController alloc] init];
    videoController.videoMaxTime = 4;
    videoController.delegate = self;
    [videoController presentPopupControllerAnimated:YES];
}

#pragma mark - OEPopVideoControllerDelegate
-(void)popVideoControllerDidSave:(NSString *)url{
    [self savePhoneLibrary:url];
}

-(void)popVideoControllerWillOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {

}

-(void)savePhoneLibrary:(NSString *)url{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *movieURL = [NSURL fileURLWithPath:url];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url))
    {
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             
//             UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
                 if (error) {
                     
                     [MBProgressHUD showError:@"error"];
//                      [alert addAction:[UIAlertAction actionWithTitle:@"error" style:UIAlertActionStyleDefault handler:nil]];
                 } else {
//                     [alert addAction:[UIAlertAction actionWithTitle:@"success" style:UIAlertActionStyleDefault handler:nil]];
                     [MBProgressHUD showSuccess:@"success"];
                 }
//              [self presentViewController:alert animated:YES completion:nil];
         }];
    }
    
}


@end
