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
@property (weak, nonatomic) IBOutlet UIButton *backButton;
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
    captureVideoPreviewLayer.frame = self.view.frame;
    
    [self.cameraPreview.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    
    
    AVCaptureMultipeerVideoDataOutput *videoOutput = [[AVCaptureMultipeerVideoDataOutput alloc] initWithDisplayName:[[UIDevice currentDevice] name]
                                                                                                      withAssistant:NO];
    [self.captureSession addInput:videoDeviceInput];
    [self.captureSession addOutput:videoOutput];
    [self setFrameRate:15 onDevice:videoDevice];
    [self.captureSession startRunning];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapBackButton:(id)sender {
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setFrameRate:(NSInteger) framerate onDevice:(AVCaptureDevice*) videoDevice {
    if ([videoDevice lockForConfiguration:nil]) {
        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1,(int)framerate);
        videoDevice.activeVideoMinFrameDuration = CMTimeMake(1,(int)framerate);
        [videoDevice unlockForConfiguration];
    }
}

@end
