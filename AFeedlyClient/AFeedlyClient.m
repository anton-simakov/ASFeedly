//
//  AFeedlyClient.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClient.h"
#import "AFeedlyClientConstants.h"
#import "AFeedlyClientUtility.h"
#import "AFeedlyClientStream.h"
#import "AFeedlyClientEntry.h"
#import "AFeedlyClientAuthentication.h"
#import "AFeedlyClientAuthenticationViewController.h"
#import "ASFURLConnectionOperation.h"

typedef void (^AFeedlyClientResultBlock)(NSError *error);
typedef void (^AFeedlyClientResponseResultBlock)(id response, NSError *error);

const CGFloat AFeedlyClientStreamEntriesMax = 10000;

NSString * rankingStrings[2] =
{
    @"newest",
    @"oldest"
};

NSString * AFeedlyClientRankingString(AFeedlyClientRanking ranking)
{
    return rankingStrings[ranking];
}

@interface AFeedlyClient ()<AFeedlyClientAuthenticationViewControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AFeedlyClientAuthentication *authentication;

@end

@implementation AFeedlyClient

- (instancetype)init
{
    return [self initWithClientID:nil clientSecret:nil];
}

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret
{
    self = [super init];
    if (self)
    {
        _authentication = [AFeedlyClientAuthentication restore];
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
        AFeedlyClientAuthenticationViewController *vc = [[AFeedlyClientAuthenticationViewController alloc] initWithCliendID:_clientID
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
    [AFeedlyClientAuthentication reset];
    [self setAuthentication:nil];
}

#pragma mark - AFeedlyAuthenticationViewControllerDelegate

- (void)feedlyClientAuthenticationViewController:(AFeedlyClientAuthenticationViewController *)vc
                               didFinishWithCode:(NSString *)code
{
    AFeedlyClientAuthentication *authentication = [AFeedlyClientAuthentication authenticationWithCode:code];
    [self finishAuthentication:authentication];
}

- (void)finishAuthentication:(AFeedlyClientAuthentication *)authentication
{
    [self setAuthentication:authentication];
    [AFeedlyClientAuthentication store:authentication];
    
    if ([_delegate respondsToSelector:@selector(feedlyClientDidFinishLogin:)])
    {
        [_delegate feedlyClientDidFinishLogin:self];
    }
}

#pragma mark - Get

- (void)getCategories
{
    NSURL *URL = [AFeedlyClientUtility URLWithPath:@"categories" parameters:nil];
    
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
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlySubscriptionsPath parameters:nil];
    
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
    [self getStream:streamID count:0 ranking:AFeedlyClientRankingDefault unreadOnly:YES newerThan:0 continuation:nil];
}

- (void)getStream:(NSString *)streamID
            count:(NSInteger)count
          ranking:(AFeedlyClientRanking)ranking
       unreadOnly:(BOOL)unreadOnly
        newerThan:(long long)newerThan
     continuation:(NSString *)continuation
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:streamID
                                                                         forKey:kFeedlyStreamIDKey];
    if (count)
    {
        [parameters setValue:@(count) forKey:kFeedlyCountKey];
    }
    
    if (ranking != AFeedlyClientRankingDefault)
    {
        [parameters setValue:AFeedlyClientRankingString(AFeedlyClientRankingNewest) forKey:kFeedlyRankedKey];
    }
    
    if (unreadOnly)
    {
        [parameters setValue:kFeedlyFeedTrueValue forKey:kFeedlyUnreadOnlyKey];
    }
    
    if (newerThan)
    {
        [parameters setValue:@(newerThan + 1) forKey:kFeedlyNewerThanKey];
    }
    
    if (continuation)
    {
        [parameters setValue:continuation forKey:kFeedlyContinuationKey];
    }
    
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlyStreamsContentsPath parameters:parameters];
    
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
        [parameters setValue:@(newerThan + 1) forKey:kFeedlyNewerThanKey];
    }
    
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlyMarkersReadsPath parameters:parameters];
    
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
    NSString *path = [NSString stringWithFormat:@"%@/%@", kFeedlyCategoriesPath, [AFeedlyClientUtility encodeString:ID]];
    
    [self makeRequestWithBase:kFeedlyBaseURL path:path parameters:@{kFeedlyLabelKey : label}];
}

- (void)updateSubscription:(NSString *)ID withTitle:(NSString *)title categories:(NSArray *)categories
{
    [self makeRequestWithBase:kFeedlyBaseURL
                         path:kFeedlySubscriptionsPath
                   parameters:@{kFeedlyIDKey : ID,
                                kFeedlyTitleKey : title,
                                kFeedlyCategoriesKey : categories}];
}

#pragma mark - Mark

- (void)markEntry:(NSString *)ID read:(BOOL)read
{
    [self markEntries:@[ID] read:read];
}

- (void)markEntries:(NSArray *)IDs read:(BOOL)read
{
    [self makeRequestWithPath:kFeedlyMarkersPath parameters:@{kFeedlyActionKey : [self actionForReadState:read],
                                                              kFeedlyTypeKey : kFeedlyEntriesValue,
                                                              kFeedlyEntryIDsKey : IDs}];
}

- (void)markCategory:(NSString *)ID read:(BOOL)read
{
    [self markCategories:@[ID] read:YES];
}

- (void)markCategories:(NSArray *)IDs read:(BOOL)read
{
    [self makeRequestWithPath:kFeedlyMarkersPath parameters:@{kFeedlyActionKey : [self actionForReadState:read],
                                                              kFeedlyTypeKey : kFeedlyCategoriesValue,
                                                              kFeedlyCategoryIDsKey : IDs}];
}

- (void)markSubscription:(NSString *)ID read:(BOOL)read
{
    [self markSubscriptions:@[ID] read:read];
}

- (void)markSubscriptions:(NSArray *)IDs read:(BOOL)read
{
    [self makeRequestWithPath:kFeedlyMarkersPath parameters:@{kFeedlyActionKey : [self actionForReadState:read],
                                                              kFeedlyTypeKey : kFeedlyFeedsValue,
                                                              kFeedlyFeedIDsKey : IDs}];
}

- (NSString *)actionForReadState:(BOOL)state
{
    return state ? kFeedlyMarkAsReadValue : kFeedlyKeepUnreadValue;
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
    [self makeRequestWithBase:kFeedlyBaseURL path:path parameters:parameters];
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

- (void)startRequestWithURL:(NSURL *)URL completionBlock:(AFeedlyClientResponseResultBlock)block
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

- (void)startRequestWithURL:(NSURL *)URL authorized:(BOOL)authorized completionBlock:(AFeedlyClientResponseResultBlock)block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    if (authorized)
    {
        [self authorizeRequest:request];
    }
    
    [self startRequest:request completionBlock:block];
}

- (void)startRequest:(NSURLRequest *)request completionBlock:(AFeedlyClientResponseResultBlock)block
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

- (void)getTokenWithblock:(AFeedlyClientResultBlock)block
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

- (void)getAccessTokenWithBlock:(AFeedlyClientResultBlock)block
{
    NSDictionary *parameters = @{kFeedlyCodeKey : [_authentication code],
                                 kFeedlyClientIDKey : _clientID,
                                 kFeedlyClientSecretKey : _clientSecret,
                                 kFeedlyRedirectURIKey : kFeedlyRedirectURI,
                                 kFeedlyGrantTypeKey : kFeedlyGrantTypeAuthorizationCode};
    
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlyAuthTokenPath parameters:parameters];
    NSURLRequest *request = [AFeedlyClientUtility requestWithURL:URL method:@"POST"];
    
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

- (void)refreshTokenWithBlock:(AFeedlyClientResultBlock)block
{
    NSDictionary *parameters = @{kFeedlyRefreshTokenKey : [_authentication refreshToken],
                                 kFeedlyClientIDKey : _clientID,
                                 kFeedlyClientSecretKey : _clientSecret,
                                 kFeedlyGrantTypeKey : kFeedlyGrantTypeRefreshToken};
    
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlyAuthTokenPath parameters:parameters];
    NSURLRequest *request = [AFeedlyClientUtility requestWithURL:URL method:@"POST"];
    
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
    NSString *refreshToken = responce[kFeedlyRefreshTokenKey];
    
    if (refreshToken)
    {
        [_authentication setRefreshToken:refreshToken];
    }
    
    NSString *state = responce[kFeedlyStateKey];
    
    if (state)
    {
        [_authentication setState:state];
    }
    
    [_authentication setUserID:responce[kFeedlyIDKey]];
    [_authentication setAccessToken:responce[kFeedlyAccessTokenKey]];
    [_authentication setTokenType:responce[kFeedlyTokenTypeKey]];
    [_authentication setPlan:responce[kFeedlyPlanKey]];
    
    NSNumber *timeInterval = responce[kFeedlyExpiresInKey];
    [_authentication setExpiresIn:[timeInterval longValue]];
    
    [AFeedlyClientAuthentication store:_authentication];
}

- (void)parseSubscriptions:(NSArray *)response
{
    NSMutableArray *subscriptions = [NSMutableArray array];
    
    for (NSDictionary *subscriptionDictionary in response)
    {
        AFeedlyClientSubscription *subscription = [AFeedlyClientSubscription new];
        
        [subscription setID: subscriptionDictionary[kFeedlyIDKey]];
        [subscription setTitle: subscriptionDictionary[kFeedlyTitleKey]];
        [subscription setWebsite:subscriptionDictionary[kFeedlyWebsiteKey]];
        
        NSTimeInterval updated = [subscriptionDictionary[kFeedlyUpdatedKey] longLongValue];
        
        [subscription setUpdated:[NSDate dateWithTimeIntervalSince1970:updated]];
        
        NSMutableArray *categories = [NSMutableArray array];
        NSArray *categoriesResponse = subscriptionDictionary[kFeedlyCategoriesKey];
        
        for (NSDictionary *categoryDictionary in categoriesResponse)
        {
            AFeedlyClientCategory *category = [AFeedlyClientCategory new];
            
            [category setID:categoryDictionary[kFeedlyIDKey]];
            [category setLabel:categoryDictionary[kFeedlyLabelKey]];
            
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
    AFeedlyClientStream *stream = [AFeedlyClientStream new];
    
    [stream setID:response[kFeedlyIDKey]];
    [stream setTitle:response[kFeedlyTitleKey]];
    [stream setDirection:response[kFeedlyDirectionKey]];
    [stream setContinuation:response[kFeedlyContinuationKey]];
    [stream setUpdated:[response[kFeedlyUpdatedKey] longLongValue]];
    
    NSArray *items = response[kFeedlyItemsKey];
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
        AFeedlyClientEntry *entry = [self parseEntry:item];
        [entries addObject:entry];
    }
    
    return entries;
}

- (AFeedlyClientEntry *)parseEntry:(NSDictionary *)item
{
    AFeedlyClientEntry *entry = [AFeedlyClientEntry new];
    
    [entry setID:item[kFeedlyIDKey]];
    [entry setTitle:item[kFeedlyTitleKey]];
    [entry setAuthor:item[kFeedlyAuthorKey]];
    [entry setOriginID:item[kFeedlyOriginIDKey]];
    
    [entry setContent:item[kFeedlySummaryKey][kFeedlyContentKey]];
    [entry setUnread:[item[kFeedlyUnreadKey] boolValue]];
    [entry setEngagement:[item[kFeedlyEngagementKey] longValue]];
    [entry setImageURLString:item[kFeedlyVisualKey][kFeedlyURLKey]];
    [entry setPublished:[item[kFeedlyPublishedKey] longLongValue]];
    
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
