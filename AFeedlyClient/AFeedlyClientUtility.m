//
//  AFeedlyClientUtility.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 12/12/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientUtility.h"
#import "AFeedlyClientConstants.h"

@implementation AFeedlyClientUtility

+ (NSURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:method];
    return request;
}

+ (NSURL *)URLWithPath:(NSString *)path parameters:(NSDictionary *)parameters
{
    return [self URLWithPath:path parameters:parameters base:kFeedlyBaseURL];
}

+ (NSURL *)URLWithPath:(NSString *)path parameters:(NSDictionary *)parameters base:(NSString *)base
{
    NSString *query = [NSString string];
    
    for (NSString *key in [parameters allKeys])
    {
        NSString *value = parameters[key];
        query = [query stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, value]];
    }
    
    if ([query length])
    {
        query = [query stringByReplacingCharactersInRange:NSMakeRange([query length] - 1, 1) withString:@""];
        query = [NSString stringWithFormat:@"?%@", query];
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@%@", base, path, query];
    return [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
