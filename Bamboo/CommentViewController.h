//
//  CommentViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface CommentViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIBubbleTableViewDataSource, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIView *overView;
@property (strong, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (strong, nonatomic) IBOutlet UIView *textInputView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *bubbleData;
@property (strong, nonatomic) NSMutableArray *arrayOfComments;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) AFHTTPClient *client;
@property (strong, nonatomic) AFXMLRequestOperation *operation;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) CGRect origin;
@property (nonatomic) CGRect textViewOrigin;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) int previousFlag;
@property (strong, nonatomic) UIActionSheet *actionSh;
@property (nonatomic) UIColor *color;
@property (nonatomic) int bottomInset;
@property (nonatomic) NSInteger relogintype;
- (IBAction)sendComment:(id)sender;
- (void) hideKeyboard;
@end
