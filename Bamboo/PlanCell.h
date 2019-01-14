//
//  PlanCell.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/20/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *planName;
@property (strong, nonatomic) IBOutlet UIImageView *planStatus;

@end
