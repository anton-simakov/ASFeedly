//
//  ATableSection.h
//  AFeedlyClientDemo
//
//  Created by Anton Simakov on 12/25/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATableSection : NSObject

@property(nonatomic, strong) NSString *header;
@property(nonatomic, strong) NSString *footer;
@property(nonatomic, strong) NSArray *items;

@end
