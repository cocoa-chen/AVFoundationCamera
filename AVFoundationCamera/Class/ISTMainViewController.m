//
//  ISTMainViewController.m
//  AVFoundationCamera
//
//  Created by 陈 爱彬 on 13-10-8.
//  Copyright (c) 2013年 陈 爱彬. All rights reserved.
//

#import "ISTMainViewController.h"
#import "ISTCameraViewController.h"

@interface ISTMainViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@end

@implementation ISTMainViewController

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
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    takePhotoBtn.frame = CGRectMake(110, 100, 100, 40);
    [takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(customPhotoTake:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//自定义相机
- (void)customPhotoTake:(UIButton *)btn
{
    ISTCameraViewController *cameraVc = [[ISTCameraViewController alloc] init];
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraVc];
    cameraNavigationController.navigationBarHidden = YES;
    [self presentViewController:cameraNavigationController animated:YES completion:^{
        [cameraNavigationController release];
        [cameraVc release];
    }];
}
//系统相机
- (void)takePhoto:(UIButton *)btn
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:^{
        [picker release];
    }];
}
@end
