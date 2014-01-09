//
//  AFeedlyClient.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFeedlyClientSubscription.h"
#import "AFeedlyClientStream.h"
#import "AFeedlyClientEntry.h"

@class AFeedlyClient;

typedef NS_ENUM(NSInteger, AFeedlyClientRanking)
{
    AFeedlyClientRankingDefault,
    AFeedlyClientRankingNewest,
    AFeedlyClientRankingOldest
};

extern const CGFloat AFeedlyClientStreamEntriesMax;

@protocol AFeedlyClientDelegate <NSObject>

@optional
- (void)feedlyClientDidFinishLogin:(AFeedlyClient *)client;
- (void)feedlyClient:(AFeedlyClient *)client didLoadSubscriptions:(NSArray *)subscriptions;
- (void)feedlyClient:(AFeedlyClient *)client didLoadStream:(AFeedlyClientStream *)stream;

@end

@interface AFeedlyClient : NSObject

@property(nonatomic, strong) NSString *clientID;
@property(nonatomic, strong) NSString *clientSecret;
@property(nonatomic, strong) id<AFeedlyClientDelegate> delegate;

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

- (void)loginWithViewController:(UIViewController *)controller;
- (void)logout;

- (void)getSubscriptions;

- (void)getStream:(NSString *)streamID;

- (void)getStream:(NSString *)streamID
            count:(NSInteger)count
          ranking:(AFeedlyClientRanking)ranking
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
