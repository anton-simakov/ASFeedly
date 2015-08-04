//
//  ASFCredential.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFCredential.h"

static NSString *const kCodeKey           = @"code";
static NSString *const kUserIDKey         = @"userID";
static NSString *const kRefreshTokenKey   = @"refreshToken";
static NSString *const kAccessTokenKey    = @"accessToken";
static NSString *const kExpirationKey     = @"expiration";
static NSString *const kTokenTypeKey      = @"tokenType";
static NSString *const kPlanKey           = @"plan";
static NSString *const kStateKey          = @"state";

static NSString *const ASFCredentialKey = @"ASFCredential";

@interface ASFCredential ()

@property (nonatomic, strong) NSDate *expiration;

@end

@implementation ASFCredential

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _accessToken  = dictionary[@"access_token"];
        _tokenType    = dictionary[@"token_type"];
        _refreshToken = dictionary[@"refresh_token"];
        id expiresIn  = dictionary[@"expires_in"];
        _expiration   = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _userID         = [coder decodeObjectForKey:kUserIDKey];
        _refreshToken   = [coder decodeObjectForKey:kRefreshTokenKey];
        _accessToken    = [coder decodeObjectForKey:kAccessTokenKey];
        _expiration     = [coder decodeObjectForKey:kExpirationKey];
        _tokenType      = [coder decodeObjectForKey:kTokenTypeKey];
        _plan           = [coder decodeObjectForKey:kPlanKey];
        _state          = [coder decodeObjectForKey:kStateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_userID         forKey:kUserIDKey];
    [coder encodeObject:_refreshToken   forKey:kRefreshTokenKey];
    [coder encodeObject:_accessToken    forKey:kAccessTokenKey];
    [coder encodeObject:_expiration     forKey:kExpirationKey];
    [coder encodeObject:_tokenType      forKey:kTokenTypeKey];
    [coder encodeObject:_plan           forKey:kPlanKey];
    [coder encodeObject:_state          forKey:kStateKey];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"UserID: %@, refresh token: %@, access token: %@, expiration: %@, token type: %@, plan: %@, state: %@",
            _userID, _refreshToken, _accessToken, _expiration, _tokenType, _plan, _state];
}

- (void)setExpiresIn:(long)ti
{
    [self setExpiration:[NSDate dateWithTimeIntervalSinceNow:ti]];
}

- (BOOL)isTokenExpired
{
    return [[NSDate date] compare:[self expiration]] != NSOrderedAscending;
}

+ (void)storeCredential:(ASFCredential *)credential
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:credential];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:ASFCredentialKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ASFCredential *)retrieveCredential
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ASFCredentialKey];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

+ (void)reset
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ASFCredentialKey];
}

@end
