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
#import "ASFSignInViewController.h"
#import "ASFURLConnectionOperation.h"
#import "DLog.h"

typedef void (^ASFResultBlock)(NSError *error);
typedef void (^ASFResponseResultBlock)(id response, NSError *error);

const CGFloat ASFStreamEntriesMax = 10000;

NSString * rankingStrings[2] =
{
    @"newest",
    @"oldest"
};

NSString * ASFRankingString(ASFRanking ranking)
{
    return rankingStrings[ranking];
}

@interface ASFFeedly ()<ASFSignInViewControllerDelegate>

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
        ASFSignInViewController *vc = [[ASFSignInViewController alloc] initWithCliendID:_clientID
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

#pragma mark - ASFSignInViewControllerDelegate

- (void)feedlyClientAuthenticationViewController:(ASFSignInViewController *)vc
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
    NSURL *URL = [ASFUtil URLWithPath:@"categories" parameters:nil];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error)
         {
             [weak handleError:error];
         }
         else
         {
             // parse categories
         }
     }];
}

- (void)getSubscriptions
{
    NSURL *URL = [ASFUtil URLWithPath:ASFSubscriptionsPath parameters:nil];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error)
         {
             [weak handleError:error];
         }
         else
         {
             [weak parseSubscriptions:response];
         }
     }];
}

- (void)getStream:(NSString *)streamID
{
    [self getStream:streamID count:0 ranking:ASFRankingDefault unreadOnly:YES newerThan:0 continuation:nil];
}

- (void)getStream:(NSString *)streamID
            count:(NSInteger)count
          ranking:(ASFRanking)ranking
       unreadOnly:(BOOL)unreadOnly
        newerThan:(long long)newerThan
     continuation:(NSString *)continuation
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:streamID
                                                                         forKey:ASFStreamIDKey];
    if (count)
    {
        [parameters setValue:@(count) forKey:ASFCountKey];
    }
    
    if (ranking != ASFRankingDefault)
    {
        [parameters setValue:ASFRankingString(ASFRankingNewest) forKey:ASFRankedKey];
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
    
    NSURL *URL = [ASFUtil URLWithPath:ASFStreamsContentsPath parameters:parameters];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error)
         {
             [weak handleError:error];
         }
         else
         {
             [weak parseStream:response];
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
    
    NSURL *URL = [ASFUtil URLWithPath:ASFMarkersReadsPath parameters:parameters];
    
    __weak __typeof(self)weak = self;
    [self startRequestWithURL:URL completionBlock:^(id response, NSError *error)
     {
         if (error)
         {
             [weak handleError:error];
         }
         else
         {
             [weak parseMarkersReads:response];
         }
     }];
}

#pragma mark - Update

- (void)updateCategory:(NSString *)ID withLabel:(NSString *)label
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", ASFCategoriesPath, [ASFUtil encodeString:ID]];
    
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
    [self makeRequestWithPath:ASFMarkersPath parameters:@{ASFActionKey : [self actionForReadState:read],
                                                              ASFTypeKey : ASFEntriesValue,
                                                              ASFEntryIDsKey : IDs}];
}

- (void)markCategory:(NSString *)ID read:(BOOL)read
{
    [self markCategories:@[ID] read:YES];
}

- (void)markCategories:(NSArray *)IDs read:(BOOL)read
{
    [self makeRequestWithPath:ASFMarkersPath parameters:@{ASFActionKey : [self actionForReadState:read],
                                                              ASFTypeKey : ASFCategoriesValue,
                                                              ASFCategoryIDsKey : IDs}];
}

- (void)markSubscription:(NSString *)ID read:(BOOL)read
{
    [self markSubscriptions:@[ID] read:read];
}

- (void)markSubscriptions:(NSArray *)IDs read:(BOOL)read
{
    [self makeRequestWithPath:ASFMarkersPath parameters:@{ASFActionKey : [self actionForReadState:read],
                                                              ASFTypeKey : ASFFeedsValue,
                                                              ASFFeedIDsKey : IDs}];
}

- (NSString *)actionForReadState:(BOOL)state
{
    return state ? ASFMarkAsReadValue : ASFKeepUnreadValue;
}

#pragma mark - Requests

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError *__autoreleasing *)error {
    
    NSParameterAssert([method isEqualToString:@"GET"] ||
                      [method isEqualToString:@"POST"]);
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSParameterAssert(URL);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"GET"]) {
        //
    } else {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self.authentication accessToken] forHTTPHeaderField:@"Authorization"];
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:error]];
    }
    
    return request;
}

#pragma mark - POST

- (void)makeRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
{
    [self makeRequestWithBase:ASFEndpoint path:path parameters:parameters];
}

- (void)makeRequestWithBase:(NSString *)base path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", base, path];
    
    NSURLRequest *request = [self requestWithMethod:@"POST"
                                          URLString:URLString
                                         parameters:parameters
                                              error:nil];
    
    [self.queue addOperation:[[ASFURLConnectionOperation alloc] initWithRequest:request]];
}

#pragma mark - GET

- (void)startRequestWithURL:(NSURL *)URL completionBlock:(ASFResponseResultBlock)block
{
    __weak __typeof(self)weak = self;
    [self getTokenWithblock:^(NSError *error)
     {
         if (error)
         {
             [weak handleError:error];
         }
         else
         {
             [weak startRequestWithURL:URL authorized:YES completionBlock:block];
         }
     }];
}

- (void)startRequestWithURL:(NSURL *)URL authorized:(BOOL)authorized completionBlock:(ASFResponseResultBlock)block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    if (authorized)
    {
        [self authorizeRequest:request];
    }
    
    [self startRequest:request completionBlock:block];
}

- (void)startRequest:(NSURLRequest *)request completionBlock:(ASFResponseResultBlock)block
{
    ASFURLConnectionOperation *operation =
    [[ASFURLConnectionOperation alloc] initWithRequest:request
                                            completion:^(ASFURLConnectionOperation *operation, id JSON, NSError *error)
     {
         if (block) {
             block(JSON, error);
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
    
    NSURL *URL = [ASFUtil URLWithPath:ASFAuthTokenPath parameters:parameters];
    NSURLRequest *request = [ASFUtil requestWithURL:URL method:@"POST"];
    
    __weak __typeof(self)weak = self;
    [self startRequest:request completionBlock:^(id response, NSError *error)
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
    
    NSURL *URL = [ASFUtil URLWithPath:ASFAuthTokenPath parameters:parameters];
    NSURLRequest *request = [ASFUtil requestWithURL:URL method:@"POST"];
    
    __weak __typeof(self)weak = self;
    [self startRequest:request completionBlock:^(id response, NSError *error)
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

- (void)authorizeRequest:(NSMutableURLRequest *)request
{
    [request addValue:[_authentication accessToken] forHTTPHeaderField:@"Authorization"];
}

- (void)handleError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Error occurred: %@", [error localizedDescription]);
#endif
}

@end
