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

static NSString *_code;

static NSString *ASFRankingValue(ASFRanking ranking) {
    switch (ranking) {
        case ASFNewest: return @"newest";
        case ASFOldest: return @"oldest";
    }
}

@interface ASFFeedly () <ASFLogInViewControllerDelegate>

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

- (void)loginWithViewController:(UIViewController *)controller {
    if (self.credential.refreshToken || _code) {
        if ([self.delegate respondsToSelector:@selector(feedlyClientDidFinishLogin:)]) {
            [self.delegate feedlyClientDidFinishLogin:self];
        }
    } else {
        ASFLogInViewController *vc = [[ASFLogInViewController alloc] initWithCliendID:_clientID
                                                                             delegate:self];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [nc setModalPresentationStyle:UIModalPresentationFullScreen];
        [controller presentViewController:nc animated:YES completion:NULL];
    }
}

#pragma mark - ASFLogInViewControllerDelegate

- (void)feedlyClientAuthenticationViewController:(ASFLogInViewController *)vc
                               didFinishWithCode:(NSString *)code {
    _code = code;
    if ([self.delegate respondsToSelector:@selector(feedlyClientDidFinishLogin:)]) {
        [self.delegate feedlyClientDidFinishLogin:self];
    }
}

#pragma mark - Get

- (void)getCategories
{
    // TODO:
}

- (void)getSubscriptions
{
    [self doRequestWithMethod:@"GET"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFSubscriptionsPath]
                   parameters:nil
                   completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         [self parseSubscriptions:JSON];
     }];
}

- (void)getStream:(NSString *)streamID
{
    [self getStream:streamID count:0 ranking:ASFNewest unreadOnly:YES newerThan:0 continuation:nil];
}

- (void)getStream:(NSString *)streamID
            count:(NSUInteger)count
          ranking:(ASFRanking)ranking
       unreadOnly:(BOOL)unreadOnly
        newerThan:(long long)newerThan
     continuation:(NSString *)continuation
{
    if (!streamID) {
        DLog(@"Stream identifier is nil.");
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:streamID
                                                                         forKey:ASFStreamIDKey];
    count = MIN(count, ASFStreamCountMax);
    
    if (count)
    {
        [parameters setValue:@(count) forKey:ASFCountKey];
    }
    
    if (unreadOnly)
    {
        [parameters setValue:ASFFeedTrueValue forKey:ASFUnreadOnlyKey];
    }
    
    if (newerThan)
    {
        [parameters setValue:@(newerThan + 1) forKey:ASFNewerThanKey];
    }
    
    if (continuation)
    {
        [parameters setValue:continuation forKey:ASFContinuationKey];
    }
    
    [parameters setValue:ASFRankingValue(ASFNewest) forKey:ASFRankedKey];
    
    [self doRequestWithMethod:@"GET"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFStreamsContentsPath]
                   parameters:parameters
                   completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         [self parseStream:JSON];
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
    
    [self doRequestWithMethod:@"GET"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFMarkersReadsPath]
                   parameters:parameters
                   completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         [self parseMarkersReads:JSON];
     }];
}

#pragma mark - Update

- (void)updateCategory:(NSString *)ID withLabel:(NSString *)label
{
    NSDictionary *parameters = @{ASFLabelKey : label};
    
    [self doRequestWithMethod:@"POST"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFCategoriesPath]
                   parameters:parameters
                   completion:nil];
}

- (void)updateSubscription:(NSString *)ID withTitle:(NSString *)title categories:(NSArray *)categories
{
    NSDictionary *parameters = @{ASFIDKey : ID,
                                 ASFTitleKey : title,
                                 ASFCategoriesKey : categories};
    
    [self doRequestWithMethod:@"POST"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFSubscriptionsPath]
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
    
    [self doRequestWithMethod:@"POST"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFMarkersPath]
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
    
    [self doRequestWithMethod:@"POST"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFMarkersPath]
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
    
    [self doRequestWithMethod:@"POST"
                    URLString:[ASFEndpoint stringByAppendingFormat:@"/%@", ASFMarkersPath]
                   parameters:parameters
                   completion:nil];
}

- (NSString *)actionForReadState:(BOOL)state
{
    return state ? ASFMarkAsReadValue : ASFKeepUnreadValue;
}

#pragma mark - Request

- (void)doRequestWithMethod:(NSString *)method
                  URLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                 completion:(ASFURLConnectionOperationCompletion)completion {
    
    [self getTokenWithblock:^(NSError *error)
     {
         if (error) {
             if (completion) {
                 completion(nil, nil, error);
             }
             return;
         } else {
             NSMutableURLRequest *request = [ASFUtil requestWithMethod:method
                                                             URLString:URLString
                                                            parameters:parameters
                                                                 token:self.credential.accessToken
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

- (void)getTokenWithblock:(ASFResultBlock)block
{
    if ([_credential accessToken] == nil)
    {
        [self getAccessTokenWithBlock:block];
    }
    else if ([_credential isExpired])
    {
        [self refreshTokenWithBlock:block];
    }
    else
    {
        if (block)
        {
            block(nil);
        }
    }
}

- (void)getAccessTokenWithBlock:(ASFResultBlock)block
{
    NSParameterAssert(block);
    NSParameterAssert(_code);
    NSDictionary *parameters = @{ASFCodeKey : _code,
                                 ASFClientIDKey : _clientID,
                                 ASFClientSecretKey : _clientSecret,
                                 ASFRedirectURIKey : ASFRedirectURI,
                                 ASFGrantTypeKey : ASFGrantTypeAuthorizationCode};
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",
                           ASFEndpoint,
                           ASFAuthTokenPath];
    
    NSURLRequest *request = [ASFUtil requestWithMethod:@"POST"
                                             URLString:URLString
                                            parameters:parameters
                                                 token:nil
                                                 error:nil];
    
    [self doRequest:request completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (!error) {
             self.credential = [[ASFCredential alloc] initWithDictionary:JSON];
             [ASFCredential storeCredential:self.credential];
         }
         block(error);
     }];
}

- (void)refreshTokenWithBlock:(ASFResultBlock)block
{
    NSParameterAssert(block);
    NSDictionary *parameters = @{ASFRefreshTokenKey : [_credential refreshToken],
                                 ASFClientIDKey : _clientID,
                                 ASFClientSecretKey : _clientSecret,
                                 ASFGrantTypeKey : ASFGrantTypeRefreshToken};
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",
                           ASFEndpoint,
                           ASFAuthTokenPath];
    
    NSURLRequest *request = [ASFUtil requestWithMethod:@"POST"
                                             URLString:URLString
                                            parameters:parameters
                                                 token:nil
                                                 error:nil];
    [self doRequest:request completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (!error) {
             self.credential = [[ASFCredential alloc] initWithDictionary:JSON];
             [ASFCredential storeCredential:self.credential];
         }
         block(error);
     }];
}

#pragma mark - Parse

- (void)parseSubscriptions:(NSArray *)response
{
    NSMutableArray *subscriptions = [NSMutableArray array];
    
    for (NSDictionary *subscriptionDictionary in response)
    {
        ASFSubscription *subscription = [ASFSubscription new];
        
        [subscription setID: subscriptionDictionary[ASFIDKey]];
        [subscription setTitle: subscriptionDictionary[ASFTitleKey]];
        [subscription setWebsite:subscriptionDictionary[ASFWebsiteKey]];
        
        NSTimeInterval updated = [subscriptionDictionary[ASFUpdatedKey] longLongValue];
        
        [subscription setUpdated:[NSDate dateWithTimeIntervalSince1970:updated]];
        
        NSMutableArray *categories = [NSMutableArray array];
        NSArray *categoriesResponse = subscriptionDictionary[ASFCategoriesKey];
        
        for (NSDictionary *categoryDictionary in categoriesResponse)
        {
            ASFCategory *category = [ASFCategory new];
            
            [category setID:categoryDictionary[ASFIDKey]];
            [category setLabel:categoryDictionary[ASFLabelKey]];
            
            [categories addObject:category];
        }
        
        [subscription setCategories:categories];
        
        [subscriptions addObject:subscription];
    }
    
    if ([_delegate respondsToSelector:@selector(feedlyClient:didLoadSubscriptions:)])
    {
        [_delegate feedlyClient:self didLoadSubscriptions:subscriptions];
    }
}

- (void)parseStream:(NSDictionary *)response
{
    ASFStream *stream = [ASFStream new];
    
    [stream setID:response[ASFIDKey]];
    [stream setTitle:response[ASFTitleKey]];
    [stream setDirection:response[ASFDirectionKey]];
    [stream setContinuation:response[ASFContinuationKey]];
    [stream setUpdated:[response[ASFUpdatedKey] longLongValue]];
    
    NSArray *items = response[ASFItemsKey];
    [stream setItems:[self parseEntries:items]];
    
    if ([_delegate respondsToSelector:@selector(feedlyClient:didLoadStream:)])
    {
        [_delegate feedlyClient:self didLoadStream:stream];
    }
}

- (NSArray *)parseEntries:(NSArray *)items
{
    NSMutableArray *entries = [NSMutableArray array];
    
    for (NSDictionary *item in items)
    {
        ASFEntry *entry = [self parseEntry:item];
        [entries addObject:entry];
    }
    
    return entries;
}

- (ASFEntry *)parseEntry:(NSDictionary *)item
{
    ASFEntry *entry = [ASFEntry new];
    
    [entry setID:item[ASFIDKey]];
    [entry setTitle:item[ASFTitleKey]];
    [entry setAuthor:item[ASFAuthorKey]];
    [entry setOriginID:item[ASFOriginIDKey]];
    
    [entry setContent:item[ASFSummaryKey][ASFContentKey]];
    [entry setUnread:[item[ASFUnreadKey] boolValue]];
    [entry setEngagement:[item[ASFEngagementKey] longValue]];
    [entry setImageURLString:item[ASFVisualKey][ASFURLKey]];
    [entry setPublished:[item[ASFPublishedKey] longLongValue]];
    
    return entry;
}

- (void)parseMarkersReads:(NSDictionary *)response
{
    NSLog(@"%@", response);
}

@end
