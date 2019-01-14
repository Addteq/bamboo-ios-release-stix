//
//  SettingTVViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 1/10/13.
//  Edit by Weifeng Zheng 6/2/13
//  Copyright (c) 2013 Matthew Burnett. All rights reserved.
//
#import "SettingTVViewController.h"
#import "NaviController.h"

@implementation SettingTVViewController
@synthesize delegate;
@synthesize tableView = myTableView;
@synthesize serverFull;
@synthesize server;
@synthesize address;
@synthesize port;
@synthesize http;
@synthesize userDefaults;
@synthesize doneButtonItem;
@synthesize cancelButtonItem;
@synthesize isHTTPS;
@synthesize tempText;
@synthesize tempField;
//@synthesize bug;
@synthesize info;

- (void)loadView{
    [super loadView];
    UIView *view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.view = view;
}

- (void)processComplete {
    [[self delegate] updateSuccessful:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    CGRect newframe = self.tableView.frame;
    newframe.origin.x=0;
    newframe.origin.y=0;
    newframe.size.height = [[UIScreen mainScreen] bounds].size.height+44;
    self.tableView.frame = newframe;
    [self.view addSubview:self.tableView];
    [super viewDidLoad];
    [self addBugIcon];
    doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButtonItem];
    cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationController.toolbarHidden = NO;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [myTableView addGestureRecognizer:gestureRecognizer];
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    userDefaults = [NSUserDefaults standardUserDefaults];
    http = [userDefaults stringForKey:kHttp];
    port = [userDefaults stringForKey:kPort];
    address = [userDefaults stringForKey:kBamboo];
    self.isHTTPS=[http compare:@"https"]==0?true:false;
    NSString *tmp = [[userDefaults URLForKey:kServer]absoluteString];
    NSRange range = [tmp rangeOfString:@"file://localhost/"];
    if (range.location != NSNotFound) {
        tmp = [tmp substringFromIndex:range.location+range.length];
    }
    if (tmp.length == 0) {
        if (http.length == 0 || address.length == 0) {
            http = @"http";
            address = @"";
            port = @"";
        } else {
            if (port != nil && port.length != 0) {
                if([address hasSuffix:@"/"]){
                    address = [address stringByReplacingCharactersInRange:NSMakeRange(address.length-1, 1) withString:@""];
                }
                // consider the address which already has path.
                NSArray *stringArray = [address componentsSeparatedByString:@"."];
                if([stringArray count]>=3){
                    NSArray *pathArray = [[stringArray objectAtIndex:2] componentsSeparatedByString:@"/"];
                    if([pathArray count]!=1){
                        if([pathArray objectAtIndex:1]!=nil){
                             serverFull= [[NSString alloc] initWithFormat:@"%@://%@.%@.%@:%@/%@", http, [stringArray objectAtIndex:0], [stringArray objectAtIndex:1],[stringArray objectAtIndex:2], port, [pathArray objectAtIndex:1]];
                        }
                    }
                    
                }
                /*
                NSRange range = [address rangeOfString:@".com" options:NSCaseInsensitiveSearch];
                if((range.location+3)!=address.length-1){
                    serverFull= [[NSString alloc] initWithFormat:@"%@://%@:%@/%@", http, [address substringToIndex:range.location+4] , port, [address substringFromIndex:range.location+5]];
                }else{
                    serverFull= [[NSString alloc] initWithFormat:@"%@://%@:%@", http, address, port];
                }
                serverFull = [[NSString alloc] initWithFormat:@"%@://%@:%@", http, address, port];
                 */
            }else{
                serverFull = [[NSString alloc] initWithFormat:@"%@://%@", http, address];
            }
        }
    } else {
        serverFull = tmp;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    /*if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }*/
    if(![[self.navigationController.toolbar subviews] containsObject:self.info]){
        [self.navigationController.toolbar addSubview:self.info];
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    /*if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }*/
    if([[self.navigationController.toolbar subviews] containsObject:self.info]){
        [self.info removeFromSuperview];
    }
    [super viewWillDisappear:animated];
    [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:animated];
    [userDefaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    http = nil;
    address = nil;
    port = nil;
    serverFull = nil;
}

#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Bamboo Server Address:";
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0){
        if (serverFull.length == 0) {
            return @"No Saved Server";
        } else {
            return serverFull;
        }
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 2;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        //return 3;
        return 2;
    } else if (section == 1){
        return 1;
    } else {
        return nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //bamboo server
        if (indexPath.row == 0) {
            serverCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"serverCell" forIndexPath:indexPath];
            cell.bambooServer.tag = 1;
            cell.bambooServer.text=[userDefaults stringForKey:kBamboo];
            return cell;
        }
        //port number
//        if (indexPath.row == 1) {
//            portCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"portCell" forIndexPath:indexPath];
//            //if (cell==nil) {
//            //    portCell *cell = [[portCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"portCell"];
//            //}
//            cell.portNum.tag = 2;
//            cell.portNum.text=[userDefaults stringForKey:kPort];
//            return cell;
//        }
        //http/https
        if (indexPath.row == 1) {
            httpCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"httpCell" forIndexPath:indexPath];
            if([[userDefaults stringForKey:kHttp] compare:@"https" ]==0)
            {
                cell.http.on = true;
                http = @"https";
            } else {
                cell.http.on=false;
                http = @"http";
            }
            return cell;
        }
    } else if( indexPath.section == 1){
        UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"licenseCell" forIndexPath:indexPath];
        //UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"licenseCell"];
        cell.textLabel.text = @"Acknowledgements";
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)httpSwitch:(UISwitch*)sender {
    if (sender.on) {
        self.isHTTPS = true;
    } else {
        self.isHTTPS = false;
    }
}

- (void)done {
    [self.view endEditing:YES];
    
    dispatch_queue_t backgroundQueueForServerRequests = dispatch_queue_create("DoneButtonPressed",NULL);
    dispatch_async(backgroundQueueForServerRequests, ^(void){
    if (!self.isServerURLNil) {
        [self setServerURL];
        self.untrustedServer = [[NSUserDefaults standardUserDefaults]valueForKey:@"unthrustedURL"];
            
        if (![self.untrustedServer isEqualToString:server]) {
                self.isUnsecureURLWarninginResponse = false;
            } else {
                self.isUnsecureURLWarninginResponse = true;
            }
            
            if (!self.isUnsecureURLWarninginResponse) {
                if(self.isHTTPS == true) {
                    http = @"https";
                }
                else {
                    http = @"http";
                }
                if (serverFull.length == 0) {
                    if (address.length != 0) {
                        if (port.length != 0) {
                            if([address hasSuffix:@"/"]){
                                address = [address stringByReplacingCharactersInRange:NSMakeRange(address.length-1, 1) withString:@""];
                            }
                            NSString *tmpString= [[NSString alloc] init];
                            NSInteger pathlocation = [address rangeOfString:@"/"].location;
                            NSInteger portlocation=0;
                            if(pathlocation==NSNotFound){
                                // no path
                                portlocation = [address rangeOfString:@":"].location;
                                if( portlocation != NSNotFound ){
                                    port =@"";
                                    tmpString= [[NSString alloc] initWithFormat:@"%@://%@", http, address];
                                } else {
                                    tmpString= [[NSString alloc] initWithFormat:@"%@://%@:%@", http, address, port];
                                }
                            } else{
                                // with path
                                NSString *therest = [address substringFromIndex:pathlocation];
                                NSString *front = [address substringToIndex:pathlocation];
                                portlocation = [front rangeOfString:@":"].location;
                                if( portlocation != NSNotFound ){
                                    port =@"";
                                    tmpString= [[NSString alloc] initWithFormat:@"%@://%@", http, address];
                                } else {
                                    tmpString= [[NSString alloc] initWithFormat:@"%@://%@:%@%@", http, front, port, therest];
                                }
                                
                            }
                             NSURL *candidateURL = [NSURL URLWithString:tmpString];
                            if (candidateURL && candidateURL.scheme && candidateURL.host && candidateURL.port) {
                                serverFull = tmpString;
                                //                    [userDefaults setValue:http forKey:kHttp];
                                //                    [userDefaults setValue:address forKey:kBamboo];
                                //                    [userDefaults setValue:port forKey:kPort];
                                //                    [userDefaults setURL:[NSURL URLWithString:serverFull] forKey:kServer];
                                self.tempHttp = http;
                                self.tempAddress = address;
                                self.port = port;
                                self.serverFull = serverFull;
                            }
                        } else {
                            NSString *tmpString = [[NSString alloc] initWithFormat:@"%@://%@", http, address];
                            NSURL *candidateURL = [NSURL URLWithString:tmpString];
                            if (candidateURL && candidateURL.scheme && candidateURL.host) {
                                serverFull = tmpString;
                                //                    [userDefaults setValue:http forKey:kHttp];
                                //                    [userDefaults setValue:address forKey:kBamboo];
                                //                    [userDefaults setValue:@"" forKey:kPort];
                                //                    [userDefaults setURL:[NSURL URLWithString:serverFull] forKey:kServer];
                                self.tempHttp = http;
                                self.tempAddress = address;
                                self.port = port;
                                self.serverFull = serverFull;
                            }
                        }
                    }
                } else {
                    NSString* temp = [[NSString alloc]initWithFormat:@"%@://",http];
                    serverFull = [serverFull stringByReplacingOccurrencesOfString:@"https://" withString:temp];
                    serverFull = [serverFull stringByReplacingOccurrencesOfString:@"http://" withString:temp];
                    self.tempHttp = http;
                    self.tempAddress = address;
                    self.port = port;
                    self.serverFull = serverFull;
                }
                [self setServerURL];
                [self checkForLicence];
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *securityAlert = [[UIAlertView alloc]initWithTitle:@"The certificate for this server is invalid" message:@"You might be connecting to a server that is pretending to be safe. This may put your confidential information at risk."delegate:self cancelButtonTitle:@"Proceed anyway"  otherButtonTitles:@"Back to safety", nil];
                    [securityAlert show];
                });
                
            }
        }
    });
}

#pragma Check for valid Licence
- (void) setServerURL {
    NSString *tmp = self.serverFull;
    NSRange range = [tmp rangeOfString:@"file://localhost/"];
    if (range.location != NSNotFound) {
        tmp = [tmp substringFromIndex:range.location+range.length];
    }
    if ( tmp == NULL || tmp.length == 0) {
        NSString *bamboo = self.address;
        port = self.port;
        http = self.http;
        if (http != nil && http.length != 0) {
            if (bamboo != nil && bamboo.length != 0) {
                if (![port isEqualToString:@""] && port != NULL &  port.length != 0) {
                    server = [[NSString alloc] initWithFormat:@"%@://%@:%@", http, bamboo, port];
                }else{
                    server = [[NSString alloc] initWithFormat:@"%@://%@", http, bamboo];
                }
            }
        }
    } else {
        server = tmp;
    }
}
- (void)checkForLicence {
    self.myclient = [[myAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [self.myclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self.myclient setDefaultHeader:@"Accept" value:@"application/json"];
    [self.myclient setParameterEncoding:AFJSONParameterEncoding];
    self.path = [self resolvePath:server];
    [userDefaults setValue:self.path forKey:kPath];
    if (self.isUnsecureURLWarninginResponse == false) {

    }
    NSString *viewURL = nil;
    if([self.path isKindOfClass:[NSNull class]] || self.path == NULL) {
        viewURL = [[NSString alloc] initWithFormat:@"/rest/addteqrest/latest/check.json"];
    } else {
        viewURL = [[NSString alloc] initWithFormat:@"%@/rest/addteqrest/latest/check.json", self.path];
    }
    
    [self.myclient getPath:viewURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[client getPath:viewURL parameters:nil username:userName password:password success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary* json = responseObject;
        NSString *version = [json objectForKey:@"Version"];
        NSString *licenceType = [json objectForKey:@"Type"];
        NSString *expirationDate = [json objectForKey:@"Expiration"];
        NSDateFormatter *dateFormatterForExpirationDate = [[NSDateFormatter alloc] init];
        [dateFormatterForExpirationDate setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSSZZZZ"];
        NSDate *expDateFromString = [dateFormatterForExpirationDate dateFromString:expirationDate];
        NSString *strDate = [dateFormatterForExpirationDate stringFromDate:[NSDate date]];
        NSDate *dateFromString = [dateFormatterForExpirationDate dateFromString:strDate];
        
        //version is 1.1
        if ([version isEqualToString:@"1.1"]) {
            // licence type is Evaluation
            if ([licenceType isEqualToString:@"Evaluation"]) {
                // check whether licence expired
                NSUserDefaults *userDefaultsToStoreExpirationDate = [NSUserDefaults standardUserDefaults];
                [userDefaultsToStoreExpirationDate setValue:expDateFromString forKey:@"licenceExpirationDate"];
                if([dateFromString compare:expDateFromString] == NSOrderedAscending ){
                    //dismiss
                    [self performSelector:@selector(processComplete)];
                            [userDefaults setValue:self.tempHttp forKey:kHttp];
                            [userDefaults setValue:self.tempAddress forKey:kBamboo];
                            [userDefaults setValue:self.tempPort forKey:kPort];
                            [userDefaults setURL:[NSURL URLWithString:self.tempServerFull] forKey:kServer];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertExpiredLicence = [[UIAlertView alloc]initWithTitle:@"Plugin license expired" message:@"Your plugin license in server is expired. Please renew." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Renew", nil];
                        [alertExpiredLicence show];
                    });
                }
            }  //licence type is commercial
            else if ([licenceType isEqualToString:@"Commercial"]) {
                //dismiss
                [self performSelector:@selector(processComplete)];
                [userDefaults setValue:self.tempHttp forKey:kHttp];
                [userDefaults setValue:self.tempAddress forKey:kBamboo];
                [userDefaults setValue:self.tempPort forKey:kPort];
                [userDefaults setURL:[NSURL URLWithString:self.tempServerFull] forKey:kServer];
            } // licence type is Unlicenced
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertInvalidLicence = [[UIAlertView alloc]
                               initWithTitle:@"Invalid License"
                               message:@"No valid license found for the stix plugin"
                               delegate: nil
                               cancelButtonTitle: @"Close"
                               otherButtonTitles: nil];
                alertInvalidLicence.alertViewStyle=UIAlertViewStyleDefault;
                [alertInvalidLicence show];
                });
            }
        }//version NOT is 1.1
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertForOldVersions = [[UIAlertView alloc]initWithTitle:@"Needs Latest Plugin" message:@"It appears that the plugin in the server is not updated for latest version. Please update the plugin. " delegate:self cancelButtonTitle:@"Download" otherButtonTitles:@"Cancel", nil];
                [alertForOldVersions show];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.isUnsecureURLWarninginResponse == false) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            // delete cookies
            [self.myclient clearAuthorizationHeader];
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([error.description rangeOfString:@"NSURLErrorDomain Code=-1003" ].location != NSNotFound){
                    [[[UIAlertView alloc] initWithTitle:@"Invalid Url" message:@"The URL entered appears to be invalid. Please enter a valid server address" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil] show];
                }
                if([error.description rangeOfString:@"NSURLErrorDomain Code=-1004" ].location != NSNotFound){
                    [[[UIAlertView alloc] initWithTitle:@"Invalid Url" message:@"Could not connect to the server. Please enter a valid server address" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil] show];
                }
                if ([operation.response statusCode] == 401) {
                    if([error.description rangeOfString:@"AUTHENTICATED_FAILED"].location == NSNotFound && [error.description rangeOfString:@"AUTHENTICATION_DENIED"].location == NSNotFound)
                    {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Cannot reach server"
                                       message:@"Please update the plugin in the server. Click Download to get the latest version of plugin."
                                       delegate: self
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles:@"Download", nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    } else {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Authentication Denied"
                                       message:@"Username or Password incorrect. Please try again or check with the Administrator."
                                       delegate: nil
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                }
                if([operation.response statusCode] == 404) {
                    if([error.description rangeOfString:@"ErrorDomain Code=-1011"].location != NSNotFound){
                        //        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Couldn't find the STIX plugin on server for authentication. Please download the plugin to enable functionality." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Error"
                                       message: @"Couldn't find the STIX plugin on server for authentication. Please download the plugin to enable functionality."
                                       delegate: self
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: @"Download", nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    } else {
                        UIAlertView *alertDialog;
                        alertDialog = [[UIAlertView alloc]
                                       initWithTitle:@"Authentication Denied"
                                       message:@"Username or Password incorrect. Please try again or check with the Administrator."
                                       delegate: nil
                                       cancelButtonTitle: @"Close"
                                       otherButtonTitles: nil];
                        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                        [alertDialog show];
                    }
                } else if([operation.response statusCode] == 503){
                    UIAlertView *alertDialog;
                    alertDialog = [[UIAlertView alloc]
                                   initWithTitle:@"Cannot reach server"
                                   message:@"Please update the plugin in the server. Click Download to get the latest version of plugin."
                                   delegate: self
                                   cancelButtonTitle: @"Close"
                                   otherButtonTitles:@"Download", nil];
                    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                    [alertDialog show];
                } else {
                    if(error) {
                        //change here
                        //if it is self signed problem
                        if ([error.description rangeOfString:@"ErrorDomain Code=-1202"].location != NSNotFound) {
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"OK ", nil] show];
                        } else if([error.description rangeOfString:@"ErrorDomain Code=-1200"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Server returned an unsecure response but it looks like you are using https. Please check your settings and try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        } else if([error.description rangeOfString:@"ErrorDomain Code=-1001"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Request Timed out. Please try again." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                        } else if([error.description rangeOfString:@"400 Bad Request"].location != NSNotFound){
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot reach the server", nil) message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                        } else {
                            if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound)
                            {
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not a valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                            } else {
                                // NSLog(@"400 ===> %@",[error localizedDescription]);
                                //
                                //                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                            }
                        }/*
                          else if([error.description rangeOfString:@"ErrorDomain Code=-1016"].location != NSNotFound){
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"The bamboo server that you are trying to access is not valid Bamboo server." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
                          }else
                          {
                          if([error.description rangeOfString:@"400 Bad Request"].location != NSNotFound)
                          {
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot reach the server", nil) message:@"Server returned a secure response but it looks like you are using http. Please check your settings and try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                          
                          }
                          else
                          {
                          //// // // // NSLog(@"400 ===> %@",[error localizedDescription]);
                          
                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                          }
                          }*/
                    }
                }
            });
        }
    }];
}

- (NSString *)resolvePath:(NSString *)serverAddress {
    NSString *base = serverAddress;
    NSURL *originalUrl=[NSURL URLWithString:base];
    NSData *data=nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response == nil && [error.description rangeOfString:@"ErrorDomain Code=-1202"].location != NSNotFound) {
      
        dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *securityAlert = [[UIAlertView alloc]initWithTitle:@"The certificate for this server is invalid" message:@"You might be connecting to a server that is pretending to be safe. This may put your confidential information at risk."delegate:self cancelButtonTitle:@"Proceed anyway"  otherButtonTitles:@"Back to safety", nil];
            [securityAlert show];
        });
        
        self.isUnsecureURLWarninginResponse = true;
        [[NSUserDefaults standardUserDefaults]setValue:server forKey:@"unthrustedURL"];
    } else {
        self.isUnsecureURLWarninginResponse = false;
    }
    NSURL *resolved = [response URL];
    NSString *serverPath = nil;
    //NSString *URLwithPath = [resolved path];
    
    NSString *test = [[resolved path] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    NSRange range = [test rangeOfString:@"/" options:NSCaseInsensitiveSearch];
    
    if(range.location == NSNotFound){
        if(test.length==0){
            serverPath=nil;
        }else{
            serverPath=[resolved path];
        }
    } else {
        serverPath = [[resolved path] substringToIndex:range.location+1];
    }
    if([serverPath isEqualToString:@"/allPlans.action"] || [serverPath isEqualToString:@"/userlogin!doDefault.action"] || ([serverPath rangeOfString:@"/userlogin!doDefault.action"].location != NSNotFound) || [serverPath isEqualToString:@"/userlogin!default.action"] || ([serverPath rangeOfString:@"/userlogin!default.action"].location != NSNotFound) || [serverPath isEqualToString:@"/"]){
        serverPath=nil;
    }
    return serverPath;
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Download"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://marketplace.atlassian.com/plugins/com.addteq.bamboo.plugin.addteq-bamboo-plugin"]];
    }
    if ([buttonTitle isEqualToString:@"Renew"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://marketplace.atlassian.com/plugins/com.addteq.bamboo.plugin.addteq-bamboo-plugin"]];
    }
    if ([buttonTitle isEqualToString:@"Proceed anyway"]){
         self.untrustedServer = nil;
         self.isUnsecureURLWarninginResponse = false;
         [[NSUserDefaults standardUserDefaults]setValue:@"^~" forKey:@"unthrustedURL"];
         [self done];
     }
}

- (IBAction)help:(id)sender {
    UIAlertView *alertDialog;
    alertDialog = [[UIAlertView alloc]
                   initWithTitle:@"Help"
                   message:@"Please input your Bamboo server settings here. Only input your server in one set of fields. Ensure the server has Addteq's Bamboo plugin installed on the specified server."
                   delegate: self
                   cancelButtonTitle: @"Close"
                   otherButtonTitles: nil];
    alertDialog.alertViewStyle=UIAlertViewStyleDefault;
    [alertDialog show];
}

- (IBAction)showFeedback:(id)sender {
    [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)cancelEdit {
    tempField.text = tempText;
    [self.view endEditing:YES];
}

- (void)cancel {
    [self.view endEditing:YES];
    if (!self.isServerURLNil) {
    [self dismissViewControllerAnimated:YES completion:nil];
        self.isServerURLNil = false;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    tempField = textField;
    tempText = textField.text;
    //  doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    //    self.navigationItem.rightBarButtonItem = doneButtonItem;
    //    cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEdit)];
    //    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    //    self.navigationItem.leftBarButtonItem = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
   //  self.output Label.text = newString;
   //   myTableView.contentOffset = tmpOffset;
   //   [textField resignFirstResponder];
    if (textField.tag == 1) {
        if (textField.text != nil && textField.text.length != 0) {
            serverFull = @"";
            address = newString;
            // NSLog(@"tag Fix Address %@ %@",address, port);
            //[userDefaults setValue:address forKey:kBamboo];
        }
    }
    if (textField.tag == 2) {
        //        if (textField.text != nil && textField.text.length != 0) {
        serverFull = @"";
        port = newString;
        // NSLog(@"tag Fix Port %@ %@",address, port);
        //[userDefaults setValue:port forKey:kPort];
        //}
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    // NSLog(@"here end editing");
    //   myTableView.contentOffset = tmpOffset;
    [textField resignFirstResponder];
    //    if (textField.tag == 0) {
    //        if (textField.text != nil && textField.text.length != 0) {
    //            serverFull = textField.text;
    //            //            address = @"";
    //            //            port = @"";
    //
    //        }
    //    }
    if (textField.tag == 1) {
        if (textField.text != nil && textField.text.length != 0) {
            serverFull = @"";
            address = textField.text;
            //[userDefaults setValue:address forKey:kBamboo];
            self.isServerURLNil = false;
        } else {
        self.isServerURLNil = true;
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Server is Blank"
                       message:@"Your server setting is blank, please update your settings."
                       delegate: nil
                       cancelButtonTitle: nil
                       otherButtonTitles: @"Edit Settings", nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
        }
    }
    if (textField.tag == 2) {
        //        if (textField.text != nil && textField.text.length != 0) {
        serverFull = @"";
        port = textField.text;
        //[userDefaults setValue:port forKey:kPort];
        //}
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield{
    [textfield resignFirstResponder];
    switch (textfield.tag) {
            //        case 0:
            //            //Full Server
            //            serverFull = [textfield text];
            //            break;
        case 1:
            //Address URL
            address = [textfield text];
            break;
        case 2:
            //Port Number
            port = [textfield text];
            break;
        default:
            break;
    }
    return YES;
}

- (void)addBugIcon {
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
    [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.clipsToBounds=YES;
    
    /*self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    }else{
        self.bug.frame = CGRectMake(285,10,28,28);
    }
    [self.bug setImage:[UIImage imageNamed:@"blueBug.png"] forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];*/
    
    self.info = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.info.frame = CGRectMake(10,10,28,28);
    }else{
        self.info.frame = CGRectMake(10,10,28,28);
    }
    [self.info setImage:[UIImage imageNamed:@"myInfoButton.png"] forState:UIControlStateNormal];
    [self.info addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.info];
    [self.navigationController setToolbarHidden:YES];
}

@end