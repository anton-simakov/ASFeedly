//
//  ASFStream.m
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFStream.h"
#import "ASFConstants.h"

@implementation ASFStream

- (NSString *)URLString
{
    return [[self ID] stringByReplacingOccurrencesOfString:ASFFeedIDPrefix withString:@""];
}

@end
