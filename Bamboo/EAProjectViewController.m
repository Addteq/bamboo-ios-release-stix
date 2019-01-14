//
//  EAProjectViewController.m
//  Bamboo
//
//  Created by Emmanuel Anyiam on 9/18/14.
//  Copyright (c) 2014 Addteq. All rights reserved.
//

#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kServer @"fullServer"
#define kBasePath @"baseWithPath"

#import "Plan.h"
#import "Project.h"
#import "PlanCell.h"
#import "BuildListViewController.h"
#import "BuildInfoViewController.h"
#import "NaviController.h"


#import "EAProjectViewController.h"



@implementation EAProjectViewController

@synthesize numProjects;
@synthesize projectArray;
@synthesize arrayOfProjects;
@synthesize arrayOfPlans;
@synthesize planArray;
@synthesize projectDictionary;
@synthesize server;
@synthesize sortingArray;
@synthesize tableView = _tableView;
@synthesize path;
@synthesize client;
@synthesize hud;
@synthesize filteredProjects;
@synthesize filteredPlans;
@synthesize savedScopeButtonIndex;
@synthesize savedSearchTerm;
@synthesize searchWasActive;
@synthesize searchBar;
@synthesize menuButton;
@synthesize  bug;
@synthesize searchDisplayController;
@synthesize actionSheetDismiss;
@synthesize dButton;


-(void) loadView{
    
    [super loadView];
    
//    UIView *view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
//    CGRect viewframe = view.frame;
//    viewframe.size.height = viewframe.size.height+44;
    //[view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
   // self.view = view;
    self.view = _myView;
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [searchBar resignFirstResponder];
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}
- (void) viewWillAppear:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        self.hudShowIntialLoading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hudShowIntialLoading];
        [self.hudShowIntialLoading setLabelText:@"Loading..."];
        self.hudShowIntialLoading.dimBackground = YES;
        [self.hudShowIntialLoading show:YES];
    });
    dispatch_queue_t plansRequest = dispatch_queue_create("plansRequest",NULL);
    dispatch_async(plansRequest, ^(void){
        [self serverRequestForPlans];
    });
    dispatch_queue_t projectRequest = dispatch_queue_create("projectRequest",NULL);
    dispatch_async(projectRequest, ^(void){
        [self serverRequestForProjects];
    });
    
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    //// NSLog(@"will appear");
    
    self.searchDisplayController.delegate=self;
    self.searchDisplayController.searchResultsDataSource=self;
    self.searchDisplayController.searchResultsDelegate=self;
    if (self.savedSearchTerm){
        self.searchBar.showsScopeBar=YES;
    }else{
        self.searchBar.showsScopeBar=NO;
    }
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"buildList" sender: self];
    }
    self.startIndex = 0;
}


- (void)viewDidLoad
{
    
    
    //[self addBugIcon];
    //// NSLog(@"did loaddd");
    //    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
    //        [backButton setImage:[UIImage imageNamed:@"search_gray.png"] forState:UIControlStateNormal];
    //    }else{
    //        [backButton setImage:[UIImage imageNamed:@"search_gray.png"] forState:UIControlStateNormal];
    //        //[backButton setTintColor:[UIColor blueColor]];
    //    }
    //[backButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UITableView *searchView = self.searchDisplayController.searchResultsTableView;
    CGRect tableviewframe = searchView.frame;
    tableviewframe.size.height = [UIScreen mainScreen].bounds.size.height+44;
    //[searchView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    searchView.frame = tableviewframe;
    
    // Design the Search Bar (which is actually a button)
    UIImage *searchImage = [UIImage imageNamed:@"EASearch5"];
    [dButton setImage:searchImage forState:normal];
    
  //  [dButton.layer setBorderWidth:1.0f];
   // [dButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
   // [dButton.layer setCornerRadius:4.0];
    
    projectArray = [[NSMutableArray alloc] init] ;
    self.allprojectsArrayToStoreInPlist = [[NSMutableArray alloc] init];
    arrayOfPlans = [[NSMutableArray alloc] init];
    planArray = [[NSMutableArray alloc] init];
    //  sortingArray = [[NSMutableArray alloc] init];
    filteredProjects = [[NSMutableArray alloc] init];
    filteredPlans = [[NSMutableArray alloc] init];
    self.storeProjectResponse = [[NSMutableArray alloc]init];
    self.storePlanResponse = [[NSMutableArray alloc]init];
    self.allprojectsDictToStoreInPlist = [[NSMutableDictionary alloc]init];
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        self.searchBar.showsScopeBar=YES;
        self.savedSearchTerm = nil;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
//    CGRect newframe = self.tableView.frame;
//    newframe.origin.x=0;
//    newframe.origin.y=0;
//    newframe.size.height = [[UIScreen mainScreen] bounds].size.height+44;
//    self.tableView.frame = newframe;
    
    CGRect footerRect = CGRectMake(0, 0, self.tableView.frame.size.width, 90);
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:footerRect];
    
    wrapperView.backgroundColor = [self.tableView backgroundColor];
    //// NSLog(@"ONLY HAPPENS ONE TIME");
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    [self.searchDisplayController setSearchResultsDelegate:self];
    self.tableView.tableFooterView = wrapperView;
    // Hide searchbar
//    CGRect newBounds = self.tableView.bounds;
//    newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
//    self.tableView.bounds = newBounds;
    
    [self.view addSubview:self.tableView];
    
    //[searchBar setShowsScopeBar:NO];
    [searchBar sizeToFit];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults URLForKey:kServer] == NULL) {
        NSString *bamboo = [userDefaults stringForKey:kBamboo];
        NSString *port = [userDefaults stringForKey:kPort];
        NSString *http = [userDefaults stringForKey:kHttp];
        if ([port isEqualToString:@""] || port == NULL) {
            server = [[NSString alloc] initWithFormat:@"%@://%@", http, bamboo];
            // NSLog(@"Server No Port: %@", server);
        }else{
            server = [[NSString alloc] initWithFormat:@"%@://%@:%@", http, bamboo, port];
            // NSLog(@"Server Port: %@", server);
        }
    }else{
        server = [[userDefaults URLForKey:kServer] absoluteString];
        // NSLog(@"Server Full: %@", server);
    }
    [super viewDidLoad];
    
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	filteredProjects = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //Get documents directory's location
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *allProjectsplistPath = [filePath stringByAppendingPathComponent:@"AllProjects.plist"];
    //    NSString *allPlansPlistPath = [filePath stringByAppendingString:@"AllPlans.plist"];
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"AllPlans.plist"];
    //Check plist's existance using FileManager
    //Get the dictionary from the plist's path
    //Again save in doc directory.
    NSError *error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:allProjectsplistPath error:&error];
    if([[NSFileManager defaultManager]removeItemAtPath:plistPath error:&error]){
        // NSLog(@"success");
    } else
    {
        // NSLog(@"fail");
        
    }
    
    self.startIndexForServerRequestForProjects = 0;
    self.startIndexForServerRequestForPlans = 0;
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

#pragma mark - server GET Requests
- (void)serverRequestForProjects {
    //    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    //    hud = [[MBProgressHUD alloc] initWithView:self.view];
    //    [self.view addSubview:hud];
    //    [hud setLabelText:@"Logging In"];
    //    hud.dimBackground = YES;
    //  [hud show:YES];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    //checking for internet connection
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if(status == AFNetworkReachabilityStatusNotReachable) {
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"No Network Connection"
                           message:@"Please check if you are connected to the Internet."
                           delegate: nil
                           cancelButtonTitle: @"Cancel"
                           otherButtonTitles: @"OK", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
            
        }
        if(status == AFNetworkReachabilityStatusReachableViaWiFi) {
            
        }
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) {
            
        }
    }];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    //    path = [self resolvePath:server];
    path = [[NSUserDefaults standardUserDefaults]valueForKey:kPath];
    
    dispatch_queue_t requestForProjectThread = dispatch_queue_create("requestForProjectThread",NULL);
    dispatch_async(requestForProjectThread, ^(void){
        NSString *projectURL = nil;
        //       // NSLog(@" numberOfTimesNeedServerRequestForProjects %@",self.numberOfTimesNeedServerRequestForProjects);
        //   // NSLog(@"$startIndexForServerRequestForProjects %d",self.startIndexForServerRequestForProjects);
        
        if ([path isKindOfClass:[NSNull class]] || path == NULL) {
            projectURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/project.json?start-index=%d&max-result=25",self.startIndexForServerRequestForProjects];
            //     // NSLog(@"projecturl %@",projectURL);
        }else{
            projectURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/project.json?start-index=%d&max-result=25", path,self.startIndexForServerRequestForProjects];
        }
        [client getPath:projectURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //        [self parseProjects:responseObject];
            //    // NSLog(@"$ppp %@",projectURL);
            // NSLog(@"$ serverRequestForProjects");
            BOOL isResponseDict = [responseObject isKindOfClass:[NSDictionary class]];
            if (isResponseDict == 1) {
                NSDictionary *tempDict = [responseObject objectForKey:@"projects"];
                
                self.allprojectsArrayToStoreInPlist = [tempDict objectForKey:@"project"];
                
                [self storeProjectsInPlist];
                //           NSArray *numProject = [self.allprojectsArrayToStoreInPlist objectForKey:@"project"];
                //          self.numberOfProjectsRecievedFromServer = [NSNumber numberWithInteger:[numProject count]];
                //         // NSLog(@"number of projects is :%@",self.numberOfProjectsRecievedFromServer);
                //parse projects for indiviual project
                //////////////////////////////////
                if (self.startIndexForServerRequestForProjects == 0) {
                    NSDictionary *results = [responseObject objectForKey:@"projects"];
                    //   long i = [response objectForKey:@"size"];
                    NSNumber *tempNum = [results objectForKey:@"size"];
                    self.numberOfTimesNeedServerRequestForProjects = [NSNumber numberWithInt:[tempNum intValue]/25];
                    //           // NSLog(@"qqq%@",self.numberOfTimesNeedServerRequestForProjects);
                    //////////////////////////////////
                    
                }
            }
            else {
                // NSLog(@"!!!AGAIN projects");
                [self serverRequestForProjects];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([operation.response statusCode] == 401) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *guest = [userDefaults stringForKey:@"guest"];
                
                if([guest isEqualToString:@"guest"]){
                    //            // NSLog(@"GUEST LOGIN");
                    [self getSessionID];
                    //         [self retryAFRequest];
                }else{
                    //            // NSLog(@"NOT GUEST");
                }
            }
        }];
    });
    //    [self.hudd hide:YES];
}

- (void)serverRequestForPlans {
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if(status == AFNetworkReachabilityStatusNotReachable) {
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"No Network Connection"
                           message:@"Please check if you are connected to the Internet."
                           delegate: nil
                           cancelButtonTitle: @"Cancel"
                           otherButtonTitles: @"OK", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
        if(status == AFNetworkReachabilityStatusReachableViaWiFi) {
        }
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) {
        }
    }];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    //    path = [self resolvePath:server];
    path = [[NSUserDefaults standardUserDefaults]valueForKey:kPath];
    
    dispatch_queue_t planRequest = dispatch_queue_create("request.for.plansName",NULL);
    dispatch_async(planRequest, ^(void){
        NSString *successURL = nil;
        //      // NSLog(@" $startIndexForServerRequestForPlans%d",self.startIndexForServerRequestForPlans);
        
        if ([path isKindOfClass:[NSNull class]] || path == NULL) {
            successURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/result.json?start-index=%d&max-result=500",self.startIndexForServerRequestForPlans];
        }else{
            successURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/result.json?start-index=%d&max-result=500", path,self.startIndexForServerRequestForPlans];
        }
        [client getPath:successURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //           [self parsePlans:responseObject];
            ///
            //       NSDictionary *results = [responseObject objectForKey:@"results"];
            //        NSArray *result = [results objectForKey:@"result"];
            //           self.numberOfPlansRecievedFromServer = [result count];
            //            self.numberOfPlansRecievedFromServer = [NSNumber numberWithInteger:[result count]];
            // NSLog(@"$ serverRequestForPlans");
            BOOL isResponseDictForPlans = [responseObject isKindOfClass:[NSDictionary class]];
            if (isResponseDictForPlans == 1) {
                NSDictionary *tempDict = [responseObject objectForKey:@"results"];
                self.allPlansArrayToStoreInPlist = [tempDict objectForKey:@"result"];
                //   // NSLog(@"%@",self.allPlansArrayToStoreInPlist);
                [self storePlansInPlist];
                //           // NSLog(@"number of plans is:%@",self.allPlansArrayToStoreInPlist);
                //
                //////////////////////////
                if (self.startIndexForServerRequestForPlans == 0) {
                    NSDictionary *results = [responseObject objectForKey:@"results"];
                    //              NSArray *result = [results objectForKey:@"result"];
                    //   long i = [response objectForKey:@"size"];
                    NSNumber *tempNum = [results objectForKey:@"size"];
                    self.numberOfTimesNeedServerRequestForPlans = [NSNumber numberWithInt:[tempNum intValue]/500];
                    //       // NSLog(@"qqq%@",self.numberOfTimesNeedServerRequestForPlans);
                }
                
                //////////////////////////
                
                //        [self.tableView reloadData];
                ///
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
            } else {
                // NSLog(@"!!!AGAIN plans");
                [self serverRequestForPlans];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
            }
        }];
    });
}

- (void)storeProjectsInPlist {
    // NSLog(@"$ storeProjectsInPlist");
    
    //Get documents directory's location
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"AllProjects.plist"];
    
    //Check plist's existance using FileManager
    NSError *err=nil;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:plistPath])
    {
        //file doesn't exist, copy file from bundle to documents directory
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AllProjects" ofType:@"plist"];
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&err];
    }
    
    //Get the dictionary from the plist's path
    //Again save in doc directory.
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc]init];
    plistDict = [self.allprojectsDictToStoreInPlist mutableCopy];
    //    NSMutableDictionary *dict;
    
    //    for ( pr = 0; pr < [allkeys count]; pr++) {
    //        tempProject = [self.allprojectsDictToStoreInPlist valueForKey:[allkeys objectAtIndex:pr]];
    //        [dict setObject:tempProject.projectName forKey:@"projectName"];
    //        [dict setObject:tempProject.key forKey:@"projectKey"];
    //        // NSLog(@"%@",dict);
    //  //     [tempArrayStoreToPlist insertObject:dict atIndex:pr];
    // //       [tempArrayStoreToPlist addObject:dict];
    ////        [tempArrayStoreToPlist setObject:dict atIndexedSubscript:pr];
    //        // NSLog(@"%@ is at index :%d",[tempArrayStoreToPlist objectAtIndex:pr],pr);
    //        [mDict setObject:tempArrayStoreToPlist forKey:[allkeys objectAtIndex:pr]];
    //    }
    //    // NSLog(@"self.allprojectsArrayToStoreInPlist %@",self.allprojectsArrayToStoreInPlist);
    NSArray *arrayFromPlist = [[NSArray alloc] initWithContentsOfFile:plistPath];
    //   // NSLog(@"data from plist %@",arrayFromPlist);
    if (self.startIndexForServerRequestForProjects == 0) {
        if ( [self.allprojectsArrayToStoreInPlist writeToFile:plistPath atomically:YES]){
            //         // NSLog(@"success");
        } else{
            //       // NSLog(@"failed");
        }
    } else {
        NSArray *tempArray = self.allprojectsArrayToStoreInPlist;
        NSMutableArray *nonRepeatingArray = [[NSMutableArray alloc]init];
        //// filter the project from the allprojectsArrayToStoreInPlist to avoid repeatation
        for (NSArray *project in tempArray ){
            if(![arrayFromPlist containsObject:project]){
                //      // NSLog(@"nonrepeating %@",project);
                [nonRepeatingArray addObject:project];
            }
        }
        self.allprojectsArrayToStoreInPlist = [[arrayFromPlist arrayByAddingObjectsFromArray:nonRepeatingArray]mutableCopy];
        
        
        
        if ( [self.allprojectsArrayToStoreInPlist writeToFile:plistPath atomically:YES]){
            //        // NSLog(@"success");
        } else{
            //         // NSLog(@"failed");
        }
        
    }
    
    [self getProjectsFromPlist];
}

- (void)storePlansInPlist {
    // NSLog(@"$ storePlansInPlist");
    
    //Get documents directory's location
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"AllPlans.plist"];
    
    //Check plist's existance using FileManager
    NSError *err=nil;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:plistPath])
    {
        //file doesn't exist, copy file from bundle to documents directory
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AllPlans" ofType:@"plist"];
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&err];
    }
    
    //Get the dictionary from the plist's path
    //Again save in doc directory.
    
    //    for ( pr = 0; pr < [allkeys count]; pr++) {
    //        tempProject = [self.allprojectsDictToStoreInPlist valueForKey:[allkeys objectAtIndex:pr]];
    //        [dict setObject:tempProject.projectName forKey:@"projectName"];
    //        [dict setObject:tempProject.key forKey:@"projectKey"];
    //        // NSLog(@"%@",dict);
    //  //     [tempArrayStoreToPlist insertObject:dict atIndex:pr];
    // //       [tempArrayStoreToPlist addObject:dict];
    ////        [tempArrayStoreToPlist setObject:dict atIndexedSubscript:pr];
    //        // NSLog(@"%@ is at index :%d",[tempArrayStoreToPlist objectAtIndex:pr],pr);
    //        [mDict setObject:tempArrayStoreToPlist forKey:[allkeys objectAtIndex:pr]];
    //    }
    
    
    //   [dict setObject:tempArray forKey:@"plans"];
    NSArray *arrayFromPlist = [[NSArray alloc] initWithContentsOfFile:plistPath];
    //   // NSLog(@"data from planPlist %@",arrayFromPlist);
    if (self.startIndexForServerRequestForPlans == 0) {
        if ( [self.allPlansArrayToStoreInPlist writeToFile:plistPath atomically:YES]){
            //        // NSLog(@"success");
        } else{
            //         // NSLog(@"failed");
        }
    } else {
        NSArray *tempArray = self.allPlansArrayToStoreInPlist;
        NSMutableArray *nonRepeatingArray = [[NSMutableArray alloc]init];
        //// filter the project from the allprojectsArrayToStoreInPlist to avoid repeatation
        for (NSArray *plan in tempArray ){
            if(![arrayFromPlist containsObject:plan]){
                //     // NSLog(@"nonrepeating %@",plan);
                [nonRepeatingArray addObject:plan];
            }
        }
        self.allPlansArrayToStoreInPlist = [[arrayFromPlist arrayByAddingObjectsFromArray:nonRepeatingArray]mutableCopy];
        
        if ( [self.allPlansArrayToStoreInPlist writeToFile:plistPath atomically:YES]){
            //      // NSLog(@"success");
        } else{
            //       // NSLog(@"failed");
        }
    }
    [self getPlansFromPlist];
}

- (void) getProjectsFromPlist {
    // NSLog(@"$ getProjectsFromPlist");
    
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"AllProjects.plist"];
    
    //Check plist's existance using FileManager
    NSError *err=nil;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:plistPath])
    {
        //file doesn't exist, copy file from bundle to documents directory
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AllProjects" ofType:@"plist"];
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&err];
    }
    
    //Get the dictionary from the plist's path
    //Again save in doc directory.
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc]init];
    plistDict = [self.allprojectsDictToStoreInPlist mutableCopy];
    
    //    for ( pr = 0; pr < [allkeys count]; pr++) {
    //        tempProject = [self.allprojectsDictToStoreInPlist valueForKey:[allkeys objectAtIndex:pr]];
    //        [dict setObject:tempProject.projectName forKey:@"projectName"];
    //        [dict setObject:tempProject.key forKey:@"projectKey"];
    //        // NSLog(@"%@",dict);
    //  //     [tempArrayStoreToPlist insertObject:dict atIndex:pr];
    // //       [tempArrayStoreToPlist addObject:dict];
    ////        [tempArrayStoreToPlist setObject:dict atIndexedSubscript:pr];
    //        // NSLog(@"%@ is at index :%d",[tempArrayStoreToPlist objectAtIndex:pr],pr);
    //        [mDict setObject:tempArrayStoreToPlist forKey:[allkeys objectAtIndex:pr]];
    //    }
    
    NSMutableArray *arrayFromPlist = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    [self parseProjects:arrayFromPlist];
    //   // NSLog(@"data from plist %@",arrayFromPlist);
    //   [self.tableView reloadData];
    //   [self.tableView setNeedsDisplay];
}

- (void) getPlansFromPlist {
    // NSLog(@"$ getPlansFromPlist");
    
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"AllPlans.plist"];
    
    //Check plist's existance using FileManager
    NSError *err=nil;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:plistPath])
    {
        //file doesn't exist, copy file from bundle to documents directory
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"AllPlans" ofType:@"plist"];
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&err];
    }
    
    //Get the dictionary from the plist's path
    //Again save in doc directory.
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc]init];
    plistDict = [self.allprojectsDictToStoreInPlist mutableCopy];
    
    //    for ( pr = 0; pr < [allkeys count]; pr++) {
    //        tempProject = [self.allprojectsDictToStoreInPlist valueForKey:[allkeys objectAtIndex:pr]];
    //        [dict setObject:tempProject.projectName forKey:@"projectName"];
    //        [dict setObject:tempProject.key forKey:@"projectKey"];
    //        // NSLog(@"%@",dict);
    //  //     [tempArrayStoreToPlist insertObject:dict atIndex:pr];
    // //       [tempArrayStoreToPlist addObject:dict];
    ////        [tempArrayStoreToPlist setObject:dict atIndexedSubscript:pr];
    //        // NSLog(@"%@ is at index :%d",[tempArrayStoreToPlist objectAtIndex:pr],pr);
    //        [mDict setObject:tempArrayStoreToPlist forKey:[allkeys objectAtIndex:pr]];
    //    }
    
    NSMutableArray *arrayFromPlist = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    //    // NSLog(@"data from plist %@",arrayFromPlist);
    [self parsePlans:arrayFromPlist];
    //   [self.tableView reloadData];
    //   [self.tableView setNeedsDisplay];
    
}
- (void) retryAFRequest {
    NSString *projectURL = nil;
    NSString *successURL = nil;
    if ([path isKindOfClass:[NSNull class]] || path == NULL) {
        projectURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/project.json?expand=projects.project.plans"];
        successURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/project.json?start-index=500&max-result=100"];
    }else{
        projectURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/project.json?expand=projects.project.plans", path];
        successURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/project.json?start-index=500&max-result=1000", path];
    }
    
    [client getPath:projectURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self parseProjects:responseObject];
        
        [client getPath:successURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self parsePlans:responseObject];
            //     [self.tableView reloadData];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
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
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
    }];
    [hud show:NO];
}

- (void) parseProjects:(NSMutableArray *) projects {
    // NSLog(@"$ parseProjects");
    
    //    NSDictionary* projects = [responseData objectForKey:@"project"];
    //  numProjects = [responseData objectForKey:@"size"];
    //    self.numberOfTimesNeedServerRequestForProjects = [NSNumber numberWithInt:[numProjects intValue]/25];
    //    // NSLog(@"%@",self.numberOfTimesNeedServerRequestForProjects);
    //parse projects for indiviual project
    if ([sortingArray count] == 0 ) {
        sortingArray = nil;
    }
    sortingArray = [[NSMutableArray alloc]init];
    projectArray = projects;
    int i = 0;
    for(i = 0; i < [projectArray count]; i++) {
        //get name and key of project
        NSString* projectName = [projectArray[i] objectForKey:@"name"];
        NSString* key = [projectArray[i] objectForKey:@"key"];
        //create project object
        Project *project = [[Project alloc] init];
        [project setProjectName:projectName];
        [project setKey:key];
        [sortingArray addObject:project];
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"projectName"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.allprojectsArrayToStoreInPlist = [[sortingArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    //    NSMutableArray *filteredArray = [[[[NSOrderedSet alloc] initWithArray:self.allprojectsArrayToStoreInPlist] array] mutableCopy];
    
    //   [self.storeProjectResponse addObjectsFromArray:filteredArray];
    //   // NSLog(@"%@",self.storeProjectResponse);
    self.allprojects = self.allprojectsArrayToStoreInPlist;
    //////
    self.recievedProjects = YES;
    [self setProjects];
    
    
    //   [self.tableView reloadData];
    //  [self.tableView setNeedsDisplay];
}

- (void) parsePlans:(NSArray *) response {
    // NSLog(@"$ parsePlans");
    
    //    NSDictionary *results = [response objectForKey:@"result"];
    NSArray *result = response;
    //   long i = [response objectForKey:@"size"];
    //    NSNumber *tempNum = [response objectForKey:@"size"];
    //  self.numberOfTimesNeedServerRequestForPlans = [NSNumber numberWithInt:[tempNum intValue]/500];
    //   // NSLog(@"%@",self.numberOfTimesNeedServerRequestForPlans);
    
    NSMutableArray *filteredArray = [[[[NSOrderedSet alloc] initWithArray:result] array] mutableCopy];
    if (![self.storePlanResponse count] == 0) {
        self.storePlanResponse = nil;
        self.storePlanResponse = [[NSMutableArray alloc]init];
    }
    [self.storePlanResponse addObjectsFromArray:filteredArray];
    
    self.recievedPlans = YES;
    [self setProjects];
    
    //        [self.tableView reloadData];
    //       [self.tableView setNeedsDisplay];
}

//- (void)GetAllProjects:(NSArray *)allProjects {
- (void)setProjects {
    // NSLog(@"$ setProjects begins");
    
    // NSLog(@"projects :%d     Plans :%d",self.recievedProjects,self.recievedPlans);
    if (self.recievedProjects ==1 && self.recievedPlans == 1) {
        self.recievedPlans = false;
        self.recievedProjects = false;
        Project *project = [[Project alloc]init];
        NSMutableArray *plans = [[NSMutableArray alloc]init];
        NSMutableDictionary *plansForProjectKey = [[NSMutableDictionary alloc]init];
        //   NSMutableArray *all = [[NSMutableArray alloc]init];
        //   all = [self.allprojects valueForKey:@"project"];
        int n = 0;
        for(n =0; n <[self.allprojects count]; n++){
            project = self.allprojects[n];
            NSMutableArray *plansForProject =[[NSMutableArray alloc]init];
            int k = 0;
            for(k = 0; k < [self.storePlanResponse count]; k++) {
                NSString *state = [self.storePlanResponse[k] objectForKey:@"state"];
                NSString *key = [self.storePlanResponse[k] objectForKey:@"key"];
                
                //Key = ProjectKey - Plankey - BuildKey
                //Get ProjectKey
                NSString *projectkey = nil;
                projectkey = [key substringFromIndex:0];
                NSRange end= [projectkey rangeOfString:@"-"];
                if( end.location != NSNotFound){
                    projectkey = [projectkey substringToIndex:end.location];
                }
                // group plans having same project key. Assign it to plansForProjectKey
                if ([project.key isEqualToString:projectkey]) {
                    Plan *plan = [[Plan alloc]init];
                    //check whether plans are disabled .Show only enabled plans
                    //      // NSLog(@"enabled :%@",[[self.storePlanResponse[k] objectForKey:@"plan"]objectForKey:@"enabled"]);
                    if ([[[self.storePlanResponse[k] objectForKey:@"plan"]objectForKey:@"enabled"]intValue] == YES) {
                        
                        plan.name = [[self.storePlanResponse[k] objectForKey:@"plan"]objectForKey:@"shortName"];
                        plan.key = [[self.storePlanResponse[k] objectForKey:@"plan"]objectForKey:@"key"];
                        plan.status = state;
                        plan.project = project.projectName;
                        [plans addObject:plan];
                        [plansForProject addObject:plan];
                    }
                }
            }
            [plansForProjectKey setObject:plansForProject forKey:project.key];
        }
        self.allprojectsArrayToStoreInPlist = [[NSMutableArray alloc]init];
        
        // Assign plansForProjectKey to Project using Projectkay as Unique key
        NSArray *keys = [plansForProjectKey allKeys];
        Project *theProject = [[Project alloc]init];
        int p = 0;
        for (p =0; p< [self.allprojects count] ; p++) {
            theProject = [self.allprojects objectAtIndex:p];
            
            int k;
            for (k=0;k<[plansForProjectKey count];k++){
                
                if ([[keys objectAtIndex:k] isEqualToString:theProject.key]) {
                    theProject.plans = [plansForProjectKey objectForKey:[keys objectAtIndex:k]];
                    [self.allprojectsDictToStoreInPlist setObject:theProject forKey:[keys objectAtIndex:k]];
                    [self.allprojectsArrayToStoreInPlist addObject:theProject];
                    
                }
            }
        }
        //    // NSLog(@"the theProject is :%@ %@",[[[[self.allprojectsArrayToStoreInPlist objectAtIndex:0]plans]objectAtIndex:0]name],[[self.allprojectsArrayToStoreInPlist objectAtIndex:0]key]);
        //     // NSLog(@"the allprojectsDictToStoreInPlist is :%@",self.allprojectsArrayToStoreInPlist);
        
        // NSLog(@"$ setProjects ends");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"$ setProjects reloaddate");
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self.hudShowIntialLoading hide:YES];
            [self.hudForLoadingMoreProjects hide:YES];
        });
    }
    
    
    //   [hud hide:YES];
    //  [self storeProjectsinPlist];
}

- (void) getSessionID{
    NSString *base = server;
    NSURL *originalUrl=[NSURL URLWithString:base];
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

#pragma mark - Table view data source

//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//    CGPoint offset = aScrollView.contentOffset;
//    CGRect bounds = aScrollView.bounds;
//    CGSize size = aScrollView.contentSize;
//    UIEdgeInsets inset = aScrollView.contentInset;
//    float y = offset.y + bounds.size.height - inset.bottom;
//    float h = size.height;
//    // // NSLog(@"offset: %f", offset.y);
//    // // NSLog(@"content.height: %f", size.height);
//    // // NSLog(@"bounds.height: %f", bounds.size.height);
//    // // NSLog(@"inset.top: %f", inset.top);
//    // // NSLog(@"inset.bottom: %f", inset.bottom);
//    // // NSLog(@"pos: %f of %f", y, h);
//
//    float reload_distance = 10;
//    if(y > h + reload_distance) {
//        int i =0;
//        if (i <1) {
//            //           [self loadMoreProjectsAndPlans];
//        }
//        i++;
//    }
//}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -10) {
        //      // NSLog(@"reload");
        // Show the hud loading
        
        //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadMoreProjectsAndPlans];
    }
}

- (void)loadMoreProjectsAndPlans {
    //   // NSLog(@"load more rows");
    self.startIndexForServerRequestForProjects += 25;
    self.startIndexForServerRequestForPlans += 500;
    if (![self.numberOfTimesNeedServerRequestForPlans intValue]== 0) {
        self.hudForLoadingMoreProjects = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hudForLoadingMoreProjects];
        [self.hudForLoadingMoreProjects setLabelText:@"Loading more projects"];
        self.hudForLoadingMoreProjects.dimBackground = YES;
        [self.hudForLoadingMoreProjects show:YES];
        [self.hudForLoadingMoreProjects setNeedsDisplay];
        dispatch_queue_t requestMorePlansThread = dispatch_queue_create("requestMorePlansThread",NULL);
        dispatch_async(requestMorePlansThread, ^(void){
            
            [self serverRequestForPlans];
        });
        self.numberOfTimesNeedServerRequestForPlans = [NSNumber numberWithInt:[self.numberOfTimesNeedServerRequestForPlans intValue]-1];
        // NSLog(@"%@",self.numberOfTimesNeedServerRequestForPlans);
    } else {
        if (![self.numberOfTimesNeedServerRequestForProjects intValue] == 0 ) {
            dispatch_queue_t getPlansFromPlistThread = dispatch_queue_create("getPlansFromPlistThread",NULL);
            dispatch_async(getPlansFromPlistThread, ^(void){
                [self getPlansFromPlist];
            });
        }
    }
    //   NSMutableArray *holdCurrentProjects = self.allprojectsArrayToStoreInPlist;
    if (![self.numberOfTimesNeedServerRequestForProjects intValue] == 0 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your code goes in here
            // NSLog(@"Main Thread Code");
            self.hudForLoadingMoreProjects = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hudForLoadingMoreProjects];
            [self.hudForLoadingMoreProjects setLabelText:@"Loading more projects"];
            self.hudForLoadingMoreProjects.dimBackground = YES;
            [self.hudForLoadingMoreProjects show:YES];
            [self.hudForLoadingMoreProjects setNeedsDisplay];
        });
        
        dispatch_queue_t requestForMoreProjectsThread = dispatch_queue_create("requestForMoreProjectsThread",NULL);
        dispatch_async(requestForMoreProjectsThread, ^(void){
            
            [self serverRequestForProjects];
        });
        self.numberOfTimesNeedServerRequestForProjects = [NSNumber numberWithInt:[self.numberOfTimesNeedServerRequestForProjects intValue]-1];
        //    // NSLog(@"%@",self.numberOfTimesNeedServerRequestForProjects);
    }
    [self.hudForLoadingMoreProjects hide:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        // Return the number of sections.
        return [filteredProjects count];
        
    }
    else {
        
        // Return the number of sections.
        //       // NSLog(@"w%lu",(unsigned long)[self.allprojectsArrayToStoreInPlist count]);
        return [self.allprojectsArrayToStoreInPlist count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        //ipad
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,70)];
        Project *project = [[Project alloc]init];
        NSString *projectName = [[NSString alloc]init];
        // create image object
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            project = [filteredProjects objectAtIndex:section];
            projectName = project.projectName;
            projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                               withString:[[projectName substringToIndex:1] capitalizedString]];
        }
        else
        {
            project = [self.allprojectsArrayToStoreInPlist objectAtIndex:section];
            projectName = project.projectName;
            projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                               withString:[[projectName substringToIndex:1] capitalizedString]];
            
            NSMutableArray *array = [[NSMutableArray alloc]init];
            [array addObject:projectName];
            //     // NSLog(@"project name:%@",array);
        }
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
        headerLabel.backgroundColor = [UIColor colorWithRed:211.0/255 green:211.0/255 blue:211.0/255 alpha:100];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        headerLabel.frame = CGRectMake(3,0,320,25);
        //  headerLabel.
        headerLabel.text =  projectName;
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.alpha = 0.8;
        if ([project.plans count]==0 ) {
            //        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            //        detailLabel.backgroundColor = [UIColor clearColor];
            //        detailLabel.textColor = [UIColor darkGrayColor];
            //        detailLabel.text = @" No Plans ";
            //        detailLabel.font = [UIFont systemFontOfSize:11];
            //        detailLabel.frame = CGRectMake(250,18,55,20);
            //        detailLabel.textColor = [UIColor redColor];
            //        detailLabel.layer.borderColor = [UIColor redColor].CGColor;
            //        detailLabel.layer.borderWidth = 1.0;
            //        [customView addSubview:detailLabel];
            UIColor *darkRedColor = [[UIColor alloc]initWithRed:208.0/255 green:2.0/255 blue:27.0/255 alpha:100.0];
            UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(240,2,60,20)];
            button.layer.cornerRadius = 6;
            button.layer.borderWidth = 1.6;
            [button setTitle:@"Hello" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
            [button setTitle:@"No Plan" forState:UIControlStateNormal];
            [button setTitleColor:darkRedColor forState:UIControlStateNormal];
            
            button.layer.borderColor = darkRedColor.CGColor;
            //    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            //         button.layer.borderColor = [UIColor redColor].CGColor ;
            button.clipsToBounds = YES;
            [headerLabel addSubview:button];
            
        }
        [customView addSubview:headerLabel];
        
        return customView;

    } else {
    // create the parent view that will hold header Label
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,70)];
    Project *project = [[Project alloc]init];
    NSString *projectName = [[NSString alloc]init];
    // create image object
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        project = [filteredProjects objectAtIndex:section];
        projectName = project.projectName;
        projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[projectName substringToIndex:1] capitalizedString]];
    }
	else
	{
        project = [self.allprojectsArrayToStoreInPlist objectAtIndex:section];
        projectName = project.projectName;
        projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[projectName substringToIndex:1] capitalizedString]];
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [array addObject:projectName];
        //     // NSLog(@"project name:%@",array);
    }
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor colorWithRed:211.0/255 green:211.0/255 blue:211.0/255 alpha:100];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(3,0,320,25);
    //  headerLabel.
    headerLabel.text =  projectName;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.alpha = 0.8;
    if ([project.plans count]==0 ) {
        //        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //        detailLabel.backgroundColor = [UIColor clearColor];
        //        detailLabel.textColor = [UIColor darkGrayColor];
        //        detailLabel.text = @" No Plans ";
        //        detailLabel.font = [UIFont systemFontOfSize:11];
        //        detailLabel.frame = CGRectMake(250,18,55,20);
        //        detailLabel.textColor = [UIColor redColor];
        //        detailLabel.layer.borderColor = [UIColor redColor].CGColor;
        //        detailLabel.layer.borderWidth = 1.0;
        //        [customView addSubview:detailLabel];
        UIColor *darkRedColor = [[UIColor alloc]initWithRed:208.0/255 green:2.0/255 blue:27.0/255 alpha:100.0];
        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(240,2,60,20)];
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1.6;
        [button setTitle:@"Hello" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
        [button setTitle:@"No Plan" forState:UIControlStateNormal];
        [button setTitleColor:darkRedColor forState:UIControlStateNormal];
        
        button.layer.borderColor = darkRedColor.CGColor;
        //    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        //         button.layer.borderColor = [UIColor redColor].CGColor ;
        button.clipsToBounds = YES;
        [headerLabel addSubview:button];
        
    }
    [customView addSubview:headerLabel];
    
    //
    //// create the imageView with the image in it
    
    
    return customView;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        Project *project = [filteredProjects objectAtIndex:section];
        NSString *projectName = project.projectName;
        projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[projectName substringToIndex:1] capitalizedString]];
        return projectName;
    }
	else
	{
        Project *project = [self.allprojectsArrayToStoreInPlist objectAtIndex:section];
        NSString *projectName = project.projectName;
        projectName = [projectName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[projectName substringToIndex:1] capitalizedString]];
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [array addObject:projectName];
        //     // NSLog(@"project name:%@",array);
        
        return projectName;
        
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==self.searchDisplayController.searchResultsTableView){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            return 90;
        }
    }
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //   return 15.0;
    return 0.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Return number of rows in section
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        // Return the number of rows in the section.
        Project *project = [filteredProjects objectAtIndex:section];
        NSMutableArray *pplans = [project getPlans];
        return [pplans count];
        
    }
	else
	{
        // Return the number of rows in the section.
        Project *project = [self.allprojectsArrayToStoreInPlist objectAtIndex:section];
        NSMutableArray *pplans = [project getPlans];
        return [pplans count];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        static NSString *CellIdentifier = @"ProjectCell";
        PlanCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        Project *project = filteredProjects[indexPath.section];
        NSString *projectName = project.projectName;
        Plan *plan = project.plans[indexPath.row];
        
        // Configure the cell...
        NSString *planName = plan.name;
        //// NSLog(@"Plan Name 1: %@", planName);
        if ([planName isEqualToString:projectName]) {
            // NSLog(@"Invalid project name");
        }else{
            NSRange pro = [planName rangeOfString:projectName];
            if ((pro.location != NSNotFound) && (planName.length != (pro.location + pro.length))){
                planName = [planName substringFromIndex:(pro.location+pro.length)];
                //// NSLog(@"Plan Name 2: %@", planName);
                
                if ([[planName substringToIndex:1] isEqualToString:@" "]) {
                    planName = [planName substringFromIndex:1];
                }
            }
        }
        planName = [planName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                     withString:[[planName substringToIndex:1] capitalizedString]];
        
        cell.planName.text = planName;
        NSString *status = [plan getStatus];
        if ([status isEqualToString:@"Successful"]) {
            UIImage *image = [UIImage imageNamed: @"Green@2x.png"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                image = [UIImage imageNamed: @"Green@2x.png"];
            }
            cell.planStatus.image = image;
        }else{
            UIImage *image = [UIImage imageNamed: @"redX@2x.png"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                image = [UIImage imageNamed: @"redX@2x.png"];
            }
            cell.planStatus.image = image;
        }
        return cell;
    }
	else
	{
        static NSString *CellIdentifier = @"ProjectCell";
        PlanCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Project *project = self.allprojectsArrayToStoreInPlist[indexPath.section];
        NSString *projectName = project.projectName;
        Plan *plan = project.plans[indexPath.row];
        // Configure the cell...
        NSString *planName = plan.name;
        //// NSLog(@"Plan Name 1: %@", planName);
        if ([planName isEqualToString:projectName]) {
            // NSLog(@"Someone sucks at naming their plans!");
        }else{
            NSRange pro = [planName rangeOfString:projectName];
            if ((pro.location != NSNotFound) && (planName.length != (pro.location + pro.length))){
                planName = [planName substringFromIndex:(pro.location+pro.length)];
                //// NSLog(@"Plan Name 2: %@", planName);
                
                if ([[planName substringToIndex:1] isEqualToString:@" "]) {
                    planName = [planName substringFromIndex:1];
                }
            }
        }
        planName = [planName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                     withString:[[planName substringToIndex:1] capitalizedString]];
        cell.planName.text = planName;
        NSString *status = [plan getStatus];
        //      // NSLog(@"qqq :%@",status);
        //      // NSLog(@"www :%@ %@",planName,status);
        
        if ([status isEqualToString:@"Successful"]) {
            UIImage *image = [UIImage imageNamed: @"Green@2x.png"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                image = [UIImage imageNamed: @"Green@2x.png"];
            }
            cell.planStatus.image = image;
        }else{
            UIImage *image = [UIImage imageNamed: @"redX@2x.png"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                image = [UIImage imageNamed: @"redX@2x.png"];
            }
            cell.planStatus.image = image;
        }
        
        return cell;
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    //add first letter of all projects
    int i;
    for (i=0; i<[self.allprojectsArrayToStoreInPlist count]; i++) {
        Project *p = self.allprojectsArrayToStoreInPlist[i];
        NSString *projectName = p.projectName;
        NSString *firstLetter = [[projectName substringToIndex:1] capitalizedString];
        if (![tempArray containsObject:firstLetter]) {
            [tempArray addObject:firstLetter];
        } else {
            [tempArray addObject:@"."];
        }
    }
    return tempArray;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"buildList"]) {
        BuildListViewController *buildListVC = segue.destinationViewController;
        
        NSIndexPath *indexPath = nil;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            Project *project = filteredProjects[indexPath.section];
            Plan *plan = project.plans[indexPath.row];
            buildListVC.projectName = [project getProjectName];
            buildListVC.planKey = plan.key;
            buildListVC.server = server;
            buildListVC.path = path;
            
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            Project *project = self.allprojectsArrayToStoreInPlist[indexPath.section];
            Plan *plan = project.plans[indexPath.row];
            buildListVC.projectName = [project getProjectName];
            buildListVC.planKey = plan.key;
            buildListVC.server = server;
            buildListVC.path = path;
        }
    }
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
    
	
	[filteredProjects removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSMutableSet *projSet = [[NSMutableSet alloc] init];
    
	for (Project *project in self.allprojectsArrayToStoreInPlist)
	{
        if([scope isEqualToString:@"All"]) {
            
            NSString *projName = [project getProjectName];
            
            if ([projName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
            {
                if (![projSet containsObject:project])
                {
                    [projSet addObject:project];
                    [filteredProjects addObject:project];
                }
            }
            
            NSMutableArray *plans = [project getPlans];
            
            for(Plan *plan in plans) {
                
                NSString *planName = [plan getName];
                if([planName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
                {
                    if (![projSet containsObject:project])
                    {
                        [projSet addObject:project];
                        [filteredProjects addObject:project];
                    }
                }
            }
            
            
        }
        
        
        if([scope isEqualToString:@"Projects"]) {
            
            NSString *projName = [project getProjectName];
            //// NSLog(@"search : %@ and project %@ ",searchText,projName);
            if ([projName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
            {
                if (![projSet containsObject:project])
                {
                    [projSet addObject:project];
                    [filteredProjects addObject:project];
                }
            }
        }
        if([scope isEqualToString:@"Plans"]) {
            
            NSMutableArray *plans = [project getPlans];
            
            for(Plan *plan in plans) {
                
                NSString *planName = [plan getName];
                if([planName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
                {
                    if (![projSet containsObject:project])
                    {
                        [projSet addObject:project];
                        Project *tempProject = [[Project alloc] init];
                        tempProject.key = [project.key copy];
                        tempProject.projectName = [project.projectName copy];
                        tempProject.planSuccess = [project.planSuccess copy];
                        tempProject.planFailed = [project.planFailed copy];
                        tempProject.plans = [NSMutableArray arrayWithArray:project.plans];
                        [tempProject filter:searchText];
                        [filteredProjects addObject:tempProject];
                    }
                }
            }
        }
        
	}
    
    [self.searchDisplayController.searchResultsTableView scrollsToTop];
    
}


-(void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    
    [searchDisplayController.searchResultsTableView setDelegate:self];
    UITableView *searchView = self.searchDisplayController.searchResultsTableView;
    CGRect tableviewframe = searchView.frame;
    tableviewframe.size.height = [UIScreen mainScreen].bounds.size.height;
    //[searchView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    searchView.frame = tableviewframe;
    [self.searchDisplayController.searchResultsTableView scrollsToTop];
    [self.tableView setAllowsSelection:NO];
    
}

-(void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    
    UIImage *searchImage = [UIImage imageNamed:@"EASearch5"];
    [dButton setImage:searchImage forState:normal];
    
    // Hide searchbar
//    CGRect newBounds = self.tableView.bounds;
//    newBounds.origin.y = newBounds.origin.y + searchBar.bounds.size.height;
//    self.tableView.bounds = newBounds;
    
    UITableView *searchView = self.searchDisplayController.searchResultsTableView;
    CGRect tableviewframe = searchView.frame;
    tableviewframe.size.height = [UIScreen mainScreen].bounds.size.height;
    //[searchView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    searchView.frame = tableviewframe;
    dButton.enabled = YES;
    
    [self.tableView setAllowsSelection:YES];
    
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBare{
    [searchBare resignFirstResponder];
    
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    
    [self.searchDisplayController.searchResultsTableView scrollsToTop];
    /*
     [self.searchDisplayController.searchResultsTableView reloadData];
     CGRect sframe = self.searchDisplayController.searchResultsTableView.frame;
     sframe.size.height=self.searchDisplayController.searchResultsTableView.contentSize.height*90;
     self.searchDisplayController.searchResultsTableView.frame = sframe;
     */
    //// NSLog(@"hello %f %f",self.searchDisplayController.searchResultsTableView.tableHeaderView.frame.size.height, self.searchDisplayController.searchResultsTableView.contentSize.height);
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //// NSLog(@"Scope title %@",[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]);
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    [self.searchDisplayController.searchResultsTableView scrollsToTop];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)enableButton:(UIButton *)button {
    button.enabled = YES;
   
}

- (IBAction)eaSearch:(id)sender {
    [dButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [dButton.layer setBackgroundColor:(__bridge CGColorRef)([UIColor clearColor])];
    [searchBar becomeFirstResponder];
    dButton.enabled = NO;
   // [dButton setBackgroundImage:[UIImage imageNamed:@"SearchBg"] forState:UIControlStateDisabled];
    //[dButton setImage:@"LoginHolder" forState:UIControlStateDisabled];
   // [dButton setImage:[UIImage imageNamed:@"SearchBg"] forState:UIControlStateDisabled];
   // [dButton.layer setBackgroundColor:(__bridge CGColorRef)([UIColor grayColor])];

}

- (IBAction)mySearch:(id)sender {
    //[self search];
    [searchBar becomeFirstResponder];
}

- (void) search{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    //[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.actionSheetDismiss.visible){
            [self.actionSheetDismiss dismissWithClickedButtonIndex:-1 animated:YES];
            [self.menuButton setEnabled:YES];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView scrollsToTop];
    [searchBar becomeFirstResponder];
}

- (IBAction)showFeedback:(id)sender {
    //// NSLog(@"first one");
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (IBAction)showActionSheet:(id)sender {
    
    
    UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
    //Action Sheet Title
    NSString *actionSheetTitle = @"Projects";
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        //ipad
        if (actionSheet.visible) {
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex
                                              animated:YES];
        } else {
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        //iphone
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
    
    self.actionSheetDismiss = actionSheet;
    
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
                //// NSLog(@"Cookie:%@", [each description]);
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen displays your current projects and the status of their plans"
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Try Again"]) {
    }
    if([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }
    if([buttonTitle isEqualToString:@"Dismiss"]) {
        return;
    }
    if([buttonTitle isEqualToString:@"Logout"]) {
        [client clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
            [cookieStorage deleteCookie:each];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if([buttonTitle isEqualToString:@"Retry"]){
        [self loggingIn:0];
    }
}

//- (NSString *)resolvePath:(NSString *)serverAddress {
//
//    NSString *base = serverAddress;
//    NSURL *originalUrl=[NSURL URLWithString:base];
//    NSData *data=nil;
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
//    NSURLResponse *response;
//    NSError *error;
//    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSURL *resolved = [response URL];
//    NSString *serverPath = nil;
//    NSString *URLwithPath = [resolved path];
//    serverPath = [URLwithPath stringByDeletingLastPathComponent];
//    //  // NSLog(@"severPath = %@", serverPath);
//    if([serverPath isEqualToString:@"/"]){
//        serverPath = nil;
//    }
//    //   NSRange start= [URLwithPath rangeOfString:@".com/"];
//    //   NSString *serverPath = nil;
//    //   if(start.location != NSNotFound) {
//    //
//    //      serverPath = [URLwithPath substringFromIndex:start.location+start.length];
//    //      NSRange end= [serverPath rangeOfString:@"/"];
//    //      if( end.location != NSNotFound){
//    //         serverPath = [serverPath substringToIndex:end.location];
//    //      }
//    //   }
//    //
//    return serverPath;
//}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    // NSLog(@"top");
}
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}

-(BOOL)shouldAutorotate{
    return YES;
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
        viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/latest/check.json"];
    }
    else {
        // NSLog(@"path %@",path);
        viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/latest/check.json", path];
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
            
            //      [self retryAFRequest];
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


@end
