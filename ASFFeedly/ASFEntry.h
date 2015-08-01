//
//  ASFEntry.h
//  ASFFeedly
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFEntry : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *author;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *originID;
@property(nonatomic, strong) NSString *imageURLString;

@property(nonatomic, assign) BOOL unread;
@property(nonatomic, assign) long engagement;

@property(nonatomic, assign) long long published;

- (NSDate *)publishedAsDate;

@end
