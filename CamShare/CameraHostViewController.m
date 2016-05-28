//
//  CameraHostViewController.m
//  CamShare
//
//  Created by Albert Le on 2016-05-27.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "CameraHostViewController.h"
#import "AVCaptureMultipeerVideoDataOutput.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraHostViewController ()

@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@end

@implementation CameraHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCamera];
}

- (void)initCamera {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.frame = CGRectMake(0,0, 320, 320);
    [self.cameraPreview.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    [_captureSession addInput:videoDeviceInput];
    
    AVCaptureMultipeerVideoDataOutput *videoOutput = [[AVCaptureMultipeerVideoDataOutput alloc] initWithDisplayName:[[UIDevice currentDevice] name]
                                                                                                      withAssistant:NO];
    [_captureSession addOutput:videoOutput];
    
    [self setFrameRate:15 onDevice:videoDevice];
    
    [self.captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setFrameRate:(NSInteger) framerate onDevice:(AVCaptureDevice*) videoDevice {
    if ([videoDevice lockForConfiguration:nil]) {
        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1,(int)framerate);
        videoDevice.activeVideoMinFrameDuration = CMTimeMake(1,(int)framerate);
        [videoDevice unlockForConfiguration];
    }
}

@end
