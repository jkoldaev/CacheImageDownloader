//
//  CachedImage.h
//  Extensions
//
//  Created by Sergey Koldaev on 20/03/15.
//  Copyright (c) 2015 Sergey Koldaev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MaxConcurentDownloadOperationsCount 4

@interface CacheImageDownloader : NSObject

+ (void)cancelAllDownloadOperations;

- (instancetype)init;

- (UIImage*)image;

//withut operation

- (UIImage*)imageWithCachingByURL:(NSURL *)url;
- (UIImage*)imageWithCachingByURL:(NSURL *)url andCachePath:(NSString*)path;

//with operation
- (void)imageWithCachingByURL:(NSURL *)url andCompletion:(void(^)(UIImage* image))block;
- (void)imageWithURL:(NSURL *)url cachePath:(NSString*)path andCompletion:(void(^)(UIImage* image))block;

- (void)cancelDownloadOperation;
- (void)cancelWithoutBreakingDownloading;

- (BOOL)isFinished;
- (BOOL)isCancelled;
- (BOOL)isExecuting;

@end
