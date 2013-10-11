//
//  ISTCameraHelper.m
//  AVFoundationCamera
//
//  Created by 陈 爱彬 on 13-2-18.
//  Copyright (c) 2013年 陈 爱彬. All rights reserved.
//

#import "ISTCameraHelper.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>

@implementation ISTCameraHelper
@synthesize session;
@synthesize captureOutput;
@synthesize image;
@synthesize preview;
@synthesize videoInput;
@synthesize isProcessingImage = _isProcessingImage;

static ISTCameraHelper *sharedInstance = nil;

- (void)initialize
{
    //正在处理生成图片为NO
    self.isProcessingImage = NO;
    //1.创建会话层
    self.session = [[[AVCaptureSession alloc] init] autorelease];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    
    //2.创建、配置输入设备
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//	NSError *error;
//	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//	if (!captureInput)
//	{
//		NSLog(@"Error: %@", error);
//		return;
//	}
//    [self.session addInput:captureInput];
    
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    if ([self.session canAddInput:newVideoInput]) {
        [self.session addInput:newVideoInput];
    }
    self.videoInput = newVideoInput;
    [newVideoInput release];
    //3.创建、配置输出
    captureOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [captureOutput setOutputSettings:outputSettings];
    [outputSettings release];

	[self.session addOutput:captureOutput];
    
}
- (id) init
{
	if (self = [super init]) [self initialize];
	return self;
}

-(void) embedPreviewInView: (UIView *) aView {
    if (!session) return;
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
    preview.frame = aView.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [aView.layer addSublayer: preview];
}

-(void)captureimage
{
    //将处理图片状态值置为YES
    self.isProcessingImage = YES;
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    __block ISTCameraHelper *objSelf = self;
    [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             NSLog(@"开始生成图片");
             UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
             objSelf.image = tempImage;
             [tempImage release];
             //将处理图片状态值置为NO
             objSelf.isProcessingImage = NO;
         }
//         CFDictionaryRef exifAttachments =
//         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
//         if (exifAttachments) {
//             // Do something with the attachments.
//         }
//         // Continue as appropriate.
//         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
//         UIImage *t_image = [[UIImage alloc] initWithData:imageData] ;
//#if 1
//         image = [[UIImage alloc]initWithCGImage:t_image.CGImage scale:1.0 orientation:UIImageOrientationUp];
//         [t_image release];
//#else
//         image = [t_image resizedImage:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationDefault];
//#endif
     }];
}
- (void)captureImage:(CaptureImageBlock)block{
    //get connection
    if (captureBlock){
        Block_release(captureBlock);
    }
    captureBlock = Block_copy(block);
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    __block ISTCameraHelper *objSelf = self;
    [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             NSLog(@"开始生成图片");
             UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
             objSelf.image = tempImage;
             [tempImage release];
             //返回图片
             objSelf->captureBlock(objSelf.image);
         }
     }];
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (BOOL) toggleCameraPosition
{
    BOOL success = NO;

    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        else
            goto bail;
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];
            success = YES;
            [newVideoInput release];
        } else if (error) {
            NSLog(@"切换镜头出错:%@",error);
        }
    }
    
bail:
    return success;
}
- (BOOL)isUseBackFacingCamera
{
    BOOL isUse;
    AVCaptureDevicePosition position = [[videoInput device] position];
    
    if (position == AVCaptureDevicePositionBack){
        isUse = YES;
    }else if (position == AVCaptureDevicePositionFront){
        isUse = NO;
    }else{
        isUse = NO;
    }
    return isUse;
}
- (BOOL)isBackCameraHasFlash
{
    if ([[self backFacingCamera] hasFlash]) {
        return YES;
    }
    return NO;
}
- (BOOL)isFlashSupportAutoMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
            return YES;
        }
	}
    return NO;
}
- (BOOL)isFlashSupportOnMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOn]) {
            return YES;
        }
	}
    return NO;
}
- (BOOL)isFlashSupportOffMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
            return YES;
        }
	}
    return NO;
}
- (void)changeFlashModeToAuto
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
- (void)changeFlashModeToOn
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOn]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOn];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
- (void)changeFlashModeToOff
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void) dealloc
{
    Block_release(captureBlock);
    [[self session] stopRunning];
	self.session = nil;
	self.image = nil;
    [videoInput release];
	[super dealloc];
}
#pragma mark Class Interface

+ (id) sharedInstance // private
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ISTCameraHelper alloc] init];
    });
    return sharedInstance;
}
+ (void) startRunning
{
	[[[ISTCameraHelper sharedInstance] session] startRunning];
}

+ (void) stopRunning
{
	[[[ISTCameraHelper sharedInstance] session] stopRunning];
}

+ (BOOL)toggleCamera
{
    return [[ISTCameraHelper sharedInstance] toggleCameraPosition];
}

+ (UIImage *) image
{
    //判断图片状态状态值，如果为YES，则等待，避免因还未生成图片时取图片而造成的返回照片不正确的问题
//    BOOL shouldWait = YES;
//    while (shouldWait) {
//        if (![[ISTCameraHelper sharedInstance] isProcessingImage]) {
//            NSLog(@"照片组成完毕");
//            shouldWait = NO;
//        }
//    }
    NSLog(@"取图片");
    return [[ISTCameraHelper sharedInstance] image];
}

+ (void)captureStillImage
{
    [[ISTCameraHelper sharedInstance] captureimage];
}

+ (void)captureStillImageWithBlock:(CaptureImageBlock)block
{
    [[ISTCameraHelper sharedInstance] captureImage:block];
}

+ (void)embedPreviewInView: (UIView *) aView
{
    [[ISTCameraHelper sharedInstance] embedPreviewInView:aView];
}

+ (BOOL)isBackFacingCamera
{
    return [[ISTCameraHelper sharedInstance] isUseBackFacingCamera];
}

+ (BOOL)isBackCameraSupportFlash
{
    return [[ISTCameraHelper sharedInstance] isBackCameraHasFlash];
}

+ (BOOL)isBackCameraFlashSupportAutoMode
{
    return [[ISTCameraHelper sharedInstance] isFlashSupportAutoMode];
}

+ (BOOL)isBackCameraFlashSupportOnMode
{
    return [[ISTCameraHelper sharedInstance] isFlashSupportOnMode];
}

+ (BOOL)isBackCameraFlashSupportOffMode
{
    return [[ISTCameraHelper sharedInstance] isFlashSupportOffMode];
}

+ (void)changeBackCameraFlashModeToAuto
{
    [[ISTCameraHelper sharedInstance] changeFlashModeToAuto];
}

+ (void)changeBackCameraFlashModeToOn
{
    [[ISTCameraHelper sharedInstance] changeFlashModeToOn];
}

+ (void)changeBackCameraFlashModeToOff
{
    [[ISTCameraHelper sharedInstance] changeFlashModeToOff];
}

@end
