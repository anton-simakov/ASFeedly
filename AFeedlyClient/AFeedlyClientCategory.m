//
//  AFeedlyClientCategory.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientCategory.h"

@implementation AFeedlyClientCategory

- (NSString *)description
{
    return [NSString stringWithFormat:@"Category ID: %@, label: %@", _ID, _label];
}

@end
