//
//  ASFEntry.m
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFEntry.h"

@implementation ASFEntry

- (NSDate *)publishedAsDate
{
    return [self published] == 0 ? nil : [NSDate dateWithTimeIntervalSince1970:[self published] / 1000];
}

@end
