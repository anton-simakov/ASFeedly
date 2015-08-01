//
//  AFeedlyClientSubscription.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientSubscription.h"
#import "AFeedlyClientConstants.h"

@implementation AFeedlyClientSubscription

- (NSString *)link
{
    return [_ID stringByReplacingOccurrencesOfString:kFeedlyFeedIDPrefix withString:@""];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Feed ID: %@, title: %@, website: %@, updated: %@, categories: %@", _ID, _title, _website, _updated, _categories];
}

@end
