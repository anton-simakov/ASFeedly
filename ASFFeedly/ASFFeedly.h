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

@class ASFFeedly;

typedef NS_ENUM(NSInteger, ASFRanking)
{
    ASFRankingNewest,
    ASFRankingOldest
};

extern const CGFloat ASFStreamEntriesMax;

@protocol ASFDelegate <NSObject>

@optional
- (void)feedlyClientDidFinishLogin:(ASFFeedly *)client;
- (void)feedlyClient:(ASFFeedly *)client didLoadSubscriptions:(NSArray *)subscriptions;
- (void)feedlyClient:(ASFFeedly *)client didLoadStream:(ASFStream *)stream;

@end

@interface ASFFeedly : NSObject

@property(nonatomic, strong) NSString *clientID;
@property(nonatomic, strong) NSString *clientSecret;
@property(nonatomic, strong) id<ASFDelegate> delegate;

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

- (void)loginWithViewController:(UIViewController *)controller;
- (void)logout;

- (void)getSubscriptions;

- (void)getStream:(NSString *)streamID;

- (void)getStream:(NSString *)streamID
            count:(NSInteger)count
          ranking:(ASFRanking)ranking
       unreadOnly:(BOOL)unreadOnly
        newerThan:(long long)newerThan
     continuation:(NSString *)continuation;

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
