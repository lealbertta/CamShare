//
//  MultipeerGuestClient.m
//  CamShare
//
//  Created by Albert Le on 2016-05-29.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "MultipeerGuestClient.h"

@interface MultipeerGuestClient ()

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) NSTimer *playerClock;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic, strong) NSNumber *fps;
    
@property (nonatomic) NSInteger numberOfFramesAtLastTick;
@property (nonatomic) NSInteger numberOfTicksWithFullBuffer;

@end

@implementation MultipeerGuestClient

- (instancetype)initWithPeer:(MCPeerID*) peerID forIndexPath:(NSIndexPath*) indexPath {
    self = [super init];
    if (self) {
        _frames = @[].mutableCopy;
        _isPlaying = NO;
        _peerID = peerID;
        _indexPath = indexPath;
        _numberOfTicksWithFullBuffer = 0;
        
    }
    return self;
}

- (void) playerClockTick {
    
    NSInteger delta = self.frames.count - self.numberOfFramesAtLastTick;
    self.numberOfFramesAtLastTick = self.frames.count;
    if (self.isPlaying) {
        
        if (self.frames.count > 1) {
            
            
            if (self.useAutoFramerate) {
                if (self.frames.count >= 10) {
                    if (self.numberOfTicksWithFullBuffer >= 30) {
                        // higher framerate
                        if (self.delegate) {
                            [self.delegate raiseFramerateForPeer:self.peerID];
                        }
                        self.numberOfTicksWithFullBuffer = 0;
                    }
                    
                    self.numberOfTicksWithFullBuffer++;
                } else {
                    self.numberOfTicksWithFullBuffer = 0;
                    if (delta <= -1) {
                        // lower framerate
                        if (self.delegate && _fps.floatValue > 5) {
                            [self.delegate lowerFramerateForPeer:self.peerID];
                        }
                    }
                }
            }
            
            if (self.delegate) {
                [self.delegate showImage:_frames[0] atIndexPath:_indexPath];
            }
            [self.frames removeObjectAtIndex:0];
            
            
        } else {
            self.isPlaying = NO;
        }
    } else {
        if (self.frames.count > 10) {
            self.isPlaying = YES;
        }
    }
}

- (void) addImageFrame:(UIImage*) image withFPS:(NSNumber*) fps {
    self.fps = fps;
    if (!self.playerClock || (self.playerClock.timeInterval != (1.0/fps.floatValue))) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerClock) {
                [self.playerClock invalidate];
            }
            
            NSTimeInterval timeInterval = 1.0 / [fps floatValue];
            self.playerClock = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                            target:self
                                                          selector:@selector(playerClockTick)
                                                          userInfo:nil
                                                           repeats:YES];
        });
    }
    [self.frames addObject:image];
}

- (void) stopPlaying {
    if (self.playerClock) {
        [self.playerClock invalidate];
    }
}

@end
