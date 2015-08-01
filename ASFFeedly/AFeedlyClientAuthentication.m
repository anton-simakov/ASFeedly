//
//  AFeedlyClientAuthentication.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientAuthentication.h"

static NSString *const AFeedlyClientAuthenticationCodeKey           = @"code";
static NSString *const AFeedlyClientAuthenticationUserIDKey         = @"userID";
static NSString *const AFeedlyClientAuthenticationRefreshTokenKey   = @"refreshToken";
static NSString *const AFeedlyClientAuthenticationAccessTokenKey    = @"accessToken";
static NSString *const AFeedlyClientAuthenticationExpirationDateKey = @"expirationDate";
static NSString *const AFeedlyClientAuthenticationTokenTypeKey      = @"tokenType";
static NSString *const AFeedlyClientAuthenticationPlanKey           = @"plan";
static NSString *const AFeedlyClientAuthenticationStateKey          = @"state";

static NSString *const AFeedlyClientAuthenticationAuthenticationKey = @"AFeedlyClientAuthenticationAuthenticationKey";

@interface AFeedlyClientAuthentication ()

@property(nonatomic, strong) NSDate *expirationDate;

@end

@implementation AFeedlyClientAuthentication

- (id)initWithCode:(NSString *)code
{
    self = [super init];
    if (self)
    {
        _code = code;
    }
    return self;
}

+ (AFeedlyClientAuthentication *)authenticationWithCode:(NSString *)code
{
    return [[AFeedlyClientAuthentication alloc] initWithCode:code];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _code           = [coder decodeObjectForKey:AFeedlyClientAuthenticationCodeKey];
        _userID         = [coder decodeObjectForKey:AFeedlyClientAuthenticationUserIDKey];
        _refreshToken   = [coder decodeObjectForKey:AFeedlyClientAuthenticationRefreshTokenKey];
        _accessToken    = [coder decodeObjectForKey:AFeedlyClientAuthenticationAccessTokenKey];
        _expirationDate = [coder decodeObjectForKey:AFeedlyClientAuthenticationExpirationDateKey];
        _tokenType      = [coder decodeObjectForKey:AFeedlyClientAuthenticationTokenTypeKey];
        _plan           = [coder decodeObjectForKey:AFeedlyClientAuthenticationPlanKey];
        _state          = [coder decodeObjectForKey:AFeedlyClientAuthenticationStateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_code           forKey:AFeedlyClientAuthenticationCodeKey];
    [coder encodeObject:_userID         forKey:AFeedlyClientAuthenticationUserIDKey];
    [coder encodeObject:_refreshToken   forKey:AFeedlyClientAuthenticationRefreshTokenKey];
    [coder encodeObject:_accessToken    forKey:AFeedlyClientAuthenticationAccessTokenKey];
    [coder encodeObject:_expirationDate forKey:AFeedlyClientAuthenticationExpirationDateKey];
    [coder encodeObject:_tokenType      forKey:AFeedlyClientAuthenticationTokenTypeKey];
    [coder encodeObject:_plan           forKey:AFeedlyClientAuthenticationPlanKey];
    [coder encodeObject:_state          forKey:AFeedlyClientAuthenticationStateKey];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"Code: %@, userID: %@, refresh token: %@, access token: %@, expiration date: %@, token type: %@, plan: %@, state: %@",
            _code, _userID, _refreshToken, _accessToken, _expirationDate, _tokenType, _plan, _state];
}

- (void)setExpiresIn:(long)ti
{
    [self setExpirationDate:[NSDate dateWithTimeIntervalSinceNow:ti]];
}

- (BOOL)isTokenExpired
{
    return [[NSDate date] compare:[self expirationDate]] != NSOrderedAscending;
}

+ (void)store:(AFeedlyClientAuthentication *)authentication
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authentication];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:AFeedlyClientAuthenticationAuthenticationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (AFeedlyClientAuthentication *)restore
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:AFeedlyClientAuthenticationAuthenticationKey];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

+ (void)reset
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AFeedlyClientAuthenticationAuthenticationKey];
}

@end
