//
//  ASFURLConnectionOperation.m
//  ASFFeedly
//
//  Created by Anton Simakov on 7/31/15.
//  Copyright (c) 2015 Anton Simakov. All rights reserved.
//

#import "ASFURLConnectionOperation.h"
#import "DLog.h"

NSString *const ASFErrorDomain = @"ASFErrorDomain";

@interface ASFURLConnectionOperation ()

@property (nonatomic, copy) ASFURLConnectionOperationCompletion completion;

@end

@implementation ASFURLConnectionOperation

- (instancetype)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request completion:nil];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                     completion:(ASFURLConnectionOperationCompletion)completion {
    NSParameterAssert(request);
    self = [super init];
    if (self) {
        _request = request;
        _completion = completion;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        NSURLResponse *response;
        NSError *error;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:self.request
                                             returningResponse:&response
                                                         error:&error];
        [self didLoadData:data
                 response:response
                    error:error];
    }
}

- (void)didLoadData:(NSData *)data
           response:(NSURLResponse *)response
              error:(NSError *)error {
    
    if (error) {
        [self didLoadJSON:nil error:error];
    } else {
        NSError *error;
        id JSON = [self JSONForResponse:response
                                   data:data
                                  error:&error];
        
        [self didLoadJSON:JSON error:error];
    }
}

- (void)didLoadJSON:(id)JSON error:(NSError *)error {
    
    if (self.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completion(self, JSON, error);
            self.completion = nil;
        });
    }
}

- (id)JSONForResponse:(NSURLResponse *)response
                 data:(NSData *)data
                error:(NSError *__autoreleasing *)error {
    
    if (![self validateResponse:(NSHTTPURLResponse *)response error:error]) {
        return nil;
    }
    
    if (![data length]) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:error];
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                   error:(NSError *__autoreleasing *)error {
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        DLog(@"Got response: %@ (%ld)", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (long)response.statusCode);
        // TODO:
    }
    return YES;
}

@end
