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

static ISTCameraHelper *sharedInstance = nil;

- (void)initialize
{
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
    [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];             
             if (image) {
                 [image release],image = nil;
             }
             image = [[UIImage alloc] initWithData:imageData];
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
    [[self session] stopRunning];
	self.session = nil;
	self.image = nil;
    [videoInput release];
	[super dealloc];
}
#pragma mark Class Interface

+ (id) sharedInstance // private
{
    @synchronized(self){
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone{
    return self;
}

+ (void) startRunning
{
	[[[self sharedInstance] session] startRunning];
}

+ (void) stopRunning
{
	[[[self sharedInstance] session] stopRunning];
}

+ (BOOL)toggleCamera
{
    return [[self sharedInstance] toggleCameraPosition];
}

+ (UIImage *) image
{
	return [[self sharedInstance] image];
}

+ (void)captureStillImage
{
    [[self sharedInstance] captureimage];
}

+ (void)embedPreviewInView: (UIView *) aView
{
    [[self sharedInstance] embedPreviewInView:aView];
}

+ (BOOL)isBackFacingCamera
{
    return [[self sharedInstance] isUseBackFacingCamera];
}

+ (BOOL)isBackCameraSupportFlash
{
    return [[self sharedInstance] isBackCameraHasFlash];
}

+ (BOOL)isBackCameraFlashSupportAutoMode
{
    return [[self sharedInstance] isFlashSupportAutoMode];
}

+ (BOOL)isBackCameraFlashSupportOnMode
{
    return [[self sharedInstance] isFlashSupportOnMode];
}

+ (BOOL)isBackCameraFlashSupportOffMode
{
    return [[self sharedInstance] isFlashSupportOffMode];
}

+ (void)changeBackCameraFlashModeToAuto
{
    [[self sharedInstance] changeFlashModeToAuto];
}

+ (void)changeBackCameraFlashModeToOn
{
    [[self sharedInstance] changeFlashModeToOn];
}

+ (void)changeBackCameraFlashModeToOff
{
    [[self sharedInstance] changeFlashModeToOff];
}

@end
