//
//  ASFCredential.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFCredential : NSObject<NSCoding>

@property(nonatomic, strong) NSString *refreshToken;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong, readonly) NSDate *expiration;
@property(nonatomic, strong) NSString *tokenType;

@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (void)storeCredential:(ASFCredential *)credential;

+ (ASFCredential *)retrieveCredential;

@end
