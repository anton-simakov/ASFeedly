//
//  ASFSubscription.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFSubscription.h"
#import "ASFCategory.h"
#import "ASFUtil.h"

@implementation ASFSubscription

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _ID = dictionary[@"id"];
        _title = dictionary[@"title"];
        _website = dictionary[@"website"];
        _updated = ASFDate(dictionary[@"updated"]);
        
        NSMutableArray *categories = [NSMutableArray array];
        
        for (NSDictionary *category in dictionary[@"categories"]) {
            [categories addObject:[[ASFCategory alloc] initWithDictionary:category]];
        }
        
        _categories = categories;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ID \"%@\" title \"%@\" website \"%@\" updated \"%@\" categories \"%@\">", [self class], self.ID, self.title, self.website, self.updated, self.categories];
}

@end
