//
//  CameraViewCollectionViewController.m
//  CamShare
//
//  Created by Albert Le on 2016-05-27.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "CameraViewCollectionViewController.h"
#import "MultipeerGuestClient.h"
#import "StreamCollectionViewCell.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewCollectionViewController () <MCNearbyServiceBrowserDelegate, MCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MultipeerGuestClientDelegate>

@property (strong, nonatomic) MCPeerID *myDevicePeerId;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) NSMutableDictionary *peers;


@property NSInteger connectionCount;

@end

@implementation CameraViewCollectionViewController

static NSString * const reuseIdentifier = @"StreamCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connectionCount = 0;
    
    self.peers = @{}.mutableCopy;
    self.myDevicePeerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:self.myDevicePeerId
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myDevicePeerId
                                                    serviceType:@"multipeer-video"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
    [self.collectionView registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.connectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height/3);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Navigate to fullscreen mode of stream
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected: {
            NSLog(@"PEER CONNECTED: %@", peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.connectionCount inSection:0];
                
                MultipeerGuestClient *newSession = [[MultipeerGuestClient alloc] initWithPeer:peerID forIndexPath:indexPath];
                newSession.delegate = self;
                
                self.peers[peerID.displayName] = newSession;
                self.connectionCount++;
                
                [self.collectionView reloadData];
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
                
                MultipeerGuestClient* peer = self.peers[peerID.displayName];
                [peer stopPlaying];
                peer = nil;
                
                [self.peers removeObjectForKey:peerID.displayName];
                
                self.connectionCount--;
                [self.collectionView reloadData];
            });
            break;
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *dict = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIImage *image = [UIImage imageWithData:dict[@"image"] scale:2.0];
    NSNumber *framesPerSecond = dict[@"framesPerSecond"];
    
    MultipeerGuestClient *currentClient = self.peers[peerID.displayName];
    [currentClient addImageFrame:image withFPS:framesPerSecond];
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

#pragma mark - MCNearbyServiceBrowserDelegate

- (void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
}

- (void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:0];
}

- (void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    //TODO: Show user the connection has been lost
}

#pragma mark - GuestClient delegate

- (void) showImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        StreamCollectionViewCell *cell = (StreamCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        UIImage *resizedImage = [self cropImage:image toRect:CGRectMake(cell.frame.origin.x,
                                                                        cell.frame.origin.y,
                                                                        self.collectionView.frame.size.width,
                                                                        self.collectionView.frame.size.height/3)];
        [cell.streamImageView setImage:resizedImage];
    });
}

- (void) raiseFramerateForPeer:(MCPeerID *)peerID {
    NSData* data = [@"raiseFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
}

- (void) lowerFramerateForPeer:(MCPeerID *)peerID {
    NSData* data = [@"lowerFramerate" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
}

#pragma mark - Helper Methods 

- (UIImage *)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


@end
