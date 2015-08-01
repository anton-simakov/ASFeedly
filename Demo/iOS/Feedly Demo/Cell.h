//
//  Cell.h
//  Feedly Demo
//
//  Created by Anton on 11/29/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setDate:(NSDate *)date;

- (CGFloat)calculateHeight:(CGFloat)width;

@end
