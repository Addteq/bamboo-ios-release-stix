//
//  CustomCell.h
//  Bamboo
//
//  Created by Weifeng Zheng on 7/16/13.
//  Copyright (c) 2013 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    UILabel *userLbl;
    UITextField *userTxt;
}
@property (nonatomic, retain) IBOutlet UILabel *_userLbl;
@property (nonatomic, retain) IBOutlet UITextField *_userTxt;

@end
