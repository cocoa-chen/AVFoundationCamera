//
//  ISTViewPhotoViewController.m
//  AVFoundationCamera
//
//  Created by 陈 爱彬 on 13-10-8.
//  Copyright (c) 2013年 陈 爱彬. All rights reserved.
//

#import "ISTViewPhotoViewController.h"

@interface ISTViewPhotoViewController ()

@end

@implementation ISTViewPhotoViewController
@synthesize photoImage = _photoImage;

- (void)dealloc
{
    [_photoImage release];
    [super dealloc];
}
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
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(10, 10, 80, 30);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    //预览图片
    NSLog(@"图片宽高%f,%f",_photoImage.size.width,_photoImage.size.height);
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 280, _photoImage.size.height / _photoImage.size.width * 280)];
    photoImageView.image = _photoImage;
    [self.view addSubview:photoImageView];
    [photoImageView release];
}

- (void)backToCamera
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
