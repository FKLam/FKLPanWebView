//
//  FKLPanWebView.m
//  Pods
//
//  Created by amglfk on 16/11/14.
//
//

#import "FKLPanWebView.h"
#import "FKLWebCacheTool.h"

static NSString * const kPreviewKeyString = @"FKL_preview";
static NSString * const kURLString = @"FKL_url";

@interface FKLPanWebView () <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIGestureRecognizer *panGesture;

@property (nonatomic, assign) CGFloat panStartx;

@property (nonatomic, assign) CGFloat panStarty;

@property (nonatomic, copy) NSMutableArray *historyViewStack;

@property (nonatomic, strong) UIImageView *historyView;

@property (nonatomic, weak) id<UIWebViewDelegate> originDelegate;

@end
@implementation FKLPanWebView

#pragma mark - lift cycle

- (instancetype)init {
    self = [super init];
    if ( self ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self historyView].frame = self.bounds;
}

- (void)dealloc {
    if ( _historyView ) {
        [_historyView removeFromSuperview];
        _historyView = nil;
    }
    [[FKLWebCacheTool sharedInstance] clearAllWebRecord];
}

#pragma mark - setup

- (void)setup {
    [self addGestureRecognizer:self.panGesture];
    [super setDelegate:self];
    
    [FKLPanWebView addShowToShowView:self];
}

#pragma mark - event respond

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    if ( ![self canGoBack] || self.historyViewStack.count == 0 ) {
        if ( self.panDelegate && [self.panDelegate respondsToSelector:@selector(FKL_panWebView:panPopGesture:)] ) {
            [self.panDelegate FKL_panWebView:self panPopGesture:panGesture];
        }
        
        return;
    }
    
    static BOOL canMoveView = YES;
    CGPoint point = [panGesture translationInView:self];
    if ( panGesture.state == UIGestureRecognizerStateBegan ) {
        self.panStartx = point.x;
        self.panStarty = point.y;
        if ( [panGesture translationInView:self].y != 0 ) {
            canMoveView = NO;
            return;
        }
    } else if ( panGesture.state == UIGestureRecognizerStateChanged ) {
        CGFloat distanceX = point.x - self.panStartx;
        if ( !canMoveView || distanceX < 50.0 ) {
            return;
        }
        if ( distanceX > 0 ) {
            if ( [self canGoBack] ) {
                assert([self.historyViewStack count] > 0 );
                
                CGRect tempFrame = self.frame;
                tempFrame.origin.y = 0;
                tempFrame.origin.x = distanceX;
                self.frame = tempFrame;
                [self historyView].image = [[self.historyViewStack lastObject] objectForKey:kPreviewKeyString];
                tempFrame.origin.x = -self.bounds.size.width / 2.0 + distanceX / 2.0;
                [self historyView].frame = tempFrame;
            }
        }
    } else if ( panGesture.state == UIGestureRecognizerStateEnded ) {
        
        if ( !canMoveView ) {
            canMoveView = YES;
            return;
        }
        CGFloat distanceX = point.x - self.panStartx;
        CGFloat duration = .5f;
        if ( [self canGoBack] ) {
            if ( distanceX > self.bounds.size.width / 2.0 ) {
                [UIView animateWithDuration:(1.0 - distanceX / self.bounds.size.width) * duration animations:^{
                    CGRect tempFrame = self.frame;
                    tempFrame.origin.x = self.bounds.size.width;
                    self.frame = tempFrame;
                    tempFrame.origin.x = 0;
                    [self historyView].frame = tempFrame;
                } completion:^(BOOL finished) {
                    CGRect tempFrame = self.frame;
                    tempFrame.origin.x = 0;
                    self.frame = tempFrame;
                    [self.superview insertSubview:self.historyView aboveSubview:self];
                    [self goBack];
                }];
            } else {
                [UIView animateWithDuration:(distanceX / self.bounds.size.width) * duration animations:^{
                    CGRect tempFrame = self.frame;
                    tempFrame.origin.x = 0;
                    self.frame = tempFrame;
                    tempFrame.origin.x = -self.bounds.size.width / 2.0;
                    [self historyView].frame = tempFrame;
                } completion:nil];
            }
        }
    }
}

- (void)goBack {
    [super goBack];
    
    __weak typeof( self ) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.superview insertSubview:weakSelf.historyView belowSubview:self];
        [weakSelf.historyViewStack removeLastObject];
        [weakSelf historyView].image = nil;
    });
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = YES;
    if ( self.originDelegate && [self.originDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)] ) {
        result = [self.originDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    BOOL isFragmentJump = NO;
    if ( request.URL.fragment ) {
        NSString *noFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        if ( webView.request.URL.absoluteString ) {
            NSString *preNonFragmentURL;
            if ( webView.request.URL.fragment ) {
                preNonFragmentURL = [webView.request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:webView.request.URL.fragment] withString:@""];
            } else {
                preNonFragmentURL = webView.request.URL.absoluteString;
            }
            isFragmentJump = [noFragmentURL isEqualToString:preNonFragmentURL];
        }
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if ( result && !isFragmentJump && isHTTPOrFile && isTopLevelNavigation ) {
        if ( (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther) && [[webView.request.URL description] length] ) {
            if ( ![[[self.historyViewStack lastObject] objectForKey:kURLString] isEqualToString:[self.request.URL description]] ) {
                UIImage *curPreview = [FKLPanWebView screenShotOfView:self];
                [self.historyViewStack addObject:@{kPreviewKeyString : curPreview, kURLString : [self.request.URL description]}];
                
//                NSString *cacheKeyString = request.URL.absoluteString;
//                if ( nil != cacheKeyString && 0 < cacheKeyString.length ) {
//                    
//                    CGFloat offsetY = self.scrollView.contentOffset.y;
//                    [[FKLWebCacheTool sharedInstance] saveWebRecordWithURLString:cacheKeyString contentOffsetY:offsetY];
//                    
//                }
            }
        }
    }
    return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ( self.originDelegate && [self.originDelegate respondsToSelector:@selector(webViewDidStartLoad:)] ) {
        [self.originDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( 0 < [self.historyViewStack count] ) {
        if ( self.panDelegate && [self.panDelegate respondsToSelector:@selector(FKL_panWebView:didChangePopGestureEnabled:)] ) {
            [self.panDelegate FKL_panWebView:self didChangePopGestureEnabled:YES];
        }
    }
    if ( self.originDelegate && [self.originDelegate respondsToSelector:@selector(webViewDidFinishLoad:)] ) {
        [self.originDelegate webViewDidFinishLoad:webView];
    }
    
    NSString *cacheKeyString = webView.request.URL.absoluteString;
    if ( nil != cacheKeyString || 0 < cacheKeyString.length ) {
        if ( [[FKLWebCacheTool sharedInstance] isExistRecordWithUrlString:cacheKeyString] ) {
            CGFloat offsetY = 0;
            offsetY = [[FKLWebCacheTool sharedInstance] readWebRecordWithURLString:cacheKeyString];
            [webView.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ( self.originDelegate && [self.originDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)] ) {
        [self.originDelegate webView:self didFailLoadWithError:error];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    NSString *cacheKeyString = self.request.URL.absoluteString;
    CGFloat offsetY = self.scrollView.contentOffset.y;
    [[FKLWebCacheTool sharedInstance] saveWebRecordWithURLString:cacheKeyString contentOffsetY:offsetY];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [self.historyViewStack count] > 0 ) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - private mehtods 

+ (void)addShowToShowView:(UIView *)showView {
    CALayer *layer = showView.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
    layer.shadowPath = path.CGPath;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 0.4f;
    layer.shadowRadius = 8.0f;
}

+ (UIImage *)screenShotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    if ( [view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)] ) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - setter mehtods 

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    _originDelegate = delegate;
}

#pragma mark - getter mehtods

- (id<UIWebViewDelegate>)delegate {
    return _originDelegate;
}

- (NSMutableArray *)historyViewStack {
    if ( nil == _historyViewStack ) {
        _historyViewStack = [NSMutableArray array];
    }
    return _historyViewStack;
}

- (UIGestureRecognizer *)panGesture {
    if ( nil == _panGesture ) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UIImageView *)historyView {
    if ( nil == _historyView ) {
        if ( self.superview ) {
            _historyView = [[UIImageView alloc] initWithFrame:self.bounds];
            [self.superview insertSubview:_historyView belowSubview:self];
        }
    }
    return _historyView;
}

@end
