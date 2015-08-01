//
//  ASFURLConnectionOperation.h
//  ASFFeedly
//
//  Created by Anton Simakov on 7/31/15.
//  Copyright (c) 2015 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASFURLConnectionOperation;

extern NSString *const ASFErrorDomain;

typedef void (^ASFURLConnectionOperationCompletion)(ASFURLConnectionOperation *operation, id JSON, NSError *error);

@interface ASFURLConnectionOperation : NSOperation

@property (strong, readonly) NSURLRequest *request;

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (instancetype)initWithRequest:(NSURLRequest *)request
                     completion:(ASFURLConnectionOperationCompletion)completion NS_DESIGNATED_INITIALIZER;

@end
