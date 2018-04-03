//
//  RNCachingURLProtocol.h
//  用来缓存网页数据  当断网的时候 访问存储的数据  有网络的时候  请求数据从网上

#import <Foundation/Foundation.h>

@interface RNCachingURLProtocol : NSURLProtocol

+ (NSSet *)supportedSchemes;
+ (void)setSupportedSchemes:(NSSet *)supportedSchemes;

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest;
- (BOOL) useCache;

@end
