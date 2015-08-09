//
//  ASFEntry.m
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFEntry.h"
#import "ASFUtil.h"

@implementation ASFEntry

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _ID = dictionary[@"id"];
        _title = dictionary[@"title"];
        _author = dictionary[@"author"];
        _originID = dictionary[@"originId"];
        _published = ASFDate(dictionary[@"published"]);
        _unread = [dictionary[@"unread"] boolValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ID \"%@\" title \"%@\" author \"%@\" originID \"%@\" published \"%@\" unread \"%d\">", [self class], self.ID, self.title, self.author, self.originID, self.published, self.isUnread];
}

@end
