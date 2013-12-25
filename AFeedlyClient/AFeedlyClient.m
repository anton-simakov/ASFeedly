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

#import "AFNetworking.h"

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

@property(nonatomic, strong) AFeedlyClientAuthentication *authentication;

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
    [self getStream:streamID
              count:AFeedlyClientStreamEntriesMax
            ranking:AFeedlyClientRankingNewest
         unreadOnly:YES
          newerThan:0
       continuation:nil];
}

- (void)getStream:(NSString *)streamID
            count:(NSInteger)count
          ranking:(AFeedlyClientRanking)ranking
       unreadOnly:(BOOL)unreadOnly
        newerThan:(long long)newerThan
     continuation:(NSString *)continuation
{
    NSMutableDictionary *parameters = [@{kFeedlyStreamIDKey : streamID,
                                         kFeedlyCountKey : @(count),
                                         kFeedlyRankedKey : AFeedlyClientRankingString(AFeedlyClientRankingNewest),
                                         kFeedlyUnreadOnlyKey : @(unreadOnly)} mutableCopy];
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

#pragma mark - Request

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
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (block)
         {
             block(responseObject, nil);
         }
     }
                                     failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (block)
         {
             block(nil, error);
         }
     }];
    
    [operation start];
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
    
    [entry setID:item[kFeedlyClientIDKey]];
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
