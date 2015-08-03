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
#import "ASFAuthentication.h"
#import "ASFLogInViewController.h"
#import "ASFURLConnectionOperation.h"
#import "DLog.h"

typedef void (^ASFResultBlock)(NSError *error);
typedef void (^ASFResponseResultBlock)(id response, NSError *error);

static NSString *ASFRankingValue(ASFRanking ranking) {
    switch (ranking) {
        case ASFNewest: return @"newest";
        case ASFOldest: return @"oldest";
    }
}

@interface ASFFeedly () <ASFLogInViewControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) ASFAuthentication *authentication;

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
        _authentication = [ASFAuthentication restore];
        _clientID = clientID;
        _clientSecret = clientSecret;
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)loginWithViewController:(UIViewController *)controller
{
    if (![_authentication refreshToken])
    {
        ASFLogInViewController *vc = [[ASFLogInViewController alloc] initWithCliendID:_clientID
                                                                             delegate:self];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [nc setModalPresentationStyle:UIModalPresentationFullScreen];
        [controller presentViewController:nc animated:YES completion:NULL];
    }
    else
    {
        [self finishAuthentication:_authentication];
    }
}

- (void)logout
{
    [ASFAuthentication reset];
    [self setAuthentication:nil];
}

#pragma mark - ASFLogInViewControllerDelegate

- (void)feedlyClientAuthenticationViewController:(ASFLogInViewController *)vc
                               didFinishWithCode:(NSString *)code
{
    ASFAuthentication *authentication = [ASFAuthentication authenticationWithCode:code];
    [self finishAuthentication:authentication];
}

- (void)finishAuthentication:(ASFAuthentication *)authentication
{
    [self setAuthentication:authentication];
    [ASFAuthentication store:authentication];
    
    if ([_delegate respondsToSelector:@selector(feedlyClientDidFinishLogin:)])
    {
        [_delegate feedlyClientDidFinishLogin:self];
    }
}

#pragma mark - Get

- (void)getCategories
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ASFEndpoint, @"categories"]];
    
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error) {
             DLog(@"%@", error);
         }
     }];
}

- (void)getSubscriptions
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ASFEndpoint, ASFSubscriptionsPath]];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error) {
             DLog(@"%@", error);
         }
         [weak parseSubscriptions:response];
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
    
    NSURL *URL = [ASFUtil URLWithString:[NSString stringWithFormat:@"%@/%@", ASFEndpoint, ASFStreamsContentsPath]
                             parameters:parameters];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error) {
             DLog(@"%@", error);
         }
         [weak parseStream:response];
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
    
    NSURL *URL = [ASFUtil URLWithString:[NSString stringWithFormat:@"%@/%@", ASFEndpoint, ASFMarkersReadsPath]
                             parameters:parameters];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error) {
             DLog(@"%@", error);
         }
         [weak parseMarkersReads:response];
     }];
}

#pragma mark - Update

- (void)updateCategory:(NSString *)ID withLabel:(NSString *)label
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", ASFCategoriesPath, ASFURLEncodedString(ID)];
    
    [self makeRequestWithBase:ASFEndpoint path:path parameters:@{ASFLabelKey : label}];
}

- (void)updateSubscription:(NSString *)ID withTitle:(NSString *)title categories:(NSArray *)categories
{
    [self makeRequestWithBase:ASFEndpoint
                         path:ASFSubscriptionsPath
                   parameters:@{ASFIDKey : ID,
                                ASFTitleKey : title,
                                ASFCategoriesKey : categories}];
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
    
    [self makeRequestWithBase:ASFEndpoint
                         path:ASFMarkersPath
                   parameters:parameters];
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
    
    [self makeRequestWithBase:ASFEndpoint
                         path:ASFMarkersPath
                   parameters:parameters];
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
    
    [self makeRequestWithBase:ASFEndpoint
                         path:ASFMarkersPath
                   parameters:parameters];
}

- (NSString *)actionForReadState:(BOOL)state
{
    return state ? ASFMarkAsReadValue : ASFKeepUnreadValue;
}

#pragma mark - POST

- (void)makeRequestWithBase:(NSString *)base path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", base, path];
    
    NSURLRequest *request = [ASFUtil requestWithMethod:@"POST"
                                             URLString:URLString
                                            parameters:parameters
                                                 token:self.authentication.accessToken
                                                 error:nil];
    
    [self.queue addOperation:[[ASFURLConnectionOperation alloc] initWithRequest:request]];
}

#pragma mark - GET

- (void)startRequestWithURL:(NSURL *)URL completionBlock:(ASFResponseResultBlock)block
{
    [self getTokenWithblock:^(NSError *error)
     {
         if (error) {
             if (block) {
                 block(nil, error);
             }
         } else {
             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
             
             [request addValue:self.authentication.accessToken forHTTPHeaderField:@"Authorization"];
             
             [self doRequest:request completion:block];
         }
     }];
}

- (void)doRequest:(NSURLRequest *)request completion:(ASFResponseResultBlock)completion
{
    ASFURLConnectionOperation *operation =
    [[ASFURLConnectionOperation alloc] initWithRequest:request
                                            completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (completion) {
             completion(JSON, error);
         }
     }];
    
    [self.queue addOperation:operation];
}

#pragma mark - Token

- (void)getTokenWithblock:(ASFResultBlock)block
{
    if ([_authentication accessToken] == nil)
    {
        [self getAccessTokenWithBlock:block];
    }
    else if ([_authentication isTokenExpired])
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
    NSDictionary *parameters = @{ASFCodeKey : [_authentication code],
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
    __weak __typeof(self)weak = self;
    [self doRequest:request completion:^(id response, NSError *error)
     {
         if (!error)
         {
             [weak parseAuthentication:response];
         }
         
         if (block)
         {
             block(error);
         }
     }];
}

- (void)refreshTokenWithBlock:(ASFResultBlock)block
{
    NSDictionary *parameters = @{ASFRefreshTokenKey : [_authentication refreshToken],
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
    __weak __typeof(self)weak = self;
    [self doRequest:request completion:^(id response, NSError *error)
     {
         if (!error)
         {
             [weak parseAuthentication:response];
         }
         
         if (block)
         {
             block(error);
         }
     }];
}

#pragma mark - Parse

- (void)parseAuthentication:(NSDictionary *)responce
{
    NSString *refreshToken = responce[ASFRefreshTokenKey];
    
    if (refreshToken)
    {
        [_authentication setRefreshToken:refreshToken];
    }
    
    NSString *state = responce[ASFStateKey];
    
    if (state)
    {
        [_authentication setState:state];
    }
    
    [_authentication setUserID:responce[ASFIDKey]];
    [_authentication setAccessToken:responce[ASFAccessTokenKey]];
    [_authentication setTokenType:responce[ASFTokenTypeKey]];
    [_authentication setPlan:responce[ASFPlanKey]];
    
    NSNumber *timeInterval = responce[ASFExpiresInKey];
    [_authentication setExpiresIn:[timeInterval longValue]];
    
    [ASFAuthentication store:_authentication];
}

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
