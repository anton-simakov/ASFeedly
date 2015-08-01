//
//  ASFAuthentication.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFAuthentication.h"

static NSString *const kCodeKey           = @"code";
static NSString *const kUserIDKey         = @"userID";
static NSString *const kRefreshTokenKey   = @"refreshToken";
static NSString *const kAccessTokenKey    = @"accessToken";
static NSString *const kExpirationDateKey = @"expirationDate";
static NSString *const kTokenTypeKey      = @"tokenType";
static NSString *const kPlanKey           = @"plan";
static NSString *const kStateKey          = @"state";

static NSString *const kAuthenticationKey = @"kAuthenticationKey";

@interface ASFAuthentication ()

@property(nonatomic, strong) NSDate *expirationDate;

@end

@implementation ASFAuthentication

- (id)initWithCode:(NSString *)code
{
    self = [super init];
    if (self)
    {
        _code = code;
    }
    return self;
}

+ (ASFAuthentication *)authenticationWithCode:(NSString *)code
{
    return [[ASFAuthentication alloc] initWithCode:code];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _code           = [coder decodeObjectForKey:kCodeKey];
        _userID         = [coder decodeObjectForKey:kUserIDKey];
        _refreshToken   = [coder decodeObjectForKey:kRefreshTokenKey];
        _accessToken    = [coder decodeObjectForKey:kAccessTokenKey];
        _expirationDate = [coder decodeObjectForKey:kExpirationDateKey];
        _tokenType      = [coder decodeObjectForKey:kTokenTypeKey];
        _plan           = [coder decodeObjectForKey:kPlanKey];
        _state          = [coder decodeObjectForKey:kStateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_code           forKey:kCodeKey];
    [coder encodeObject:_userID         forKey:kUserIDKey];
    [coder encodeObject:_refreshToken   forKey:kRefreshTokenKey];
    [coder encodeObject:_accessToken    forKey:kAccessTokenKey];
    [coder encodeObject:_expirationDate forKey:kExpirationDateKey];
    [coder encodeObject:_tokenType      forKey:kTokenTypeKey];
    [coder encodeObject:_plan           forKey:kPlanKey];
    [coder encodeObject:_state          forKey:kStateKey];
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

+ (void)store:(ASFAuthentication *)authentication
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authentication];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAuthenticationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ASFAuthentication *)restore
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthenticationKey];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

+ (void)reset
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAuthenticationKey];
}

@end
