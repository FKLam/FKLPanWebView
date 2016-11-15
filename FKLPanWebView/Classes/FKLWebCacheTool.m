//
//  FKLWebCacheTool.m
//  Pods
//
//  Created by amglfk on 16/11/15.
//
//

#import "FKLWebCacheTool.h"

NSString const * kWebViewCache = @"FKL_webView_cache";

@implementation FKLWebCacheTool

+ (instancetype)sharedInstance {
    static FKLWebCacheTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( nil == _instance ) {
            _instance = [self new];
        }
    });
    return _instance;
}

- (BOOL)isExistRecordWithUrlString:(NSString *)urlString {
    BOOL isExist = NO;
    NSMutableArray *webViewCacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewCache];
    NSMutableArray *tempArray = nil;
    if ( !webViewCacheArray ) {
        return isExist;
    } else {
        tempArray = [webViewCacheArray mutableCopy];
        for ( NSMutableDictionary *obj in tempArray ) {
            NSString *keyString = [[obj allKeys] firstObject];
            if ( [keyString isEqualToString:urlString] ) {
                isExist = YES;
                break;
            }
        }
    }
    return isExist;
}

- (void)saveWebRecordWithURLString:(NSString *)urlString contentOffsetY:(CGFloat)contenOffsetY {
//    if ( nil == urlString || 0 == urlString.length ) {
//        return;
//    }
    NSMutableArray *webViewCacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewCache];
    if ( !webViewCacheArray ) {
        webViewCacheArray = [NSMutableArray array];
        NSDictionary *webViewCacheDict = @{urlString : @(contenOffsetY)};
        [webViewCacheArray addObject:webViewCacheDict];
        [[NSUserDefaults standardUserDefaults] setObject:webViewCacheArray forKey:kWebViewCache];
    } else {
        NSMutableArray *tempArray = [webViewCacheArray mutableCopy];
        NSUInteger index = -1;
        for (NSUInteger idx = 0; idx < tempArray.count; idx++ ) {
            NSDictionary *obj = [tempArray objectAtIndex:idx];
            NSString *keyString = [[obj allKeys] firstObject];
            if ( [keyString isEqualToString:urlString] ) {
                index = idx;
                break;
            }
        }
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithObject:@(contenOffsetY) forKey:urlString];
        if ( -1 != index ) {
            [tempArray removeObjectAtIndex:index];
        }
        [tempArray addObject:dictM];
        [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:kWebViewCache];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGFloat)readWebRecordWithURLString:(NSString *)urlString {
    if ( nil == urlString || 0 == urlString.length ) {
        return 0;
    }
    
    CGFloat offsetY = 0;
    NSMutableArray *webViewCacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewCache];
    NSMutableArray *tempArray = nil;
    if ( !webViewCacheArray ) {
        return offsetY;
    } else {
        tempArray = [webViewCacheArray mutableCopy];
        for ( NSMutableDictionary *obj in tempArray ) {
            NSString *keyString = [[obj allKeys] firstObject];
            if ( [keyString isEqualToString:urlString] ) {
                offsetY = [[obj objectForKey:keyString] floatValue];
                break;
            }
        }
    }
    return offsetY;
}

- (void)clearAllWebRecord {
    NSMutableArray *webViewCacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewCache];
    if ( webViewCacheArray ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWebViewCache];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
