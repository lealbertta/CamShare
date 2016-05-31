//
//  StreamCollectionViewCell.h
//  CamShare
//
//  Created by Albert Le on 2016-05-30.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *streamImageView;
@property (weak, nonatomic) IBOutlet UILabel *hostNameLabel;

@end
