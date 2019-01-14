//
//  BIViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 12/12/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "BuildInfoViewController.h"


@interface BIViewController : UIViewController<UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *buildNum;
@property (strong, nonatomic) IBOutlet UIImageView *buildState;
//@property (strong, nonatomic) IBOutlet UIImageView *buildStateBackground;
@property (strong, nonatomic) IBOutlet UIImageView *buildStateBackground1;
@property (strong, nonatomic) IBOutlet UILabel *buildReason;
@property (strong, nonatomic) IBOutlet UILabel *buildRevision;
@property (strong, nonatomic) IBOutlet UILabel *buildPrettyTime;
@property (strong, nonatomic) IBOutlet UILabel *buildDuration;
@property (strong, nonatomic) IBOutlet UILabel *buildRelativeTime;
@property (strong, nonatomic) IBOutlet UITextView *buildArtifactTV;
@property (strong, nonatomic) IBOutlet UIImageView *buildNumberImage;
@property (strong, nonatomic) IBOutlet UIImageView *buildIconImage;

@property (strong, nonatomic) NSString *buildNumString;
@property (strong, nonatomic) NSString *buildReasonString;
@property (strong, nonatomic) NSString *buildRevisionString;
@property (strong, nonatomic) NSString *buildPrettyTimeString;
@property (strong, nonatomic) NSString *buildDurationString;
@property (strong, nonatomic) NSString *buildRelativeTimeString;
@property (strong, nonatomic) NSMutableArray *buildArtifactArray;
@property (strong, nonatomic) NSString *buildStateString;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *planKey;

/*@property (strong, nonatomic) IBOutlet UIImageView *myBugI;
@property (strong, nonatomic) IBOutlet UIImageView *buggy;
- (IBAction)bugButton;
@property (strong, nonatomic) UIImage *myBugImage;

@property (strong, nonatomic) UIButton *bug;*/

@property (strong, nonatomic) NSMutableArray *buildArray;
@property (nonatomic) NSInteger *numIndex;
@end
