//
//  ASFRequestBuilder.m
//  ASFFeedly
//
//  Created by Anton Simakov on 12/12/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFRequestBuilder.h"
#import "ASFConstants.h"

static NSString *ASFURLEncodedPair(id field, id value) {
    if (!value || [value isEqual:[NSNull null]]) {
        return ASFURLEncodedString([field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@",
                ASFURLEncodedString([field description]),
                ASFURLEncodedString([value description])];
    }
}

NSURL *ASFURLByAppendingParameters(NSURL *URL, NSDictionary *parameters) {
    if (!parameters || ![parameters count]) {
        return URL;
    }
    
    NSString *query = ASFQueryFromParameters(parameters);
    
    NSString *absoluteString = [URL absoluteString];
    if ([absoluteString rangeOfString:@"?"].location == NSNotFound) {
        absoluteString = [NSString stringWithFormat:@"%@?%@", absoluteString, query];
    } else {
        absoluteString = [NSString stringWithFormat:@"%@&%@", absoluteString, query];
    }
    
    return [NSURL URLWithString:absoluteString];
}

NSString *ASFQueryFromURL(NSURL *URL) {
    NSArray *components = [[URL absoluteString] componentsSeparatedByString:@"?"];
    return [components lastObject];
}

NSString *ASFQueryFromParameters(NSDictionary *parameters) {
    NSMutableArray *pairs = [NSMutableArray array];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [pairs addObject:ASFURLEncodedPair(key, obj)];
    }];
    
    return [pairs componentsJoinedByString:@"&"];
}

NSString *ASFURLEncodedString(NSString *string) {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)string,
                                                                     NULL,
                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                     kCFStringEncodingUTF8));
}

NSString *ASFURLDecodedString(NSString *string) {
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                     (__bridge CFStringRef)string,
                                                                                     CFSTR(""),
                                                                                     kCFStringEncodingUTF8));
}

NSDictionary *ASFParametersFromQuery(NSString *query) {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count == 2) {
            parameters[ASFURLDecodedString(elements[0])] = ASFURLDecodedString(elements[1]);
        }
    }
    return parameters;
}

@implementation ASFRequestBuilder

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     token:(NSString *)token
                                     error:(NSError *__autoreleasing *)error {
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSParameterAssert(URL);
    
    NSMutableURLRequest *request = [self requestWithURL:URL
                                                 method:method
                                             parameters:parameters
                                                  error:error];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL
                                 method:(NSString *)method
                             parameters:(NSDictionary *)parameters
                                  error:(NSError *__autoreleasing *)error {
    
    NSParameterAssert([method isEqualToString:@"GET"] ||
                      [method isEqualToString:@"POST"]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if ([method isEqualToString:@"GET"]) {
        request.URL = ASFURLByAppendingParameters(URL, parameters);
    } else {
        request.URL = URL;
        request.HTTPMethod = method;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:0
                                                             error:error];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    return request;
}

@end
