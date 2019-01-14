//
//  ChangesViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *comments;
@property (strong, nonatomic) IBOutlet UITableView *changedFiles;
@property (nonatomic, strong) NSMutableArray *commentsArray;
@property (nonatomic, strong) NSMutableArray *usernameArray;
@property (nonatomic, strong) NSMutableArray *fileNamesArray;
@property (nonatomic, strong) NSNumber* numChanges;
@property (nonatomic, strong) NSNumber* numChangedFiles;
@property (nonatomic, strong) NSDictionary *changesDictionary;
@property (nonatomic, strong) NSMutableArray *changeArray;
@property (nonatomic, strong) NSString *buildKey;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) BambooAPIManager *manager;
@property (nonatomic, strong) MBProgressHUD *hud;

- (IBAction)help:(id)sender;


@end
