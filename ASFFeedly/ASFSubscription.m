//
//  ASFSubscription.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFSubscription.h"
#import "ASFConstants.h"

@implementation ASFSubscription

- (NSString *)link
{
    return [_ID stringByReplacingOccurrencesOfString:ASFFeedIDPrefix withString:@""];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Feed ID: %@, title: %@, website: %@, updated: %@, categories: %@", _ID, _title, _website, _updated, _categories];
}

@end
