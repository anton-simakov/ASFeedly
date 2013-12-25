//
//  AFeedlyClientAuthentication.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFeedlyClientAuthentication : NSObject<NSCoding>

@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *refreshToken;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong, readonly) NSDate *expirationDate;
@property(nonatomic, strong) NSString *tokenType;
@property(nonatomic, strong) NSString *plan;
@property(nonatomic, strong) NSString *state;

- (id)initWithCode:(NSString *)code;
+ (AFeedlyClientAuthentication *)authenticationWithCode:(NSString *)code;

+ (void)store:(AFeedlyClientAuthentication *)authentication;
+ (AFeedlyClientAuthentication *)restore;

+ (void)reset;

- (void)setExpiresIn:(long)ti;
- (BOOL)isTokenExpired;

@end
