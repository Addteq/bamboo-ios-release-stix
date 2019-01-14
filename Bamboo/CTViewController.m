//
//  CTViewController.m
//  Changes
//
//  Created by Matthew Burnett on 12/18/12.
//  Edited by Yung Chang on 3/9/13.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//
#import "CTViewController.h"
#import "Commit.h"
#import "NaviController.h"
@interface CTViewController ()
@end
@implementation CTViewController
@synthesize searchBar;
@synthesize commitArray;
@synthesize fileNamesArray;
@synthesize filteredArray;
@synthesize buildKey;
@synthesize server;
@synthesize path;
@synthesize client;
@synthesize hud;
@synthesize flag;
@synthesize flag404;
@synthesize flag500;
@synthesize menuButton;
@synthesize actionSh;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Hide Scope Bar
    [searchBar setShowsScopeBar:NO];
    [searchBar sizeToFit];
    
    
    
    
    //[self addBugIcon];
    
    self.searchbt = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.searchbt.frame = CGRectMake(self.view.frame.size.width-100.0f ,10.0f,20.0f,20);
        [self.searchbt setImage:[UIImage imageNamed:@"search_gray.png"] forState:UIControlStateNormal];
    }else{
        self.searchbt.frame = CGRectMake(240.0f ,10.0f,20.0f,20);
        [self.searchbt setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    }
    [self.searchbt addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.searchbt];
    
    //Alloc Arrays
    commitArray = [[NSMutableArray alloc] init];
    fileNamesArray = [[NSMutableArray alloc] init];
    filteredArray = [[NSMutableArray alloc] init];
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    [self parseChanges];
}
-(void) viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:NO];
        }
    }
    if([[self.navigationController.navigationBar subviews] containsObject:self.searchbt]){
        [self.searchbt removeFromSuperview];
    }
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}
-(void) viewWillAppear:(BOOL)animated{
    if(![[self.navigationController.navigationBar subviews] containsObject:self.searchbt]){
        [self.navigationController.navigationBar addSubview:self.searchbt];
    }
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    //Hide Search Box
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    [super viewWillAppear:animated];
}
- (void) parseChanges
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setLabelText:@"Loading..."];
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
    //NSString *changePath = [[NSString alloc] initWithFormat:@"%@", changeURL];
    //   // NSLog(@"Change Path:%@", changePath);
    
    //    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    //    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //    [client setDefaultHeader:@"Accept" value:@"application/json"];
    //    [client setParameterEncoding:AFJSONParameterEncoding];
    // NSLog(@"START %@", server);
    
    
    
    
    
    [client getPath:changePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get changes dictionary
        NSDictionary *changesDictionary = [responseObject objectForKey:@"changes"];
        
        //parse json for changes
        NSArray *changeArray = [changesDictionary objectForKey:@"change"];
        NSMutableSet *files = [[NSMutableSet alloc] init];
        
        int i = 0;
        for(i = 0; i < [changeArray count]; i++) {
            NSString *comment = [changeArray[i] objectForKey:@"comment"];
            //Get username
            NSString* fullName = [changeArray[i] objectForKey:@"fullName"];
            NSString* author = [changeArray[i] objectForKey:@"author"];
            NSString* userName = [changeArray[i] objectForKey:@"userName"];
            
            NSString *name = nil;
            if(fullName != (id)[NSNull null] && fullName.length != 0){
                name = fullName;
            }else if (userName != (id)[NSNull null] && userName.length != 0 ){
                name = userName;
            }else if (author != (id)[NSNull null] && author.length != 0 ){
                name = author;
            }else{
                // NSLog(@"Houston, we have a problem. No fullName, userName, or author field.");
            }
            
            Commit *commit = [Commit messageWithAuthor:comment author:name];
            [commitArray addObject:commit];
            
            //Get changed files dictionary
            NSDictionary* changedFilenameDictionary = [changeArray[i] objectForKey:@"files"];
            
            //Get changed files array
            NSArray *changedFilenameArray = [changedFilenameDictionary objectForKey:@"file"];
            
            //Get changed filenames
            int j = 0;
            for(j = 0; j < [changedFilenameArray count]; j++) {
                NSString *fullpath = [changedFilenameArray[j] objectForKey:@"name"];
                NSString *filename = [fullpath lastPathComponent];
                if (![files containsObject:filename])
                {
                    [files addObject:filename];
                    [fileNamesArray addObject:filename];
                }
            }
        }
        CGRect tableviewframe = self.tableView.frame;
        tableviewframe.size.height = self.tableView.frame.size.height+44;
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        self.tableView.frame = tableviewframe;
        
        // hide search bar
        CGRect newBounds = self.tableView.bounds;
        newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
        self.tableView.bounds = newBounds;
        
        [self.tableView reloadData];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] == 404) {
            flag = YES;
            flag404 = YES;
            // NSLog(@"Status code 404, Flag %c", flag);
            [self.tableView reloadData];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        else{
            if([operation.response statusCode] == 500) {
                flag = YES;
                flag500 = YES;
                // NSLog(@"Status code 500, Flag %c", flag);
                [self.tableView reloadData];
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
            else {
                if([operation.response statusCode] == 401){
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *guest = [userDefaults stringForKey:@"guest"];
                    
                    if([guest isEqualToString:@"guest"]){
                        // NSLog(@"GUEST LOGIN");
                    }else{
                        // NSLog(@"NOT GUEST");
                        [self loggingIn:0];
                    }

                }else{
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
                        // NSLog(@"Network Request Error:%@", error);
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
                }
                
            }
        }
        
        // NSLog(@"HELLO Network Request Error:%@", error);
        [hud show:NO];
        
    }];
}

- (void) retryParseChanges{
    NSString *changeURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result/%@.json?expand=changes.change.files", buildKey];
    NSString *changePath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        changePath = [[NSString alloc] initWithFormat:@"%@", changeURL];
    }
    else {
        changePath = [[NSString alloc] initWithFormat:@"%@%@", path, changeURL];
    }    //   // NSLog(@"Change Path:%@", changePath);
    
    //    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    //    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //    [client setDefaultHeader:@"Accept" value:@"application/json"];
    //    [client setParameterEncoding:AFJSONParameterEncoding];
    
    [client getPath:changePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get changes dictionary
        NSDictionary *changesDictionary = [responseObject objectForKey:@"changes"];
        
        //parse json for changes
        NSArray *changeArray = [changesDictionary objectForKey:@"change"];
        NSMutableSet *files = [[NSMutableSet alloc] init];
        
        int i = 0;
        for(i = 0; i < [changeArray count]; i++) {
            NSString *comment = [changeArray[i] objectForKey:@"comment"];
            //Get username
            NSString* fullName = [changeArray[i] objectForKey:@"fullName"];
            NSString* author = [changeArray[i] objectForKey:@"author"];
            NSString* userName = [changeArray[i] objectForKey:@"userName"];
            
            NSString *name = nil;
            if(fullName != (id)[NSNull null] && fullName.length != 0){
                name = fullName;
            }else if (userName != (id)[NSNull null] && userName.length != 0 ){
                name = userName;
            }else if (author != (id)[NSNull null] && author.length != 0 ){
                name = author;
            }else{
                // NSLog(@"Houston, we have a problem. No fullName, userName, or author field.");
            }
            
            Commit *commit = [Commit messageWithAuthor:comment author:name];
            [commitArray addObject:commit];
            
            //Get changed files dictionary
            NSDictionary* changedFilenameDictionary = [changeArray[i] objectForKey:@"files"];
            
            //Get changed files array
            NSArray *changedFilenameArray = [changedFilenameDictionary objectForKey:@"file"];
            
            //Get changed filenames
            int j = 0;
            for(j = 0; j < [changedFilenameArray count]; j++) {
                NSString *fullpath = [changedFilenameArray[j] objectForKey:@"name"];
                NSString *filename = [fullpath lastPathComponent];
                if (![files containsObject:filename])
                {
                    [files addObject:filename];
                    [fileNamesArray addObject:filename];
                }
            }
        }
        CGRect tableviewframe = self.tableView.frame;
        tableviewframe.size.height = self.tableView.frame.size.height+44;
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        self.tableView.frame = tableviewframe;
        
        // hide search bar
        CGRect newBounds = self.tableView.bounds;
        newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
        self.tableView.bounds = newBounds;
        
        [self.tableView reloadData];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([operation.response statusCode] == 404) {
            flag = YES;
            flag404 = YES;
            // NSLog(@"Status code 404, Flag %c", flag);
            [self.tableView reloadData];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        else{
            if([operation.response statusCode] == 500) {
                flag = YES;
                flag500 = YES;
                // NSLog(@"Status code 500, Flag %c", flag);
                [self.tableView reloadData];
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
            else {
                if([operation.response statusCode] == 401){
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *guest = [userDefaults stringForKey:@"guest"];
                    
                    if([guest isEqualToString:@"guest"]){
                        // NSLog(@"GUEST LOGIN");
                    }else{
                        // NSLog(@"NOT GUEST");
                        [self loggingIn:0];
                    }
                    
                }else{
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
                        // NSLog(@"Network Request Error:%@", error);
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
                }
                
            }
        }
        // NSLog(@"HELLO Network Request Error:%@", error);
        [hud show:NO];
    
    }];
}

- (void)didReceiveMemoryWarning
{
    [self setActionSh:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        // Return the number of sections.
        if ([commitArray count] == 0 || [fileNamesArray count] == 0) {
            return 1;
        }else{
            return 2;
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    else
    {
        if (flag == YES) {
            if(flag404 == YES){
                return @"404 Not Found";
            }
            else{
                if(flag500== YES){
                    return @"500 Internal Server Error";
                }
                else{
                    return @"Invalid Access";
                }
            }
        }else{
            if (section == 0) {
                return @"Commit Messages";
            }
            if (section == 1) {
                return @"Changed Files";
            }
        }
        return @"";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredArray count];
    }
    else
    {
        // Return the number of rows in the section.
        if (section == 0) {
            if ([commitArray count] == 0) {
                return 1;
            }else{
                return [commitArray count];
            }
        }
        if (section == 1) {
            if ([fileNamesArray count] == 0) {
                return 1;
            }else{
                return [fileNamesArray count];
            }
        }
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //commitCell
    //fileCell
    UITableViewCell *cell = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        static NSString *CellIdentifier = @"fileCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Configure the cell...
        cell.textLabel.text = filteredArray[indexPath.row];
    }
    else
    {
        if (indexPath.section == 0) {
            static NSString *CellIdentifier = @"commitCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // NSLog(@"Flag %c", flag);
            
            if (flag == YES){
                if(flag404 == YES){
                    cell.textLabel.text = @"404 Not Found";
                }
                else{
                    if(flag500 == YES){
                        cell.textLabel.text = @"500 Internal Server Error";
                    }
                    else{
                        cell.textLabel.text = @"Unknown";
                    }
                }
            }else if ([commitArray count] == 0) {
                cell.textLabel.text = @"No Commits";
            }else{
                // Configure the cell...
                Commit *c = [commitArray objectAtIndex:indexPath.row];
                cell.textLabel.text = c.message;
                cell.detailTextLabel.text = c.author;
            }
        }
        if (indexPath.section == 1) {
            static NSString *CellIdentifier = @"fileCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([fileNamesArray count] == 0) {
                cell.textLabel.text = @"No Changed Files";
            }else{
                // Configure the cell...
                cell.textLabel.text = fileNamesArray[indexPath.row];
            }
        }
    }
    return cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSString *msg = [filteredArray objectAtIndex:[indexPath row]];
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Search Result"
                       message:msg
                       delegate: nil
                       cancelButtonTitle: @"Close"
                       otherButtonTitles: nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];

        
    }else{
        
    if([indexPath section]==0){
        if([commitArray count] != 0)
        {
            Commit *c = [commitArray objectAtIndex:[indexPath row]];
            NSString *msg = [c.message stringByAppendingFormat:@"\nby %@", c.author];
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Commit"
                           message:msg
                           delegate: nil
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }
        
        
    }else if([indexPath section]==1){
        if([fileNamesArray count] != 0){
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Changed Files"
                           message:[fileNamesArray objectAtIndex:[indexPath row]]
                           delegate: nil
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }
    }
    }
}
- (void)showSearch{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
            [self.menuButton setEnabled:YES];
        }
    }

    [searchBar becomeFirstResponder];
}
- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
    //Action Sheet Title
    NSString *actionSheetTitle = @"Changes";
    //Action Sheet Button Titles
    NSString *logout = @"Logout";
    NSString *cancelTitle = @"Cancel";
    NSString *helpTitle = @"Help";
    actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                              delegate:self
                                     cancelButtonTitle:cancelTitle
                                destructiveButtonTitle:logout
                                     otherButtonTitles:helpTitle, nil];
    
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
            [actionSheet showFromBarButtonItem: sender animated:YES];
        }
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
    self.actionSh=actionSheet;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Try Again"])
    {
        [self parseChanges];
    }else if([title isEqualToString:@"Retry"]){
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setLabelText:@"Loading..."];
        hud.dimBackground = YES;
        [hud show:YES];
        [self loggingIn:0];
    }
    else{
        if([title isEqualToString:@"Dismiss"]) {
            return;
        }else if([title isEqualToString:@"Close"]){
            return;
        }
        else{
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [menuButton setEnabled:YES];
        
    }
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
        else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen shows you the commit detail for the selected build. You can search this list for particular files, authors, or the commit messages themselves."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }
    
}
- (IBAction)showFeedback:(id)sender {
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    
    // Remove all objects from the filtered search array
    [self.filteredArray removeAllObjects];
    NSMutableSet *search = [[NSMutableSet alloc] init];
    
    if ([scope isEqualToString:@"All"]) {
        //no filter
        for (Commit *com in commitArray) {
            NSString *str = com.author;
            if ([str rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str])
                {
                    [search addObject:str];
                    [filteredArray addObject:str];
                }
            }
            NSString *str1 = com.message;
            if ([str1 rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str1])
                {
                    [search addObject:str1];
                    [filteredArray addObject:str1];
                }
            }
        }
        for (NSString *str in fileNamesArray) {
            if ([str rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str])
                {
                    [search addObject:str];
                    [filteredArray addObject:str];
                }
            }
        }
        
    }else if([scope isEqualToString:@"Messages"]){
        //filter using only comment
        for (Commit *com in commitArray) {
            NSString *str = com.message;
            if ([str rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str])
                {
                    [search addObject:str];
                    [filteredArray addObject:str];
                }
            }
        }
    }else if([scope isEqualToString:@"Files"]){
        //filter using filename
        for (NSString *str in fileNamesArray) {
            if ([str rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str])
                {
                    [search addObject:str];
                    [filteredArray addObject:str];
                }
            }
        }
    }else if([scope isEqualToString:@"Author"]){
        //filter using username
        for (Commit *com in commitArray) {
            NSString *str = com.author;
            if ([str rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound ) {
                if (![search containsObject:str])
                {
                    [search addObject:str];
                    [filteredArray addObject:str];
                }
            }
        }
    }
}
#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}




-(void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    CGRect tableviewframe = self.tableView.frame;
    tableviewframe.size.height = self.tableView.frame.size.height+44;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.tableView.frame = tableviewframe;
    [self.tableView reloadData];
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    [searchBar resignFirstResponder];
    
    
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    [self.searchBar resignFirstResponder];
}
- (void) addBugIcon{
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
    [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.clipsToBounds=YES;
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    }else{
        self.bug.frame = CGRectMake(282,10,28,28);
    }
    
    [self.bug setImage:[UIImage imageNamed:@"blueBug.png"] forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
}

- (void) loggingIn:(NSInteger)type{
    
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
            
            [self retryParseChanges];
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
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:@"Request Timed out. Please try again."
                           delegate: self
                           cancelButtonTitle: @"Retry"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }if((myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (myclient.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
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


@end