//
//  ASFSubscription.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFSubscription : NSObject

@property (readonly, nonatomic, copy) NSString *ID;
@property (readonly, nonatomic, copy) NSString *title;
@property (readonly, nonatomic, copy) NSString *website;
@property (readonly, nonatomic, strong) NSDate *updated;
@property (readonly, nonatomic, strong) NSArray *categories;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
