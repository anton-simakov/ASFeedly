//
//  ASFCategory.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFCategory : NSObject

@property (readonly, nonatomic, copy) NSString *ID;
@property (readonly, nonatomic, copy) NSString *label;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
