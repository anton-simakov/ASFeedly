//
//  AFeedlyClientSubscription.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/7/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFeedlyClientCategory.h"

@interface AFeedlyClientSubscription : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *website;
@property(nonatomic, strong) NSDate *updated;
@property(nonatomic, strong) NSArray *categories;

- (NSString *)link;

@end
