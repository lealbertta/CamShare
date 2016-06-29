//
//  MultipeerGuestClient.h
//  CamShare
//
//  Created by Albert Le on 2016-05-29.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol MultipeerGuestClientDelegate <NSObject>

- (void)setHostName:(NSString *)hostName atIndexPath:(NSIndexPath *)indexPath;
- (void)showImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath;
- (void)raiseFramerateForPeer:(MCPeerID *)peerID;
- (void)lowerFramerateForPeer:(MCPeerID *)peerID;

@end

@interface MultipeerGuestClient : NSObject

@property (strong, nonatomic) id delegate;
@property (nonatomic) NSIndexPath *indexPath;
@property BOOL useAutoFramerate;

- (instancetype)initWithPeer:(MCPeerID *)peerID forIndexPath:(NSIndexPath *)indexPath;

- (void)addImageFrame:(UIImage *)image withFPS:(NSNumber *)fps;
- (void)stopPlaying;
- (void)setHostNameForIndexPath:(NSIndexPath*)indexPath;
@end
