//
//  CachedImage.m
//  Extensions
//
//  Created by Sergey Koldaev on 20/03/15.
//  Copyright (c) 2015 Sergey Koldaev. All rights reserved.
//

#import "CacheImageDownloader.h"

@interface CacheImageDownloader (){
@private
    NSBlockOperation* _operation;
    BOOL _cancelWithoutBreaingDownloading;
    NSImage* _image;
}

@end

@implementation CacheImageDownloader

static NSString* _defaultCache;
static NSOperationQueue* _imageDownloadingQueue;

+ (void)initialize{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _defaultCache = paths[0];
    _imageDownloadingQueue = [[NSOperationQueue alloc] init];
    [_imageDownloadingQueue setMaxConcurrentOperationCount:MaxConcurentDownloadOperationsCount];
}

+ (void)cancelAllDownloadOperations{
    [_imageDownloadingQueue cancelAllOperations];
}

- (instancetype)init{
    self = [super init];
    if (self){
        _operation = nil;
        _image = nil;
        _cancelWithoutBreaingDownloading = NO;
    }
    return self;
}

- (NSImage*)image{
    return _image;
}

- (NSImage*)imageWithCachingByURL:(NSURL *)url andCachePath:(NSString *)path{
    NSUInteger downloadedFileSize = 0;
    NSUInteger urlFileSize = 0;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse* responce = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:nil];
    if ([responce respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary* head = [responce allHeaderFields];
        NSString* stringNumber = head[@"Content-Length"];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber* number = [numberFormatter numberFromString:stringNumber];
        NSLog(@"File size: %@", number);
        if (number){
            urlFileSize = [number unsignedIntegerValue];
        }
    }
    
    if (urlFileSize > 0){
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* urlPath = [url path];
        NSUInteger hash = hashByString([urlPath UTF8String]);
        NSString* cachedFilePath = [NSString stringWithFormat:@"%@/%lu.%@", path, hash, [urlPath pathExtension]];
        if ([fileManager fileExistsAtPath:cachedFilePath]){
            downloadedFileSize = [fileManager attributesOfItemAtPath:cachedFilePath error:nil].fileSize;
        }
        
        if (urlFileSize == downloadedFileSize){
            NSLog(@"File downloaded");
            _image = [[NSImage alloc] initWithContentsOfFile:cachedFilePath];
        }else{
            NSLog(@"File need download");
            [request setHTTPMethod:@"BODY"];
            NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:nil];
            if (data){
                _image = [[NSImage alloc] initWithData:data];
                [data writeToFile:cachedFilePath atomically:YES];
            }
        }
        
    }
    
    return _image;
}

- (NSImage *)imageWithCachingByURL:(NSURL *)url{
    return [[CacheImageDownloader alloc] imageWithCachingByURL:url andCachePath:_defaultCache];
}

- (void)imageWithURL:(NSURL *)url cachePath:(NSString *)path andCompletion:(void (^)(NSImage *))block{
    if (!_operation || _operation.isCancelled || _operation.isFinished){
        _cancelWithoutBreaingDownloading = NO;
        _operation = [NSBlockOperation blockOperationWithBlock:^{
            
            NSUInteger downloadedFileSize = 0;
            NSUInteger urlFileSize = 0;
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"HEAD"];
            NSHTTPURLResponse* responce = nil;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:nil];
            if ([responce respondsToSelector:@selector(allHeaderFields)]){
                NSDictionary* head = [responce allHeaderFields];
                NSString* stringNumber = head[@"Content-Length"];
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
                NSNumber* number = [numberFormatter numberFromString:stringNumber];
                NSLog(@"File size: %@", number);
                if (number){
                    urlFileSize = [number unsignedIntegerValue];
                }
            }
            
            if (urlFileSize > 0){
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSString* urlPath = [url path];
                NSUInteger hash = hashByString([urlPath UTF8String]);
                NSString* cachedFilePath = [NSString stringWithFormat:@"%@/%lu.%@", path, hash, [urlPath pathExtension]];
                if ([fileManager fileExistsAtPath:cachedFilePath]){
                    downloadedFileSize = [fileManager attributesOfItemAtPath:cachedFilePath error:nil].fileSize;
                }
                
                if (urlFileSize == downloadedFileSize){
                    NSLog(@"File downloaded");
                    _image = [[NSImage alloc] initWithContentsOfFile:cachedFilePath];
                }else{
                    NSLog(@"File need download");
                    [request setHTTPMethod:@"BODY"];
                    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:nil];
                    if (data){
                        _image = [[NSImage alloc] initWithData:data];
                        [fileManager removeItemAtPath:cachedFilePath error:nil];
                        [data writeToFile:cachedFilePath atomically:YES];
                    }
                }
                
            }
            
            if (!_cancelWithoutBreaingDownloading){
                block(_image);
            }
            
        }];
        
        [_imageDownloadingQueue addOperation:_operation];
    }
}

- (void)imageWithCachingByURL:(NSURL *)url andCompletion:(void (^)(NSImage *))block{
    [[CacheImageDownloader alloc] imageWithURL:url cachePath:_defaultCache andCompletion:block];
}

- (void)cancelDownloadOperation{
    [_operation cancel];
}

- (void)cancelWithoutBreakingDownloading{
    _cancelWithoutBreaingDownloading = YES;
}

- (BOOL)isFinished{
    return _operation.isFinished;
}

- (BOOL)isCancelled{
    return _operation.isCancelled;
}

- (BOOL)isExecuting{
    return _operation.isExecuting;
}

NSUInteger hashByString(const char* string){
    const NSUInteger key = 1204;
    NSUInteger hash = key;
    
    while (*string) {
        hash += hash * key + *string++;
    }
    return hash;
}

@end
