//
//  portCell.m
//  Bamboo
//
//  Created by Matthew Burnett on 1/7/13.
//  Copyright (c) 2013 Matthew Burnett. All rights reserved.
//

#import "portCell.h"

@implementation portCell
@synthesize portNum;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
