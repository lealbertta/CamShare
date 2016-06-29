//
//  StreamViewController.m
//  CamShare
//
//  Created by Albert Le on 2016-05-31.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "StreamViewController.h"

@interface StreamViewController () <MCSessionDelegate , MultipeerGuestClientDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *streamView;

@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session.delegate = self;
    self.mpClient.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected: {
            NSLog(@"PEER CONNECTED: %@", peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
            });

            break;
        }
        case MCSessionStateConnecting:
        NSLog(@"PEER CONNECTING: %@", peerID.displayName);
        //TODO: Add loading animation
        break;
        case MCSessionStateNotConnected: {
            NSLog(@"PEER NOT CONNECTED: %@", peerID.displayName);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (peerID.displayName == self.peerID) {
                 
                    [self.mpClient stopPlaying];
                
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
                
            });
            break;
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *dict = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIImage *image = [UIImage imageWithData:dict[@"image"] scale:2.0];
    NSNumber *framesPerSecond = dict[@"framesPerSecond"];
    
    [self.mpClient addImageFrame:image withFPS:framesPerSecond];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}

- (void) session:(MCSession*)session didReceiveCertificate:(NSArray*)certificate fromPeer:(MCPeerID*)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler {
    certificateHandler(YES);
}

#pragma mark - GuestClient delegate

- (void)setHostName:(NSString *)hostName atIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)showImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamView setImage:image];
    });
}

- (void)raiseFramerateForPeer:(MCPeerID *)peerID {
    NSData* data = [@"raiseFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
}

- (void)lowerFramerateForPeer:(MCPeerID *)peerID {
    NSData* data = [@"lowerFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
}


@end
