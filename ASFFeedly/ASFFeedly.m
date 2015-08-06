//
//  ASFFeedly.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFFeedly.h"
#import "ASFConstants.h"
#import "ASFUtil.h"
#import "ASFStream.h"
#import "ASFEntry.h"
#import "ASFCredential.h"
#import "ASFLogInViewController.h"
#import "ASFURLConnectionOperation.h"
#import "DLog.h"

typedef void (^ASFResultBlock)(NSError *error);

@interface ASFFeedly ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) ASFCredential *credential;

@end

@implementation ASFFeedly

- (instancetype)init {
    return [self initWithClientID:nil
                     clientSecret:nil];
}

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret {
    
    if (!clientID || ![clientID length]) {
        DLog(@"Client ID is nil or empty.");
        return nil;
    }
    
    if (!clientSecret || ![clientSecret length]) {
        DLog(@"Client secret is nil or empty.");
        return nil;
    }
    
    self = [super init];
    if (self) {
        _credential = [ASFCredential retrieveCredential];
        _clientID = clientID;
        _clientSecret = clientSecret;
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (BOOL)isAuthorized {
    return [ASFLogInViewController code] || self.credential;
}

- (void)subscriptions:(void(^)(NSArray *subscriptions, NSError *error))completion {
    [self doRequest:@"GET"
               path:ASFSubscriptionsPath
         parameters:nil
         completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (error) {
             completion(nil, error);
         } else {
             NSMutableArray *subscriptions = [NSMutableArray array];
             for (NSDictionary *subscription in JSON) {
                 [subscriptions addObject:[[ASFSubscription alloc] initWithDictionary:subscription]];
             }
             
             completion(subscriptions, nil);
         }
     }];
}

- (void)stream:(NSString *)streamID completion:(void(^)(ASFStream *stream, NSError *error))completion {
    
    NSDictionary *parameters = @{ASFStreamIDKey : streamID};
    
    [self doRequest:@"GET"
               path:ASFStreamsContentsPath
         parameters:parameters
         completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (error) {
             completion(nil, error);
         } else {
             completion([[ASFStream alloc] initWithDictionary:JSON], nil);
         }
     }];
}

- (void)getMarkersReads
{
    [self getMarkersReadsNewerThan:0];
}

- (void)getMarkersReadsNewerThan:(long long)newerThan
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (newerThan)
    {
        [parameters setValue:@(newerThan + 1) forKey:ASFNewerThanKey];
    }
    
    [self doRequest:@"GET"
               path:ASFMarkersReadsPath
         parameters:parameters
         completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         // TODO:
     }];
}

#pragma mark - Update

- (void)updateCategory:(NSString *)ID withLabel:(NSString *)label
{
    NSDictionary *parameters = @{ASFLabelKey : label};
    
    [self doRequest:@"POST"
               path:ASFCategoriesPath
         parameters:parameters
         completion:nil];
}

- (void)updateSubscription:(NSString *)ID withTitle:(NSString *)title categories:(NSArray *)categories
{
    NSDictionary *parameters = @{ASFIDKey : ID,
                                 ASFTitleKey : title,
                                 ASFCategoriesKey : categories};
    [self doRequest:@"POST"
               path:ASFSubscriptionsPath
         parameters:parameters
         completion:nil];
}

#pragma mark - Mark

- (void)markEntry:(NSString *)ID read:(BOOL)read
{
    [self markEntries:@[ID] read:read];
}

- (void)markEntries:(NSArray *)IDs read:(BOOL)read
{
    NSDictionary *parameters = @{ASFActionKey : [self actionForReadState:read],
                                 ASFTypeKey : ASFEntriesValue,
                                 ASFEntryIDsKey : IDs};
    [self doRequest:@"POST"
               path:ASFMarkersPath
         parameters:parameters
         completion:nil];
}

- (void)markCategory:(NSString *)ID read:(BOOL)read
{
    [self markCategories:@[ID] read:YES];
}

- (void)markCategories:(NSArray *)IDs read:(BOOL)read
{
    NSDictionary *parameters = @{ASFActionKey : [self actionForReadState:read],
                                 ASFTypeKey : ASFCategoriesValue,
                                 ASFCategoryIDsKey : IDs};
    
    [self doRequest:@"POST"
               path:ASFMarkersPath
         parameters:parameters
         completion:nil];
}

- (void)markSubscription:(NSString *)ID read:(BOOL)read
{
    [self markSubscriptions:@[ID] read:read];
}

- (void)markSubscriptions:(NSArray *)IDs read:(BOOL)read
{
    NSDictionary *parameters = @{ASFActionKey : [self actionForReadState:read],
                                 ASFTypeKey : ASFFeedsValue,
                                 ASFFeedIDsKey : IDs};
    
    [self doRequest:@"POST"
               path:ASFMarkersPath
         parameters:parameters
         completion:nil];
}

- (NSString *)actionForReadState:(BOOL)state
{
    return state ? ASFMarkAsReadValue : ASFKeepUnreadValue;
}

#pragma mark - Request

- (void)doRequest:(NSString *)method
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
       completion:(ASFURLConnectionOperationCompletion)completion {
    
    [self token:^(NSString *token, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, nil, error);
            }
        } else {
            NSMutableURLRequest *request = [ASFUtil requestWithMethod:method
                                                            URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", path]
                                                           parameters:parameters
                                                                token:token
                                                                error:nil];
            [self doRequest:request completion:completion];
        }
    }];
}

- (void)doRequest:(NSURLRequest *)request completion:(ASFURLConnectionOperationCompletion)completion
{
    ASFURLConnectionOperation *operation =
    [[ASFURLConnectionOperation alloc] initWithRequest:request
                                            completion:completion];
    [self.queue addOperation:operation];
}

#pragma mark - Token

- (void)token:(void(^)(NSString *token, NSError *error))completion {
    
    NSParameterAssert(completion);
    
    if (self.credential.accessToken) {
        if (self.credential.isExpired) {
            NSDictionary *parameters = @{@"refresh_token" : self.credential.refreshToken,
                                         @"client_id" : self.clientID,
                                         @"client_secret" : self.clientSecret,
                                         @"grant_type" : @"refresh_token"};
            
            [self tokenWithParameters:parameters
                           completion:completion];
        } else {
            completion(self.credential.accessToken, nil);
        }
    } else {
        NSDictionary *parameters = @{@"code" : [ASFLogInViewController code],
                                     @"client_id" : self.clientID,
                                     @"client_secret" : self.clientSecret,
                                     @"redirect_uri" : ASFRedirectURI,
                                     @"grant_type" : @"authorization_code"};
        
        [self tokenWithParameters:parameters
                       completion:completion];
    }
}

- (void)tokenWithParameters:(NSDictionary *)parameters
                 completion:(void(^)(NSString *token, NSError *error))completion {
    
    NSError *error;
    NSURLRequest *request = [ASFUtil requestWithMethod:@"POST"
                                             URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFAuthTokenPath]
                                            parameters:parameters
                                                 token:nil
                                                 error:&error];
    if (error) {
        completion(nil, error);
        return;
    }
    
    [self doRequest:request completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            self.credential = [[ASFCredential alloc] initWithDictionary:JSON];
            [ASFCredential storeCredential:self.credential];
            completion(self.credential.accessToken, nil);
        }
    }];
}

@end
