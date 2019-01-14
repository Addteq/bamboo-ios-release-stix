//
//  BuildListCell.h
//  buildtest
//
//  Created by Matthew Burnett on 11/15/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *buildNum;
@property (strong, nonatomic) IBOutlet UILabel *buildReason;
@property (strong, nonatomic) IBOutlet UILabel *buildTime;
@property (strong, nonatomic) IBOutlet UIImageView *buildImage;

@end
