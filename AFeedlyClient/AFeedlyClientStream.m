//
//  AFeedlyClientStream.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientStream.h"
#import "AFeedlyClientConstants.h"

@implementation AFeedlyClientStream

- (NSString *)URLString
{
    return [[self ID] stringByReplacingOccurrencesOfString:kFeedlyFeedIDPrefix withString:@""];
}

@end
