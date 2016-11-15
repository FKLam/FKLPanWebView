//
//  FKLViewController.m
//  FKLPanWebView
//
//  Created by FKLam on 11/14/2016.
//  Copyright (c) 2016 FKLam. All rights reserved.
//

#import "FKLViewController.h"
#import "FKLTestController.h"

@interface FKLViewController ()


/**
 测试按钮
 */
@property (nonatomic, strong) UIButton *testButton;

@end

@implementation FKLViewController

#pragma mark - lift cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupUI];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadUI

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.testButton];
    self.testButton.frame = CGRectMake(0, 100.0, self.view.bounds.size.width, 44.0);
    
}

#pragma mark - event responds

- (void)clickTestButton:(UIButton *)sender {
    FKLTestController *vc = [[FKLTestController alloc] init];
    vc.urlString = @"http://m.aomygod.com";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter methods 

- (UIButton *)testButton {
    if ( nil == _testButton ) {
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setTitle:@"Test" forState:UIControlStateNormal];
        [clickButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [clickButton addTarget:self action:@selector(clickTestButton:) forControlEvents:UIControlEventTouchUpInside];
        _testButton = clickButton;
    }
    return _testButton;
}

@end
