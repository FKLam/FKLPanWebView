//
//  FKLWebCacheTool.h
//  Pods
//
//  Created by amglfk on 16/11/15.
//
//  UIWebView 浏览记录的工具类

#import <Foundation/Foundation.h>

extern NSString const * kWebViewCache;

@interface FKLWebCacheTool : NSObject

/**
 UIWebview 浏览记录的工具类
 */
+ (instancetype)sharedInstance;

/**
 浏览记录

 @return 是否存在浏览记录
 */
- (BOOL)isExistRecordWithUrlString:(NSString *)urlString;

/**
 保存浏览记录
 */
- (void)saveWebRecordWithURLString:(NSString *)urlString contentOffsetY:(CGFloat)contenOffsetY;

/**
 读取浏览记录
 */
- (CGFloat)readWebRecordWithURLString:(NSString *)urlString;

/**
 清除浏览记录
 */
- (void)clearAllWebRecord;

@end
