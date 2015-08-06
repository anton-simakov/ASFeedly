//
//  ASFStream.m
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFStream.h"
#import "ASFEntry.h"

@implementation ASFStream

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _ID = dictionary[@"id"];
        _title = dictionary[@"title"];
        _direction = dictionary[@"direction"];
        _continuation = dictionary[@"continuation"];
        
        NSNumber *number = dictionary[@"updated"];
        if (number) {
            _updated = [NSDate dateWithTimeIntervalSince1970:[number longValue] / 1000.0];
        }
        
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSDictionary *item in dictionary[@"items"]) {
            [items addObject:[[ASFEntry alloc] initWithDictionary:item]];
        }
        
        _items = items;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ID \"%@\" title \"%@\" direction \"%@\" continuation \"%@\" updated \"%@\" items \"%@\">", [self class], self.ID, self.title, self.direction, self.continuation, self.updated, self.items];
}

@end
