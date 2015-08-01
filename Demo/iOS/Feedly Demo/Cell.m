//
//  Cell.m
//  Feedly Demo
//
//  Created by Anton on 11/29/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "Cell.h"

static const CGFloat kHorizontalInset = 10;

@interface Cell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *dateLabel;

@end

@implementation Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleLabel = [UILabel new];
        
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                     forAxis:UILayoutConstraintAxisVertical];
        [[self contentView] addSubview:_titleLabel];
        
        _dateLabel = [UILabel new];
        
        [_dateLabel setNumberOfLines:0];
        [_dateLabel setTextColor:[UIColor lightGrayColor]];
        [_dateLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                    forAxis:UILayoutConstraintAxisVertical];
        [[self contentView] addSubview:_dateLabel];
        
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints
{
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_titleLabel
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0f
                                   constant:kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_titleLabel
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1.0f
                                   constant:kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_titleLabel
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f
                                   constant:-kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_dateLabel
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0f
                                   constant:kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_dateLabel
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_titleLabel
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                   constant:kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_dateLabel
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f
                                   constant:-kHorizontalInset]];
    
    [[self contentView]  addConstraint:
     [NSLayoutConstraint constraintWithItem:_dateLabel
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:[self contentView]
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                   constant:-kHorizontalInset]];
}

- (CGFloat)calculateHeight:(CGFloat)width
{
    [self setupLabels:width];
    
    [[self contentView] setNeedsLayout];
    [[self contentView] layoutIfNeeded];
    
    CGSize size = [[self contentView] systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (void)setupLabels:(CGFloat)width
{
    CGFloat labelWidth = width - kHorizontalInset * 2;
    [_titleLabel setPreferredMaxLayoutWidth:labelWidth];
    [_dateLabel setPreferredMaxLayoutWidth:labelWidth];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setTitle:(NSString *)title
{
    [_titleLabel setText:title];
}

- (void)setDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [_dateLabel setText:[formatter stringFromDate:date]];
}

@end
