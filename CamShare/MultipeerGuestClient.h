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

- (void) showImage:(UIImage*) image atIndexPath:(NSIndexPath*) indexPath;
- (void) raiseFramerateForPeer:(MCPeerID*) peerID;
- (void) lowerFramerateForPeer:(MCPeerID*) peerID;

@end

@interface MultipeerGuestClient : NSObject

@property (strong, nonatomic) id delegate;
@property BOOL useAutoFramerate;

- (instancetype) initWithPeer:(MCPeerID*) peerID atIndexPath:(NSIndexPath*) indexPath;

- (void) addImageFrame:(UIImage*) image withFPS:(NSNumber*) fps;
- (void) stopPlaying;

@end
