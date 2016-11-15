//
//  FKLTestController.m
//  FKLPanWebView
//
//  Created by amglfk on 16/11/15.
//  Copyright © 2016年 FKLam. All rights reserved.
//

#import "FKLTestController.h"
#import "FKLPanWebView.h"

#define IS_IPHONE_6_PLUS [UIScreen mainScreen].scale == 3
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString * const kTargetsString = @"_targets";
static NSString * const kTargetString = @"_target";
static NSString * const kActionString = @"handleNavigationTransition:";

@interface FKLTestController () <FKLPanWebViewDelegate>

@property (nonatomic, strong) FKLPanWebView *webView;

@end

@implementation FKLTestController {
    id _navPanTarget;
    SEL _navPanAction;
}

#pragma mark - lift cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)dealloc {
    if ( !self.navigationController.interactivePopGestureRecognizer.isEnabled ) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ( !self.navigationController.interactivePopGestureRecognizer.isEnabled ) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - setup

- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 获取系统默认手势 Handler 并保存
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSMutableArray *gestureTargets = [self.navigationController.interactivePopGestureRecognizer valueForKey:kTargetsString];
        id gestureTarget = [gestureTargets firstObject];
        _navPanTarget = [gestureTarget valueForKey:kTargetString];
        _navPanAction = NSSelectorFromString(kActionString);
    }
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    
    if ( !self.navigationController.interactivePopGestureRecognizer.isEnabled ) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - FKLPanWebViewDelegate

- (void)FKL_panWebView:(FKLPanWebView *)webView panPopGesture:(UIPanGestureRecognizer *)panPopGesture {
    if ( _navPanTarget && [_navPanTarget respondsToSelector:_navPanAction] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_navPanTarget performSelector:_navPanAction withObject:panPopGesture];
#pragma clang diagnostic pop
    }
}

- (void)FKL_panWebView:(FKLPanWebView *)webView didChangePopGestureEnabled:(BOOL)enabled {
    if ( enabled ) {
        if ( self.navigationController.interactivePopGestureRecognizer.isEnabled ) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

#pragma mark - getter methods 

- (FKLPanWebView *)webView {
    if ( nil == _webView ) {
        _webView = [[FKLPanWebView alloc] init];
        _webView.panDelegate = self;
    }
    return _webView;
}

@end
