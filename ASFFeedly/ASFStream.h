//
//  ASFStream.h
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFStream : NSObject

@property (readonly, nonatomic, copy) NSString *ID;
@property (readonly, nonatomic, copy) NSString *direction;
@property (readonly, nonatomic, copy) NSString *title;
@property (readonly, nonatomic, copy) NSString *continuation;
@property (readonly, nonatomic, strong) NSArray *items;
@property (readonly, nonatomic, strong) NSDate *updated;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
