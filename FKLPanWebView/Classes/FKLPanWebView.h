//
//  FKLPanWebView.h
//  Pods
//
//  Created by amglfk on 16/11/14.
//
//  支持手势侧滑返回的 WebView

#import <UIKit/UIKit.h>

@class FKLPanWebView;

@protocol  FKLPanWebViewDelegate <NSObject>

@optional

- (void)FKL_panWebView:(FKLPanWebView *)webView panPopGesture:(UIPanGestureRecognizer *)panPopGesture;

- (void)FKL_panWebView:(FKLPanWebView *)webView didChangePopGestureEnabled:(BOOL)enabled;

@end

@interface FKLPanWebView : UIWebView

@property (nonatomic, weak) id<FKLPanWebViewDelegate> panDelegate;

@end
