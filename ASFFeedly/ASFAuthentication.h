//
//  ASFAuthentication.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFAuthentication : NSObject<NSCoding>

@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *refreshToken;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong, readonly) NSDate *expirationDate;
@property(nonatomic, strong) NSString *tokenType;
@property(nonatomic, strong) NSString *plan;
@property(nonatomic, strong) NSString *state;

- (id)initWithCode:(NSString *)code;
+ (ASFAuthentication *)authenticationWithCode:(NSString *)code;

+ (void)store:(ASFAuthentication *)authentication;
+ (ASFAuthentication *)restore;

+ (void)reset;

- (void)setExpiresIn:(long)ti;
- (BOOL)isTokenExpired;

@end
