//
//  CommentViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kUsername @"username"

#import "CommentViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@interface CommentViewController ()

@end

@implementation CommentViewController
@synthesize bubbleData;
@synthesize textField;
@synthesize textInputView;
@synthesize bubbleTable;
@synthesize arrayOfComments;
@synthesize key;
@synthesize path;
@synthesize client;
@synthesize operation;
@synthesize server;
@synthesize origin;
@synthesize textViewOrigin;
@synthesize previousFlag;
@synthesize actionSh;
@synthesize hud;
@synthesize color;
@synthesize bottomInset;
@synthesize relogintype;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated{
    UIImage *button = [UIImage imageNamed: @"list.png"];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithImage:button
                                     landscapeImagePhone:button
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(showActionSheet:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    self.navigationItem.title = @"Comments";
    //   self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    self.sendButton.layer.backgroundColor=[[UIColor whiteColor] CGColor];
    self.sendButton.layer.borderWidth=1.0f;
    self.sendButton.layer.borderColor=[[UIColor grayColor] CGColor];
    self.sendButton.layer.cornerRadius=8.0f;
    
    
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth=1.0f;
    textField.layer.borderColor=[[UIColor grayColor] CGColor];
    textField.layer.cornerRadius=8.0f;
    textField.layer.backgroundColor=[[UIColor whiteColor] CGColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,5,20)];
    textField.leftView=paddingView;
    textField.leftViewMode=UITextFieldViewModeAlways;
    
    bottomInset=30;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud setLabelText:@"Loading..."];
    self.hud.dimBackground = YES;
    [self.hud show:YES];
    
    
    arrayOfComments = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user = [userDefaults stringForKey:kUsername];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    
    NSString *commentURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@/comment.json?expand=comments.comment", key];
    NSString *commentPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        commentPath = [[NSString alloc] initWithFormat:@"%@", commentURL];
    }
    else {
        commentPath = [[NSString alloc] initWithFormat:@"%@%@", path, commentURL];
    }
    
    
    
    [client getPath:commentPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //parse json for results
        NSDictionary* comments = [responseObject objectForKey:@"comments"];
        
        //get result array from results
        NSArray* comment = [comments objectForKey:@"comment"];
        
        int i;
        for (i=0; i < [comment count]; i++) {
            //      // NSLog(@"Comment %d %@", i, comment[i]);
            NSString *author = [comment[i] objectForKey:@"author"];
            //            // NSLog(@"Author: %@", author);
            NSString *content = [comment[i] objectForKey:@"content"];
            //            // NSLog(@"Content: %@", content);
            NSString *creationdate = [comment[i] objectForKey:@"creationDate"];
            //            // NSLog(@"Date: %@", creationdate);
            NSString *goodDate = nil;
            NSString *formattedDate = nil;
            NSDate *useDate;
            NSRange clean = [creationdate rangeOfString:@"."];
            if (clean.location != NSNotFound) {
                goodDate = [creationdate substringToIndex:clean.location];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *date = [formatter dateFromString:goodDate];
                [formatter setDateFormat:@"MMM dd, yyyy, h:mm aaa"];
                formattedDate = [NSString stringWithFormat:@"%@",
                                 [formatter stringFromDate:date]];
                useDate = [formatter dateFromString:formattedDate];
                //               // NSLog(@"Formatted Date: %@", formattedDate);
            }
            
            
            self.color = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1.0];
            if ([user rangeOfString:author].location != NSNotFound) {
                //Right aligned label
                // UIColor *color = [UIColor blackColor];
                
                
                NSBubbleData *heyBubble = [NSBubbleData dataWithText:content date:useDate type:BubbleTypeMine fontColor:self.color];
                [arrayOfComments addObject:heyBubble];
            }else{
                //Left aligned comment
                NSBubbleData *photoBubble = [NSBubbleData dataWithText:content date:useDate type:BubbleTypeSomeoneElse fontColor:self.color];
                [arrayOfComments addObject:photoBubble];
            }
        }
        
        
        
        bubbleData = [[NSMutableArray alloc] initWithArray:arrayOfComments];
        bubbleTable.bubbleDataSource = self;
        bubbleTable.contentInset=UIEdgeInsetsMake(0, 0, bottomInset, 0);
        
        // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
        // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
        // Groups are delimited with header which contains date and time for the first message in the group.
        
        bubbleTable.snapInterval = 120;
        
        // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
        // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
        
        bubbleTable.showAvatars = NO;
        
        // Uncomment the line below to add "Now typing" bubble
        // Possible values are
        //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
        //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
        //    - NSBubbleTypingTypeNone - no "now typing" bubble
        
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            CGRect bframe = self.bubbleTable.frame;
            bframe.size.height = [UIScreen mainScreen].bounds.size.height-50;
            self.bubbleTable.frame = bframe;
            
            CGRect inputframe = self.textInputView.frame;
            inputframe.origin.y = self.bubbleTable.frame.size.height;
            inputframe.size.height = 35;
            self.textInputView.frame = inputframe;
            // NSLog(@"%f %f %f %f ", inputframe.origin.x,inputframe.origin.y, inputframe.size.width, inputframe.size.height );
            
            [self.overView addSubview:self.bubbleTable];
            [self.overView addSubview:self.textInputView];
            
            /*
             CGRect fieldframe = self.textField.frame;
             fieldframe.origin.x=4.0;
             fieldframe.origin.y=10;
             self.textField.frame = fieldframe;
             
             CGRect sendframe = self.sendButton.frame;
             sendframe.origin.x=self.textField.frame.size.width+9;
             sendframe.origin.y=self.textField.frame.origin.y;
             // NSLog(@"%f %f ", sendframe.origin.x, sendframe.origin.y);
             self.sendButton.frame = sendframe;
             */
            [self.textInputView addSubview:self.textField];
            [self.textInputView addSubview:self.sendButton];
        }
        [bubbleTable reloadData];
        
        
        if((bubbleTable.contentSize.height-bubbleTable.bounds.size.height) > 0 ){
            CGPoint bottomOffset = CGPointMake(0, bubbleTable.contentSize.height-bubbleTable.bounds.size.height+bottomInset);
            [bubbleTable setContentOffset:bottomOffset animated:NO];
        }
        //         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
        //         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    } failure:^(AFHTTPRequestOperation *failoperation, NSError *error) {
        if ([failoperation.response statusCode] == 401) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *guest = [userDefaults stringForKey:@"guest"];
            
            if([guest isEqualToString:@"guest"]){
                // NSLog(@"GUEST LOGIN");
            }else{
                // NSLog(@"NOT GUEST");
                /*
                 KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BambooLogin" accessGroup:nil];
                 NSString *user = [userDefaults stringForKey:kUsername];
                 NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
                 [client setAuthorizationHeaderWithUsername:user password:password];
                 */
                [self loggingIn:0];
            }
            
            
        }else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Server Error or Unavailable, Please logout!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }else{
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Check your internet connection."
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
        
        
        // NSLog(@"Network Request Error:%@", error);
        
    } ];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [bubbleTable addGestureRecognizer:gestureRecognizer];
    
}

- (void) retryGetComments{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user = [userDefaults stringForKey:kUsername];
    NSString *commentURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@/comment.json?expand=comments.comment", key];
    NSString *commentPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        commentPath = [[NSString alloc] initWithFormat:@"%@", commentURL];
    }
    else {
        commentPath = [[NSString alloc] initWithFormat:@"%@%@", path, commentURL];
    }
    [client getPath:commentPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //parse json for results
        NSDictionary* comments = [responseObject objectForKey:@"comments"];
        
        //get result array from results
        NSArray* comment = [comments objectForKey:@"comment"];
        
        int i;
        for (i=0; i < [comment count]; i++) {
            //      // NSLog(@"Comment %d %@", i, comment[i]);
            NSString *author = [comment[i] objectForKey:@"author"];
            //            // NSLog(@"Author: %@", author);
            NSString *content = [comment[i] objectForKey:@"content"];
            //            // NSLog(@"Content: %@", content);
            NSString *creationdate = [comment[i] objectForKey:@"creationDate"];
            //            // NSLog(@"Date: %@", creationdate);
            NSString *goodDate = nil;
            NSString *formattedDate = nil;
            NSDate *useDate;
            NSRange clean = [creationdate rangeOfString:@"."];
            if (clean.location != NSNotFound) {
                goodDate = [creationdate substringToIndex:clean.location];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *date = [formatter dateFromString:goodDate];
                [formatter setDateFormat:@"MMM dd, yyyy, h:mm aaa"];
                formattedDate = [NSString stringWithFormat:@"%@",
                                 [formatter stringFromDate:date]];
                useDate = [formatter dateFromString:formattedDate];
                //               // NSLog(@"Formatted Date: %@", formattedDate);
            }
            
            
            self.color = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1.0];
            if ([user rangeOfString:author].location != NSNotFound) {
                //Right aligned label
                // UIColor *color = [UIColor blackColor];
                
                
                NSBubbleData *heyBubble = [NSBubbleData dataWithText:content date:useDate type:BubbleTypeMine fontColor:self.color];
                [arrayOfComments addObject:heyBubble];
            }else{
                //Left aligned comment
                NSBubbleData *photoBubble = [NSBubbleData dataWithText:content date:useDate type:BubbleTypeSomeoneElse fontColor:self.color];
                [arrayOfComments addObject:photoBubble];
            }
        }
        
        
        
        bubbleData = [[NSMutableArray alloc] initWithArray:arrayOfComments];
        bubbleTable.bubbleDataSource = self;
        bubbleTable.contentInset=UIEdgeInsetsMake(0, 0, bottomInset, 0);
        
        // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
        // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
        // Groups are delimited with header which contains date and time for the first message in the group.
        
        bubbleTable.snapInterval = 120;
        
        // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
        // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
        
        bubbleTable.showAvatars = NO;
        
        // Uncomment the line below to add "Now typing" bubble
        // Possible values are
        //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
        //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
        //    - NSBubbleTypingTypeNone - no "now typing" bubble
        
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            CGRect bframe = self.bubbleTable.frame;
            bframe.size.height = [UIScreen mainScreen].bounds.size.height-99;
            self.bubbleTable.frame = bframe;
            
            CGRect inputframe = self.textInputView.frame;
            inputframe.origin.y = self.bubbleTable.frame.size.height;
            inputframe.size.height = 35;
            self.textInputView.frame = inputframe;
            // NSLog(@"%f %f %f %f ", inputframe.origin.x,inputframe.origin.y, inputframe.size.width, inputframe.size.height );
            
            [self.overView addSubview:self.bubbleTable];
            [self.overView addSubview:self.textInputView];
            
            /*
             CGRect fieldframe = self.textField.frame;
             fieldframe.origin.x=4.0;
             fieldframe.origin.y=10;
             self.textField.frame = fieldframe;
             
             CGRect sendframe = self.sendButton.frame;
             sendframe.origin.x=self.textField.frame.size.width+9;
             sendframe.origin.y=self.textField.frame.origin.y;
             // NSLog(@"%f %f ", sendframe.origin.x, sendframe.origin.y);
             self.sendButton.frame = sendframe;
             */
            [self.textInputView addSubview:self.textField];
            [self.textInputView addSubview:self.sendButton];
        }
        [bubbleTable reloadData];
        
        
        if((bubbleTable.contentSize.height-bubbleTable.bounds.size.height) > 0 ){
            CGPoint bottomOffset = CGPointMake(0, bubbleTable.contentSize.height-bubbleTable.bounds.size.height+bottomInset);
            [bubbleTable setContentOffset:bottomOffset animated:NO];
        }
        //         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
        //         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
        
    } failure:^(AFHTTPRequestOperation *failoperation, NSError *error) {
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Server Error or Unavailable, Please logout!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else{
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Check your internet connection."
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
        
        
        // NSLog(@"Network Request Error:%@", error);
        
    } ];
}
- (void)didReceiveMemoryWarning
{
    [self setColor:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendComment:(id)sender {
    //Get text
    //Post to server
    //if Post successful, add right aligned label with green bubble (ballon_1.png)
    //Post Comment URL: /rest/api/latest/result/PROJECTKEY-PLANKEY-BUILDNUMBER/comment
    if([textField.text isEqualToString:@""]){
        [textField resignFirstResponder];
    }else{
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setLabelText:@"Sending"];
        hud.dimBackground = YES;
        [hud show:YES];
        
        
        //delete cookie.
        /*
         NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
         NSArray *cookies = [cookieStorage cookies];
         for (NSHTTPCookie *each in cookies) {
         // NSLog(@"Cookie:%@", [each description]);
         [cookieStorage deleteCookie:each];
         }
         */
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *user = [userDefaults stringForKey:kUsername];
        NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@/comment", key];
        //// NSLog(@"%@", planURL);
        // NSLog(@"Server:%@", server);
        // NSLog(@"Path:%@", path);
        
        NSString *urlString = nil;
        if ([path isKindOfClass:[NSNull class]] || path == NULL) {
            urlString = [[NSString alloc] initWithFormat:@"%@%@", server, planURL];
        } else {
            if([server hasSuffix:path]){
                urlString = [[NSString alloc] initWithFormat:@"%@%@", server, planURL];
            }else{
                urlString = [[NSString alloc] initWithFormat:@"%@%@%@", server, path, planURL];
            }
        }
        // NSLog(@"urlString %@", urlString);
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableData *postData = [NSMutableData data];
        [postData appendData: [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
        [postData appendData: [[NSString stringWithFormat:@"<comment author=\"%@\">", user] dataUsingEncoding: NSUTF8StringEncoding]];
        [postData appendData: [[NSString stringWithFormat:@"<content>%@</content>", textField.text] dataUsingEncoding: NSUTF8StringEncoding]];
        [postData appendData: [[NSString stringWithFormat:@"</comment>"] dataUsingEncoding: NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                               cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval: 10];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        
        //Use weak property attribute to reference property inside blocks
        __weak CommentViewController *weakCommentVC = self;
        NSString *textFieldText = weakCommentVC.textField.text;
        
        operation = [[AFXMLRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSBubbleData *sayBubble = [NSBubbleData dataWithText:textFieldText date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine fontColor:weakCommentVC.color];
            
            [weakCommentVC.bubbleData addObject:sayBubble];
            [weakCommentVC.bubbleTable reloadData];
            weakCommentVC.textField.text = @"";
            weakCommentVC.textField.placeholder=@"Type your comment here";
            [weakCommentVC.textField resignFirstResponder];
            if((weakCommentVC.bubbleTable.contentSize.height-weakCommentVC.bubbleTable.bounds.size.height) > 0 ){
                CGPoint bottomOffset = CGPointMake(0, weakCommentVC.bubbleTable.contentSize.height-weakCommentVC.bubbleTable.bounds.size.height+weakCommentVC.bottomInset);
                [weakCommentVC.bubbleTable setContentOffset:bottomOffset animated:NO];
            }
            
            [weakCommentVC.hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        } failure:^(AFHTTPRequestOperation *failoperation, NSError *error) {
            if([failoperation.response statusCode]==401){
                [weakCommentVC loggingIn:1];
            }else{
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Posting of comment failed, please try again."
                               delegate: nil
                               cancelButtonTitle: @"OK"
                               otherButtonTitles:nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
                // NSLog(@"Post comment failed");
                // NSLog(@"Error:%@", [error description]);
                [weakCommentVC.hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        }];
        
        [operation start];
    }
}
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textInputView endEditing:TRUE];
    [self.view endEditing:TRUE];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        origin = self.overView.frame;
        textViewOrigin = self.textInputView.frame;
        
        CGFloat viewHeight = bubbleTable.bounds.size.height-kbSize.height-self.textInputView.frame.size.height;
        
        if((bubbleTable.contentSize.height-bubbleTable.bounds.size.height)>=0){
            self.overView.frame = CGRectMake(0, -kbSize.height, origin.size.width, origin.size.height);
            previousFlag=1;
            // // NSLog(@"case 1 content size is big");
        }else{
            if((bubbleTable.contentSize.height-viewHeight) > 0 ){
                CGPoint bottomOffset = CGPointMake(0, bubbleTable.contentSize.height-bubbleTable.bounds.size.height);
                [bubbleTable setContentOffset:bottomOffset animated:NO];
                self.overView.frame = CGRectMake(0, -kbSize.height, origin.size.width, origin.size.height);
                previousFlag=2;
                
                //// NSLog(@"case 2 content size is not bigger than screen view but needs to move for keyboard");
            }else{
                CGRect newfr = self.textInputView.frame;
                newfr.origin.y -= kbSize.height;
                self.textInputView.frame = newfr;
                previousFlag=3;
                //// NSLog(@"case 3 content size is small so just move input view");
            }
        }
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //NSDictionary* info = [aNotification userInfo];    // unused
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size; // unused
    [UIView animateWithDuration:0.25f animations:^{
        
        if(previousFlag==1){
            self.overView.frame = origin;
        }else if(previousFlag==2){
            self.overView.frame = origin;
            CGPoint bottomOffset;
            if((bubbleTable.contentSize.height-bubbleTable.bounds.size.height) > 0 ){
                bottomOffset = CGPointMake(0, bubbleTable.contentSize.height-bubbleTable.bounds.size.height);
            }else{
                bottomOffset = CGPointMake(0, 0);
            }
            [bubbleTable setContentOffset:bottomOffset animated:NO];
            
        }else if(previousFlag==3){
            self.textInputView.frame = textViewOrigin;
        }
        
    }];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}


- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet;
    //Action Sheet Title
    NSString *actionSheetTitle = @"Comments";
    //Action Sheet Button Titles
    NSString *logout = @"Logout";
    NSString *cancelTitle = @"Cancel";
    NSString *feedback = @"Leave Feedback";
    NSString *help = @"Help";
    actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                              delegate:self
                                     cancelButtonTitle:cancelTitle
                                destructiveButtonTitle:logout
                                     otherButtonTitles:feedback, help, nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet.cancelButtonIndex = -1;
    }
    //    } else {
    //        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    //    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (actionSheet.visible) {
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex
                                              animated:YES];
        } else {
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        [actionSheet showInView:self.view];
    }
    self.actionSh = actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==-1)
    {
        // NSLog(@"Touch outside");
        //[actionSheet showInView:[self.view window]];
    }
    
    else
    {
        //Get the name of the current pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if ([buttonTitle isEqualToString:@"Leave Feedback"]) {
            //[self.navigationController presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
            [self performSelector:@selector(ShowModalTableViewController) withObject:nil afterDelay:0];
            
        }
        if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen allows you to comment on the selected build."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
        
    }
}

-(void) ShowModalTableViewController
{
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Try Again"]) {
        
        [self viewDidLoad];
    }
    if([buttonTitle isEqualToString:@"Logout"]) {
        [client clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
            [cookieStorage deleteCookie:each];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }
    if([buttonTitle isEqualToString:@"Dismiss"]) {
        return;
    }else if([buttonTitle isEqualToString:@"Retry"]){
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        if(self.relogintype==0){
            [self.hud setLabelText:@"Loading..."];
        }else{
            [self.hud setLabelText:@"Sending..."];
        }
        self.hud.dimBackground = YES;
        [self.hud show:YES];
        [self loggingIn:self.relogintype];
    }
}

- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}

-(BOOL)shouldAutorotate{
    return NO;
}


- (void) loggingIn:(NSInteger)type{
    
    if(type==0){
        self.relogintype=0;
    }else{
        self.relogintype=1;
    }
    //Initialize httpClient
    AFHTTPClient *myclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [myclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [myclient setDefaultHeader:@"Accept" value:@"application/json"];
    [myclient setParameterEncoding:AFJSONParameterEncoding];
    
    NSString *viewURL = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/1.0/check.json"];
    }
    else {
        // NSLog(@"path %@",path);
        viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/1.0/check.json", path];
    }
    //viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/1.0/check.json"];
    
    // NSLog( @"viewURL=%@", viewURL);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BambooLogin" accessGroup:nil];
    NSString *user = [userDefaults stringForKey:kUsername];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    [myclient setAuthorizationHeaderWithUsername:user password:password];
    [myclient getPath:viewURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* json = responseObject;
        NSString* check = [json objectForKey:@"check-code"];
        NSRange checkRange = [check rangeOfString:@"success"];
        if (checkRange.location != NSNotFound) {
            // NSLog(@"SUCCESS LOGING IN");
            if(type==0){
                [self retryGetComments];
            }else{
                [self retrySendComment];
            }
        }else{
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Server Error or Unavailable, Please logout!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // NSLog(@"FAIL to LOG IN");
        
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if([error.description rangeOfString:@"ErrorDomain Code=-1001"].location != NSNotFound){
            if(type==0){
                self.relogintype=0;
            }else{
                self.relogintype=1;
            }
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Request Timed out. Please try again."
                           delegate: self
                           cancelButtonTitle: @"Retry"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else if((myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Server Error or Unavailable, Please logout!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else{
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Check your internet connection."
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }];
    [hud show:NO];
}

- (void) retrySendComment{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user = [userDefaults stringForKey:kUsername];
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@/comment", key];
    //// NSLog(@"%@", planURL);
    // NSLog(@"Server:%@", server);
    // NSLog(@"Path:%@", path);
    
    NSString *urlString = nil;
    if ([path isKindOfClass:[NSNull class]] || path == NULL) {
        urlString = [[NSString alloc] initWithFormat:@"%@%@", server, planURL];
    } else {
        if([server hasSuffix:path]){
            urlString = [[NSString alloc] initWithFormat:@"%@%@", server, planURL];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@%@%@", server, path, planURL];
        }
    }
    // NSLog(@"urlString %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableData *postData = [NSMutableData data];
    [postData appendData: [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [postData appendData: [[NSString stringWithFormat:@"<comment author=\"%@\">", user] dataUsingEncoding: NSUTF8StringEncoding]];
    [postData appendData: [[NSString stringWithFormat:@"<content>%@</content>", textField.text] dataUsingEncoding: NSUTF8StringEncoding]];
    [postData appendData: [[NSString stringWithFormat:@"</comment>"] dataUsingEncoding: NSUTF8StringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    //Use weak property attribute to reference property inside blocks
    __weak CommentViewController *weakCommentVC = self;
    NSString *textFieldText = weakCommentVC.textField.text;
    
    operation = [[AFXMLRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:textFieldText date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine fontColor:weakCommentVC.color];
        
        [weakCommentVC.bubbleData addObject:sayBubble];
        [weakCommentVC.bubbleTable reloadData];
        weakCommentVC.textField.text = @"";
        weakCommentVC.textField.placeholder=@"Type your comment here";
        [weakCommentVC.textField resignFirstResponder];
        if((weakCommentVC.bubbleTable.contentSize.height-weakCommentVC.bubbleTable.bounds.size.height) > 0 ){
            CGPoint bottomOffset = CGPointMake(0, weakCommentVC.bubbleTable.contentSize.height-weakCommentVC.bubbleTable.bounds.size.height+weakCommentVC.bottomInset);
            [weakCommentVC.bubbleTable setContentOffset:bottomOffset animated:NO];
        }
        
        [weakCommentVC.hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    } failure:^(AFHTTPRequestOperation *failoperation, NSError *error) {
        
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Error"
                       message:@"Posting of comment failed, please try again."
                       delegate: nil
                       cancelButtonTitle: @"OK"
                       otherButtonTitles:nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
        // NSLog(@"Post comment failed");
        // NSLog(@"Error:%@", [error description]);
        [weakCommentVC.hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    
    [operation start];
}


@end
