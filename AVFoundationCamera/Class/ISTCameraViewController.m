//
//  ISTCameraViewController.m
//  AVFoundationCamera
//
//  Created by 陈 爱彬 on 13-10-8.
//  Copyright (c) 2013年 陈 爱彬. All rights reserved.
//

#import "ISTCameraViewController.h"
#import "ISTCameraHelper.h"
#import "ISTViewPhotoViewController.h"

@interface ISTCameraViewController ()
{
    UIView *previewView;
    UIButton *flashBtn;
    ISTCameraFlashMode currentFlashMode;
}
@end

@implementation ISTCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //创建视图
    previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    previewView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:previewView];
    [previewView release];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(10, 410, 80, 40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToMainVc:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    takePhotoBtn.frame = CGRectMake(110, 410, 100, 40);
    [takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoBtn];
    UIButton *toggleCameraBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toggleCameraBtn.frame = CGRectMake(230, 20, 80, 30);
    [toggleCameraBtn setTitle:@"前后" forState:UIControlStateNormal];
    [toggleCameraBtn addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toggleCameraBtn];
    flashBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    flashBtn.frame = CGRectMake(10, 20, 80, 30);
    [flashBtn addTarget:self action:@selector(changeFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    //判断支持类别
    if ([ISTCameraHelper isBackCameraFlashSupportAutoMode]) {
        [flashBtn setTitle:@"自动" forState:UIControlStateNormal];
        currentFlashMode = ISTCameraFlashModeAuto;
    }else if ([ISTCameraHelper isBackCameraFlashSupportOnMode]){
        [flashBtn setTitle:@"打开" forState:UIControlStateNormal];
        currentFlashMode = ISTCameraFlashModeOn;
    }else if ([ISTCameraHelper isBackCameraFlashSupportOffMode]){
        [flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
        currentFlashMode = ISTCameraFlashModeOff;
    }
    //后置摄像头若不支持闪光灯隐藏按钮
    if (![ISTCameraHelper isBackCameraSupportFlash]) {
        flashBtn.hidden = YES;
    }
    //预览窗口
    [ISTCameraHelper embedPreviewInView:previewView];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //开始实时取景
    [ISTCameraHelper startRunning];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止取景
    [ISTCameraHelper stopRunning];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//返回
- (void)backToMainVc:(UIButton *)btn
{
    //Back
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//拍照
- (void)takePhoto:(UIButton *)btn
{
//    [ISTCameraHelper captureStillImage];
//    [self performSelector:@selector(getImage) withObject:nil afterDelay:0.5];
    [ISTCameraHelper captureStillImageWithBlock:^(UIImage *captureImage){
        ISTViewPhotoViewController *viewPhotoVc = [[ISTViewPhotoViewController alloc] init];
        viewPhotoVc.photoImage = captureImage;
        [self.navigationController pushViewController:viewPhotoVc animated:YES];
        [viewPhotoVc release];
    }];
}
//获取图片并跳转到下一界面
- (void)getImage
{
    ISTViewPhotoViewController *viewPhotoVc = [[ISTViewPhotoViewController alloc] init];
    viewPhotoVc.photoImage = [ISTCameraHelper image];
    [self.navigationController pushViewController:viewPhotoVc animated:YES];
    [viewPhotoVc release];
}
//切换镜头
- (void)toggleCamera:(UIButton *)btn
{
    btn.enabled = NO;
    [ISTCameraHelper toggleCamera];
    btn.enabled = YES;
    if ([ISTCameraHelper isBackFacingCamera]) {
        if ([ISTCameraHelper isBackCameraSupportFlash]) {
            flashBtn.hidden = NO;
        }
    }else{
        flashBtn.hidden = YES;
    }
}
//切换闪光灯
- (void)changeFlashMode
{
    if (currentFlashMode == ISTCameraFlashModeAuto) {
        //切换到闪光灯为开
        if ([ISTCameraHelper isBackCameraFlashSupportOnMode]) {
            [ISTCameraHelper changeBackCameraFlashModeToOn];
            currentFlashMode = ISTCameraFlashModeOn;
        }else if ([ISTCameraHelper isBackCameraFlashSupportOffMode]){
            //切换到闪光灯为关
            [ISTCameraHelper changeBackCameraFlashModeToOff];
            currentFlashMode = ISTCameraFlashModeOff;
        }
    }else if (currentFlashMode == ISTCameraFlashModeOn) {
        //切换到闪光灯为关
        if ([ISTCameraHelper isBackCameraFlashSupportOffMode]) {
            [ISTCameraHelper changeBackCameraFlashModeToOff];
            currentFlashMode = ISTCameraFlashModeOff;
        }else if ([ISTCameraHelper isBackCameraFlashSupportAutoMode]){
            //切换到闪光灯为自动
            [ISTCameraHelper changeBackCameraFlashModeToAuto];
            currentFlashMode = ISTCameraFlashModeAuto;
        }
    }else if (currentFlashMode == ISTCameraFlashModeOff) {
        //切换到闪光灯为自动
        if ([ISTCameraHelper isBackCameraFlashSupportAutoMode]) {
            [ISTCameraHelper changeBackCameraFlashModeToAuto];
            currentFlashMode = ISTCameraFlashModeAuto;
        }else if ([ISTCameraHelper isBackCameraFlashSupportOnMode]){
            //切换到闪光灯为开
            [ISTCameraHelper changeBackCameraFlashModeToOn];
            currentFlashMode = ISTCameraFlashModeOn;
        }
    }
}
@end
