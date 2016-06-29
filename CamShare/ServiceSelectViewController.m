//
//  ServiceSelectViewController.m
//  CamShare
//
//  Created by Albert Le on 2016-05-27.
//  Copyright © 2016 Albert Le. All rights reserved.
//

#import "ServiceSelectViewController.h"

@interface ServiceSelectViewController ()

@property (weak, nonatomic) IBOutlet UIButton *hostButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation ServiceSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hostButton.layer.cornerRadius = 5.0f;
    self.connectButton.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
