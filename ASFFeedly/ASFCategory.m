//
//  ASFCategory.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFCategory.h"

@implementation ASFCategory

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _ID = dictionary[@"id"];
        _label = dictionary[@"label"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ID \"%@\" label \"%@\">", [self class], self.ID, self.label];
}

@end
