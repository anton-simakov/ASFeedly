//
//  AFeedlyClientSubscription.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientSubscription.h"

static NSString *const AFeedlyClientSubscriptionUserPrefix = @"user/";
static NSString *const AFeedlyClientSubscriptionFeedPrefix = @"feed/";

@implementation AFeedlyClientSubscription

- (NSString *)link
{
    return [_ID stringByReplacingOccurrencesOfString:AFeedlyClientSubscriptionFeedPrefix withString:@""];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Feed ID: %@, title: %@, website: %@, updated: %@, categories: %@", _ID, _title, _website, _updated, _categories];
}

@end
