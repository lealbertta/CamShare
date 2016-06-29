//
//  StreamViewController.h
//  CamShare
//
//  Created by Albert Le on 2016-05-31.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "ViewController.h"
#import "MultipeerGuestClient.h"

@interface StreamViewController : ViewController <MultipeerGuestClientDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *streamPlayer;
@property (weak, nonatomic) MultipeerGuestClient *mpClient;
@property (weak, nonatomic) MCPeerID *myDevicePeerId;
@property (weak, nonatomic) NSString *peerID;
@property (weak, nonatomic) MCSession *session;

@end
