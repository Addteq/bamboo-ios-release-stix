//
//  BuildListCell.m
//  buildtest
//
//  Created by Matthew Burnett on 11/15/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "BuildListCell.h"

@implementation BuildListCell
@synthesize buildNum;
@synthesize buildReason;
@synthesize buildTime;
@synthesize buildImage;

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
