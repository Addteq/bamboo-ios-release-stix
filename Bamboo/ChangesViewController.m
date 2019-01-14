//
//  ChangesViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/8/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//


#import "ChangesViewController.h"

@interface ChangesViewController ()

@end

@implementation ChangesViewController
@synthesize changedFiles;
@synthesize comments;
@synthesize commentsArray;
@synthesize usernameArray;
@synthesize changesDictionary;
@synthesize changeArray;
@synthesize numChanges;
@synthesize numChangedFiles;
@synthesize fileNamesArray;
@synthesize buildKey;
@synthesize server;
@synthesize path;
@synthesize manager;
@synthesize hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      // Custom initialization
   }
   return self;
}

- (void)viewDidLoad
{
   UIImage *button = [UIImage imageNamed: @"list.png"];
   UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                    initWithImage:button
                                    landscapeImagePhone:button
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(showActionSheet:)];
   self.navigationItem.rightBarButtonItem = logoutButton;
   
   
   changesDictionary = [[NSDictionary alloc] init];
   changeArray = [[NSMutableArray alloc] init];
   commentsArray = [[NSMutableArray alloc] init];
   usernameArray = [[NSMutableArray alloc] init];
   fileNamesArray = [[NSMutableArray alloc] init];
    manager = [BambooAPIManager sharedManager:server];
    if((manager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (manager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
        
        //Check if host can be reached first, before making request
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        
        
    }
    else {
        
        [self parseChanges];
    }
   [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   //    int numSections = 0;
   //    if(tableView == comments) {
   //        numSections = 1;
   //    }
   //    if(tableView == changedFiles) {
   //        numSections = 1;
   //    }
   // Return the number of sections.
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(tableView == comments) {
      //NSLog(@"%i",[commentsArray count]);
      if ([commentsArray count] == 0){//[numChanges intValue];
         return 1;
      }else{
         return [commentsArray count];
      }
   }
   if(tableView == changedFiles) {
      //NSLog(@"%i",[fileNamesArray count]);
      if ([fileNamesArray count] == 0){//numRows = [numChangedFiles intValue];
         return 1;
      }else{
         return [fileNamesArray count];
      }
   }
   else{
      // Return the number of rows in the section.
      return 0;
   }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"commentCell";
   static NSString *CellIdentifier1 = @"changedFileCell";
   
   if(tableView == comments) {
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      if([commentsArray count] == 0){
         cell.textLabel.text = @"No commits";
         tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
      }else{
         cell.textLabel.text = commentsArray[indexPath.row];
         cell.detailTextLabel.text = usernameArray[indexPath.row];
      }
      return cell;
   }
   
   if(tableView == changedFiles) {
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier1];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      if([fileNamesArray count] == 0){
         cell.textLabel.text = @"No commits";
         tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
      }else{
         cell.textLabel.text = fileNamesArray[indexPath.row];
      }
      return cell;
   }
   return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (void) parseChanges {
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setLabelText:@"Loading"];
    hud.dimBackground = YES;
    [hud show:YES];

    
    NSString *changeURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=changes.change.files", buildKey];
    NSString *changePath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        changePath = [[NSString alloc] initWithFormat:@"%@", changeURL];
    }
    else {
        changePath = [[NSString alloc] initWithFormat:@"%@%@", path, changeURL];
    }
    NSLog(@"Change Path:%@", changePath);
    
    manager = [BambooAPIManager sharedManager:server];
    [manager getPath:changePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get changes dictionary
        changesDictionary = [responseObject objectForKey:@"changes"];
        NSLog(@"Changes dictionary:%@", changesDictionary);
        
        //Get number of changes
        numChanges = [changesDictionary objectForKey:@"size"];
        
        //parse json for changes
        changeArray = [changesDictionary objectForKey:@"change"];
        
        int i = 0;
        
        for(i = 0; i < [changeArray count]; i++) {
            NSString *comment = [changeArray[i] objectForKey:@"comment"];
            
            //Get username
            NSString* fullName = [changeArray[i] objectForKey:@"fullName"];
            NSString* author = [changeArray[i] objectForKey:@"author"];
            NSString* userName = [changeArray[i] objectForKey:@"userName"];
            
            if(fullName != (id)[NSNull null] && fullName.length != 0){
                //Add username to array
                [usernameArray addObject:fullName];
            }else if (userName != (id)[NSNull null] && userName.length != 0 ){
                //Add username to array
                [usernameArray addObject:userName];
            }else if (author != (id)[NSNull null] && author.length != 0 ){
                //Add username to array
                [usernameArray addObject:author];
            }else{
                NSLog(@"Houston, we have a problem");
            }
            
            
            //Add change object to array
            [commentsArray addObject:comment];
            
            
            //Get changed files dictionary
            NSDictionary* changedFilenameDictionary = [changeArray[i] objectForKey:@"files"];
            
            //Get number of changed files
            numChangedFiles = [changedFilenameDictionary objectForKey:@"size"];
            
            //Get changed files array
            NSArray *changedFilenameArray = [changedFilenameDictionary objectForKey:@"file"];
            
            
            //Get changed filenames
            int j = 0;
            for(j = 0; j < [changedFilenameArray count]; j++) {
                NSString *filename = [changedFilenameArray[j] objectForKey:@"name"];
                [fileNamesArray addObject:filename];
            }
        }
        
        [self.comments reloadData];
        [self.changedFiles reloadData];
        [hud hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if((manager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (manager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Cannot Connect to Bamboo"
                           delegate: self
                           cancelButtonTitle: @"Cancel"
                           otherButtonTitles: @"Try Again", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }

//        [hud hide:YES];
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//        if(error) {
//            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
//        }
//
//        NSLog(@"Network Request Error:%@", error);
    }];

    [hud show:NO];
   //NSError *error;
   
   //parse out the json data
   //NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
   
  
    
   }
}

- (IBAction)showActionSheet:(id)sender {
   UIActionSheet *actionSheet;
   //Action Sheet Title
   NSString *actionSheetTitle = @"Menu";
   //Action Sheet Button Titles
   NSString *logout = @"Logout";
   NSString *cancelTitle = @"Cancel";
   actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                             delegate:self
                                    cancelButtonTitle:cancelTitle
                               destructiveButtonTitle:logout
                                    otherButtonTitles:nil];
   
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
      [actionSheet showFromToolbar:self.navigationController.toolbar];
   }
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   //Get the name of the current pressed button
   NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
   if ([buttonTitle isEqualToString:@"Logout"]) {
       [manager clearAuthorizationHeader];
      NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
      for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
         [cookieStorage deleteCookie:each];
      }
      
      LoginViewController *pvc;
      UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
      pvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"login"];
      pvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
      pvc.modalPresentationStyle=UIModalPresentationFullScreen;
      [self presentViewController:pvc animated:YES completion:nil];
   }
   if ([buttonTitle isEqualToString:@"Cancel"]) {
   }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Try Again"]) {
        
        [self parseChanges];
    }
    if([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }    
}

- (IBAction)help:(id)sender {
   
   UIAlertView *alertDialog;
   alertDialog = [[UIAlertView alloc]
                  initWithTitle:@"Help"
                  message:@"Help will go here"
                  delegate: self
                  cancelButtonTitle: @"Ok"
                  otherButtonTitles: nil];
   alertDialog.alertViewStyle=UIAlertViewStyleDefault;
   [alertDialog show];
   
}
@end
