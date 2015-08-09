//
//  Cell.h
//  Feedly Demo
//
//  Created by Anton on 11/29/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASFEntry;

@interface Cell : UITableViewCell

@property (nonatomic, strong) ASFEntry *entry;

@end
