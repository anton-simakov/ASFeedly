//
//  ASFCredential.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFCredential.h"

static NSString *const ASFCredentialKey = @"ASFCredential";

@interface ASFCredential ()

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSString *refreshToken;
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

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ accessToken:\"%@\" tokenType:\"%@\" refreshToken:\"%@\" expiration:\"%@\">", [self class], self.accessToken, self.tokenType, self.refreshToken, self.expiration];
}

- (BOOL)isExpired {
    return [self.expiration compare:[NSDate date]] == NSOrderedAscending;
}

+ (void)storeCredential:(ASFCredential *)credential {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:credential];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:ASFCredentialKey];
}

+ (ASFCredential *)retrieveCredential {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ASFCredentialKey];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.accessToken = [decoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))];
        self.tokenType = [decoder decodeObjectForKey:NSStringFromSelector(@selector(tokenType))];
        self.refreshToken = [decoder decodeObjectForKey:NSStringFromSelector(@selector(refreshToken))];
        self.expiration = [decoder decodeObjectForKey:NSStringFromSelector(@selector(expiration))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [coder encodeObject:self.tokenType forKey:NSStringFromSelector(@selector(tokenType))];
    [coder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
    [coder encodeObject:self.expiration forKey:NSStringFromSelector(@selector(expiration))];
}

@end
