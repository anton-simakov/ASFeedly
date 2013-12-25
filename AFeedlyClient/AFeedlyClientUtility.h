//
//  AFeedlyClientUtility.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 12/12/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFeedlyClientUtility : NSObject

+ (NSURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method;

+ (NSURL *)URLWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
+ (NSURL *)URLWithPath:(NSString *)path parameters:(NSDictionary *)parameters base:(NSString *)base;

@end
