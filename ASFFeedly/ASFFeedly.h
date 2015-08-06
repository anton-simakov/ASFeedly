//
//  ASFFeedly.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASFSubscription.h"
#import "ASFStream.h"
#import "ASFEntry.h"

@interface ASFFeedly : NSObject

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

- (BOOL)isAuthorized;

- (void)subscriptions:(void(^)(NSArray *subscriptions, NSError *error))completion;
- (void)stream:(NSString *)streamID completion:(void(^)(ASFStream *stream, NSError *error))completion;

- (void)getMarkersReads;
- (void)getMarkersReadsNewerThan:(long long)newerThan;

- (void)updateCategory:(NSString *)ID withLabel:(NSString *)label;
- (void)updateSubscription:(NSString *)ID withTitle:(NSString *)title categories:(NSArray *)categories;

- (void)markEntry:(NSString *)ID read:(BOOL)read;
- (void)markEntries:(NSArray *)IDs read:(BOOL)read;
- (void)markCategory:(NSString *)ID read:(BOOL)read;
- (void)markCategories:(NSArray *)IDs read:(BOOL)read;
- (void)markSubscription:(NSString *)ID read:(BOOL)read;
- (void)markSubscriptions:(NSArray *)IDs read:(BOOL)read;

@end
