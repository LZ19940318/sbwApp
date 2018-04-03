//
//  RNCachingURLProtocol.m
//


#import "RNCachingURLProtocol.h"
#import "Reachability.h"
#import "NSString+Sha1.h"

#define WORKAROUND_MUTABLE_COPY_LEAK 0

#if WORKAROUND_MUTABLE_COPY_LEAK
static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround;

@end
#endif

@interface RNCachedData : NSObject <NSCoding>
@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, strong) NSURLRequest *redirectRequest;
@end

static NSString *RNCachingURLHeader = @"X-RNCache";

@interface RNCachingURLProtocol () // <NSURLConnectionDelegate, NSURLConnectionDataDelegate> iOS5-only
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end

static NSObject *RNCachingSupportedSchemesMonitor;
static NSSet *RNCachingSupportedSchemes;

@implementation RNCachingURLProtocol
@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

+ (void)initialize
{
  if (self == [RNCachingURLProtocol class])
  {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      RNCachingSupportedSchemesMonitor = [NSObject new];
    });
        
    [self setSupportedSchemes:[NSSet setWithObject:@"http"]];
  }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  // only handle http requests we haven't marked with our header.
    if (([[self supportedSchemes] containsObject:[[request URL] scheme]] &&
         ([request valueForHTTPHeaderField:RNCachingURLHeader] == nil)))
  {
    return YES;
  }
  return NO;
//    NSURLRequestUseProtocolCachePolicy = 0,
//    
//    NSURLRequestReloadIgnoringLocalCacheData = 1,
//    NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4, // Unimplemented
//    NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
//    
//    NSURLRequestReturnCacheDataElseLoad = 2,
//    NSURLRequestReturnCacheDataDontLoad = 3,
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest
{
  // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
  NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
  NSString *fileName = [[[aRequest URL] absoluteString] sha1];

  return [cachesPath stringByAppendingPathComponent:fileName];
}

- (void)startLoading
{
  if (![self useCache]) {
//      RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
//      if (cache) {
//          NSData *data = [cache data];
//          NSURLResponse *response = [cache response];
//          NSURLRequest *redirectRequest = [cache redirectRequest];
//          if (redirectRequest) {
//              [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
//          } else {
//              
//              [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
//              [[self client] URLProtocol:self didLoadData:data];
//              [[self client] URLProtocolDidFinishLoading:self];
//          }
//      }
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
                if (cache) {
                    NSData *data = [cache data];
                    NSURLResponse *response = [cache response];
                    NSURLRequest *redirectRequest = [cache redirectRequest];
                    if (redirectRequest) {
                        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
                    } else {
          
                        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed]; // we handle caching ourselves.
                        [[self client] URLProtocol:self didLoadData:data];
                        [[self client] URLProtocolDidFinishLoading:self];
                    }
                }
//
      });

    NSMutableURLRequest *connectionRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
      [[self request] mutableCopyWorkaround];
#else
      [[self request] mutableCopy];
#endif
//
//    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
    [connectionRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                delegate:self];
    [self setConnection:connection];
    }else {
    RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
    if (cache) {
      NSData *data = [cache data];
      NSURLResponse *response = [cache response];
      NSURLRequest *redirectRequest = [cache redirectRequest];
      if (redirectRequest) {
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
      } else {
          
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
        [[self client] URLProtocol:self didLoadData:data];
        [[self client] URLProtocolDidFinishLoading:self];
        
          NSMutableURLRequest *connectionRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
          [[self request] mutableCopyWorkaround];
#else
          [[self request] mutableCopy];
#endif
          //
          //    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
          [connectionRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];
          NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                      delegate:self];
          [self setConnection:connection];
      }
    }
    else {
      [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
    }
  }
}

- (void)stopLoading
{
  [[self connection] cancel];
}

// NSURLConnection delegates (generally we pass these on to our client)

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
// Thanks to Nick Dowell https://gist.github.com/1885821
  if (response != nil) {
      NSMutableURLRequest *redirectableRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
      [request mutableCopyWorkaround];
#else
      [request mutableCopy];
#endif
    // We need to remove our header so we know to handle this request and cache it.
    // There are 3 requests in flight: the outside request, which we handled, the internal request,
    // which we marked with our header, and the redirectableRequest, which we're modifying here.
    // The redirectable request will cause a new outside request from the NSURLProtocolClient, which 
    // must not be marked with our header.
    [redirectableRequest setValue:nil forHTTPHeaderField:RNCachingURLHeader];

    NSString *cachePath = [self cachePathForRequest:[self request]];
    RNCachedData *cache = [RNCachedData new];
    [cache setResponse:response];
    [cache setData:[self data]];
      
    [cache setRedirectRequest:redirectableRequest];
    [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
    return redirectableRequest;
  } else {
    return request;
  }
//    if ([response isKindOfClass:[NSHTTPURLResponse class]])
//    {
//        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//        if ([HTTPResponse statusCode] == 301 || [HTTPResponse statusCode] == 302)
//        {
//            NSMutableURLRequest *mutableRequest = [request mutableCopy];
//            [mutableRequest setURL:[NSURL URLWithString:[[HTTPResponse allHeaderFields] objectForKey:@"Location"]]];
//            request = [mutableRequest copy];
//            [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
//        }
//    }
//    return request;

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"hitongRNRN%@", dataString);
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
              if (cache) {
                  NSData *data1 = [cache data];
                  NSURLResponse *response = [cache response];
                  NSURLRequest *redirectRequest = [cache redirectRequest];
                  if (redirectRequest) {
                      [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
                  } else {
                      
                      [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
                      [[self client] URLProtocol:self didLoadData:data1];
                      [[self client] URLProtocolDidFinishLoading:self];
                      
                  }
              }
              else {
                  [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
              }
          });

  [[self client] URLProtocol:self didLoadData:data];
  [self appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [[self client] URLProtocol:self didFailWithError:error];
  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}
//- (void)URLProtocol:(NSURLProtocol*)protocol didLoadData:(NSData *)data{
//    NSLog(@"222%@" , data);
//    [[self client] URLProtocol:self didLoadData:data];
//    [self appendData:data];
//}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [self setResponse:response];
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [[self client] URLProtocolDidFinishLoading:self];

  NSString *cachePath = [self cachePathForRequest:[self request]];
  RNCachedData *cache = [RNCachedData new];
  [cache setResponse:[self response]];
  [cache setData:[self data]];
  [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];

  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}

- (BOOL) useCache 
{
    BOOL reachable = (BOOL) [[Reachability reachabilityWithHostName:[[[self request] URL] host]] currentReachabilityStatus] != NotReachable;
    return !reachable;
}

- (void)appendData:(NSData *)newData
{
  if ([self data] == nil) {
    [self setData:[newData mutableCopy]];
  }
  else {
    [[self data] appendData:newData];
  }
}

+ (NSSet *)supportedSchemes {
  NSSet *supportedSchemes;
  @synchronized(RNCachingSupportedSchemesMonitor)
  {
    supportedSchemes = RNCachingSupportedSchemes;
  }
  return supportedSchemes;
}

+ (void)setSupportedSchemes:(NSSet *)supportedSchemes
{
  @synchronized(RNCachingSupportedSchemesMonitor)
  {
    RNCachingSupportedSchemes = supportedSchemes;
  }
}

@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

@implementation RNCachedData
@synthesize data = data_;
@synthesize response = response_;
@synthesize redirectRequest = redirectRequest_;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:[self data] forKey:kDataKey];
  [aCoder encodeObject:[self response] forKey:kResponseKey];
  [aCoder encodeObject:[self redirectRequest] forKey:kRedirectRequestKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self != nil) {
    [self setData:[aDecoder decodeObjectForKey:kDataKey]];
    [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
    [self setRedirectRequest:[aDecoder decodeObjectForKey:kRedirectRequestKey]];
  }

  return self;
}

@end

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:[self timeoutInterval]];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    if ([self HTTPBodyStream]) {
        [mutableURLRequest setHTTPBodyStream:[self HTTPBodyStream]];
    } else {
        [mutableURLRequest setHTTPBody:[self HTTPBody]];
    }
    [mutableURLRequest setHTTPMethod:[self HTTPMethod]];
    
    return mutableURLRequest;
}

@end
#endif
