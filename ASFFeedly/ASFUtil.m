//
//  ASFUtil.m
//  ASFFeedly
//
//  Created by Anton Simakov on 8/9/15.
//  Copyright (c) 2015 Anton Simakov. All rights reserved.
//

#import "ASFUtil.h"

NSDate *ASFDate(NSNumber *number) {
    if (!number) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:[number longValue] / 1000.0];
}
