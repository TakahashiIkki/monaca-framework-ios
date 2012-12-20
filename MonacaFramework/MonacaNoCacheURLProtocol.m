//
//  URLProtocolAbstruct.m
//  MonacaDebugger
//
//  Created by yasuhiro on 12/12/20.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaNoCacheURLProtocol.h"
#import "Device.h"

@implementation MonacaNoCacheURLProtocol

static BOOL isWork;

+ (void)offURLProtocol
{
    isWork = NO;
}

+ (void)onURLProtocol
{
    isWork = YES;
}

+ (BOOL) requestIsCacheEquivalent: (NSURLRequest*)requestA toRequest: (NSURLRequest*)requestB
{
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *cRequest = [NSMutableURLRequest requestWithURL:request.URL];
    [cRequest setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [cRequest setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    return cRequest;
}

- (NSHTTPURLResponse *)responseWithNonCacheHeader:(NSURLRequest *)request Data:(NSData *)data
{
    NSHTTPURLResponse *response;
    if ([Device iOSVersionMajor] >= 5) {
        NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [request.allHTTPHeaderFields objectForKey:@"Accept"], @"Accept",
                                 @"no-cache", @"Cache-Control",
                                 @"no-cache", @"Pragma",
                                 [NSString stringWithFormat:@"%d", [data length]], @"Content-Length",
                                 nil];
        response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                               statusCode:200
                                              HTTPVersion:@"1.1"
                                             headerFields:headers];
    } else {
        response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                 MIMEType:[request.allHTTPHeaderFields objectForKey:@"Accept"]
                                    expectedContentLength:[data length]
                                         textEncodingName:nil];
    }
    return response;
}

@end
