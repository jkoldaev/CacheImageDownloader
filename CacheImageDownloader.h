//
//  CachedImage.h
//  Extensions
//
//  Created by Sergey Koldaev on 20/03/15.
//  Copyright (c) 2015 Sergey Koldaev. All rights reserved.
//

#import <AppKit/AppKit.h>

#define MaxConcurentDownloadOperationsCount 4

@interface CacheImageDownloader : NSObject

+ (void)cancelAllDownloadOperations;

- (instancetype)init;

- (NSImage*)image;

//withut operation

- (NSImage*)imageWithCachingByURL:(NSURL *)url;
- (NSImage*)imageWithCachingByURL:(NSURL *)url andCachePath:(NSString*)path;

//with operation
- (void)imageWithCachingByURL:(NSURL *)url andCompletion:(void(^)(NSImage* image))block;
- (void)imageWithURL:(NSURL *)url cachePath:(NSString*)path andCompletion:(void(^)(NSImage* image))block;

- (void)cancelDownloadOperation;
- (void)cancelWithoutBreakingDownloading;

- (BOOL)isFinished;
- (BOOL)isCancelled;
- (BOOL)isExecuting;

@end
