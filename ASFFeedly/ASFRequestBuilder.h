//
//  ASFRequestBuilder.h
//  ASFFeedly
//
//  Created by Anton Simakov on 12/12/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSURL *ASFURLByAppendingParameters(NSURL *URL, NSDictionary *parameters);
extern NSString *ASFQueryFromURL(NSURL *URL);
extern NSString *ASFQueryFromParameters(NSDictionary *parameters);
extern NSString *ASFURLEncodedString(NSString *string);
extern NSString *ASFURLDecodedString(NSString *string);
extern NSDictionary *ASFParametersFromQuery(NSString *query);

@interface ASFRequestBuilder : NSObject

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     token:(NSString *)token
                                     error:(NSError *__autoreleasing *)error;

@end
