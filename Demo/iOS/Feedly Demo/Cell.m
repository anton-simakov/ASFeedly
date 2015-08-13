//
//  Cell.m
//  Feedly Demo
//
//  Created by Anton on 11/29/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "Cell.h"
#import "ASFEntry.h"

@implementation Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.numberOfLines = 3;
    }
    return self;
}

- (void)setEntry:(ASFEntry *)entry {
    _entry = entry;
    self.textLabel.text = entry.title;
}

@end
