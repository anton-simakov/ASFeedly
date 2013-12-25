//
//  AFeedlyClientStream.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 12/13/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFeedlyClientStream : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *direction;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *continuation;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, assign) long long updated;

@end
