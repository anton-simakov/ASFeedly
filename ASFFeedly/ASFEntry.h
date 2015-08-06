//
//  ASFEntry.h
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFEntry : NSObject

@property (readonly, nonatomic, copy) NSString *ID;
@property (readonly, nonatomic, copy) NSString *title;
@property (readonly, nonatomic, copy) NSString *author;
@property (readonly, nonatomic, copy) NSString *originID;
@property (readonly, nonatomic, strong) NSDate *published;
@property (readonly, nonatomic, assign, getter = isUnread) BOOL unread;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
