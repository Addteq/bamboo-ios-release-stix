//
//  LogViewController.m
//  Bamboo
//
//  Created by You Liang Low on 11/30/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "LogViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SavedLogsViewController.h"
#import "NaviController.h"
#define kBamboo @"bamboo_url"
#define kPort @"port_num"
#define kHttp @"http"
#define kBasePath @"baseWithPath"

@interface LogViewController ()

@end

@implementation LogViewController {
   CGFloat startContentOffset;
   CGFloat lastContentOffset;
   BOOL hidden;
}
@synthesize logLine;
@synthesize infoList;
@synthesize errorList;
@synthesize fullList;
@synthesize summaryList;
@synthesize infoString;
@synthesize errorString;
@synthesize fullString;
@synthesize summaryString;
@synthesize numFull;
@synthesize numInfo;
@synthesize numError;
@synthesize jobKey;
@synthesize jobBuildKey;
@synthesize log;
@synthesize logSize;
@synthesize documentController;
@synthesize hud;
@synthesize server;
@synthesize path;
@synthesize logSegment;
@synthesize logView;
@synthesize client;
@synthesize planKey;
@synthesize dirPath;
@synthesize menuButton;
@synthesize actionSh;
@synthesize bug;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      // Custom initialization
   }
   return self;
}

-(void) viewWillAppear:(BOOL)animated{
    if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }
    [super viewWillAppear:animated];
}
-(void) viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.actionSh.visible){
            [self.actionSh dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
   
 //  logSegment.segmentedControlStyle = 7;
   logView.contentInset = UIEdgeInsetsMake(0,0,0,0);
   infoList = [[NSMutableArray alloc] init];
   errorList = [[NSMutableArray alloc] init];
   summaryList = [[NSMutableArray alloc] init];
   fullList = [[NSMutableArray alloc] init];
   
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"text/plain"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    self.navigationController.toolbarHidden = NO;
    //[self addBugIcon];
   [self processLogs];
    
    
   [super viewDidLoad];
   
   
	// Do any additional setup after loading the view.
}

- (void) processLogs {
   
   [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
   hud = [[MBProgressHUD alloc] initWithView:self.view];
   [self.view addSubview:hud];
   [hud setLabelText:@"Loading..."];
   hud.dimBackground = YES;
   [hud show:YES];
   
   jobKey = [self getJobKey:jobBuildKey];
   //// NSLog(@"Job Key:%@", jobKey);
   //// NSLog(@"Job Build Key:%@", jobBuildKey);
   NSString *logsURL = [[NSString alloc] initWithFormat:@"/download/%@/build_logs/%@.log",jobKey, jobBuildKey];
   NSString *logPath = nil;
   if([path isKindOfClass:[NSNull class]] || path == NULL) {
      logPath = [[NSString alloc] initWithFormat:@"%@", logsURL];
   }
   else {
      logPath = [[NSString alloc] initWithFormat:@"%@%@", path, logsURL];
   }
    // NSLog(@"Process log %@", logPath);
    /*
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *each in cookies) {
        [cookieStorage deleteCookie:each];
        // NSLog(@"delete cookie");
    }
    */
    
//    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
//    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    [client setDefaultHeader:@"Accept" value:@"text/plain"];
//    [client setParameterEncoding:AFJSONParameterEncoding];
    [client getPath:logPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        logSize = [response length];
        log = response;
        
        [self parseLogs:response];
        NSRange pageNotFoundRange1 = [response rangeOfString:@"Page Not Found"];
        //Temp solution when log file website does not exist
        if(pageNotFoundRange1.location != NSNotFound) {
            fullString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            infoString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            errorString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            summaryString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
        }
        else {
            fullString = @"To view full log, please download and open it with a Text Editor";
            infoString = @"Info Log:\n";
            
            if([infoList count] < 50) {
                
                int infoSize = (int)[infoList count];
                numInfo = [NSNumber numberWithInt:infoSize];
                NSString *infoDetail = [[NSString alloc] initWithFormat:@"%@ of lines availabe of total %@\n", numInfo, numInfo];
                infoString = [infoString stringByAppendingString:infoDetail];
                int i = 0;
                for(i = 0; i < [infoList count]; i++) {
                    
                    infoString = [infoString stringByAppendingString:@"\n"];
                    infoString = [infoString stringByAppendingString:[infoList objectAtIndex:i]];
                    
                }
                
            }
            else {
                
                int infoSize = (int)[infoList count];
                numInfo = [NSNumber numberWithInt:infoSize];
                NSString *infoDetail = [[NSString alloc] initWithFormat:@"50 of lines availabe of total %@\n", numInfo];
                infoString = [infoString stringByAppendingString:infoDetail];
                int i = 0;
                for(i = 0; i < [infoList count]; i++) {
                    
                    if(i < 50) {
                        infoString = [infoString stringByAppendingString:@"\n"];
                        infoString = [infoString stringByAppendingString:[infoList objectAtIndex:i]];
                    }
                    
                }
                
                
            }
        }
        
        errorString = @"Error Log:\n";
        
        int size = (int)[errorList count];
        numError = [NSNumber numberWithInt:size];
        NSString *errorDetail = [[NSString alloc] initWithFormat:@"%@ of lines availabe of total %@\n", numError, numError];
        
        errorString = [errorString stringByAppendingString:errorDetail];
        
        int k = 0;
        for(k = 0; k < [errorList count]; k++) {
            
            if(k < 50) {
                numError = [NSNumber numberWithInt:50];
                errorString = [errorString stringByAppendingString:@"\n"];
                errorString = [errorString stringByAppendingString:[errorList objectAtIndex:k]];
            }
        }
        
        summaryString = @"Summary Log:\n";
        
        int l = 0;
        for(l = 0; l < [summaryList count]; l++) {
            
            if(l < 50) {
                summaryString = [summaryString stringByAppendingString:@"\n"];
                summaryString = [summaryString stringByAppendingString:[summaryList objectAtIndex:l]];
            }
        }
        
        [self changeSegment];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([operation.response statusCode] == 401) {
           
            [self loggingIn:0];
        }else if([operation.response statusCode]==404){
            
            fullString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            infoString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            errorString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            summaryString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            [self changeSegment];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             
        }else if([operation.response statusCode]==403){
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
        else {
            
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
        }
        
        // NSLog(@"Network Request Error:%@", error);

        
    }];
   [hud show:NO];
}

- (void) retryGetLogs{
    
    jobKey = [self getJobKey:jobBuildKey];
    //// NSLog(@"Job Key:%@", jobKey);
    //// NSLog(@"Job Build Key:%@", jobBuildKey);
    NSString *logsURL = [[NSString alloc] initWithFormat:@"/download/%@/build_logs/%@.log",jobKey, jobBuildKey];
    NSString *logPath = nil;
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        logPath = [[NSString alloc] initWithFormat:@"%@", logsURL];
    }
    else {
        logPath = [[NSString alloc] initWithFormat:@"%@%@", path, logsURL];
    }
    
    //    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    //    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //    [client setDefaultHeader:@"Accept" value:@"text/plain"];
    //    [client setParameterEncoding:AFJSONParameterEncoding];
    [client getPath:logPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        logSize = [response length];
        log = response;
        
        [self parseLogs:response];
        NSRange pageNotFoundRange1 = [response rangeOfString:@"Page Not Found"];
        //Temp solution when log file website does not exist
        if(pageNotFoundRange1.location != NSNotFound) {
            fullString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            infoString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            errorString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            summaryString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
        }
        else {
            fullString = @"To view full log, please download and open it with a Text Editor";
            infoString = @"Info Log:\n";
            
            if([infoList count] < 50) {
                
                int infoSize = (int)[infoList count];
                numInfo = [NSNumber numberWithInt:infoSize];
                NSString *infoDetail = [[NSString alloc] initWithFormat:@"%@ of lines availabe of total %@\n", numInfo, numInfo];
                infoString = [infoString stringByAppendingString:infoDetail];
                int i = 0;
                for(i = 0; i < [infoList count]; i++) {
                    
                    infoString = [infoString stringByAppendingString:@"\n"];
                    infoString = [infoString stringByAppendingString:[infoList objectAtIndex:i]];
                    
                }
                
            }
            else {
                
                int infoSize = (int)[infoList count];
                numInfo = [NSNumber numberWithInt:infoSize];
                NSString *infoDetail = [[NSString alloc] initWithFormat:@"50 of lines availabe of total %@\n", numInfo];
                infoString = [infoString stringByAppendingString:infoDetail];
                int i = 0;
                for(i = 0; i < [infoList count]; i++) {
                    
                    if(i < 50) {
                        infoString = [infoString stringByAppendingString:@"\n"];
                        infoString = [infoString stringByAppendingString:[infoList objectAtIndex:i]];
                    }
                    
                }
                
                
            }
        }
        
        errorString = @"Error Log:\n";
        
        int size = (int)[errorList count];
        numError = [NSNumber numberWithInt:size];
        NSString *errorDetail = [[NSString alloc] initWithFormat:@"%@ of lines availabe of total %@\n", numError, numError];
        
        errorString = [errorString stringByAppendingString:errorDetail];
        
        int k = 0;
        for(k = 0; k < [errorList count]; k++) {
            
            if(k < 50) {
                numError = [NSNumber numberWithInt:50];
                errorString = [errorString stringByAppendingString:@"\n"];
                errorString = [errorString stringByAppendingString:[errorList objectAtIndex:k]];
            }
        }
        
        summaryString = @"Summary Log:\n";
        
        int l = 0;
        for(l = 0; l < [summaryList count]; l++) {
            
            if(l < 50) {
                summaryString = [summaryString stringByAppendingString:@"\n"];
                summaryString = [summaryString stringByAppendingString:[summaryList objectAtIndex:l]];
            }
        }
        
        [self changeSegment];
        [hud hide:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
        if([operation.response statusCode] == 404) {
            fullString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            infoString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            errorString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            summaryString = [[NSString alloc] initWithFormat:@"No log found for %@", jobBuildKey];
            [self changeSegment];
            [hud hide:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        else {
            
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
            
        }
               
        // NSLog(@"Network Request Error:%@", error);
        
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [self setActionSh:nil];
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (NSString*) getJobKey:(NSString*) BuildKey {
   
   NSString *key = nil;
   NSString *notKey = nil;
   NSString *tempKey = nil;
   
   NSRange dashRange = [BuildKey rangeOfString:@"-"];
   if(dashRange.location != NSNotFound) {
      
      key = [BuildKey substringToIndex:dashRange.location+dashRange.length];
      notKey = [BuildKey substringFromIndex:dashRange.location+dashRange.length];
      //// NSLog(@"Key 1:%@", key);
      //// NSLog(@"Not Key 1:%@", notKey);
      
      NSRange dashRange1 = [notKey rangeOfString:@"-"];
      
      if(dashRange1.location != NSNotFound) {
         tempKey = [notKey substringToIndex:dashRange1.location+dashRange1.length];
         key = [[NSString alloc] initWithFormat:@"%@%@",key,tempKey];
         notKey = [notKey substringFromIndex:dashRange1.location+dashRange1.length];
         //// NSLog(@"Key 2:%@", key);
         //// NSLog(@"Not Key 2:%@", notKey);
         
         NSRange dashRange2 = [notKey rangeOfString:@"-"];
         if(dashRange2.location != NSNotFound) {
            tempKey = [notKey substringToIndex:dashRange2.location];
            key = [[NSString alloc] initWithFormat:@"%@%@",key,tempKey];
            notKey = [notKey substringFromIndex:dashRange2.location+dashRange2.length];
            //// NSLog(@"Key 3:%@", key);
            //// NSLog(@"Not Key 3:%@", notKey);
         }
      }
   }
   return key;
}

- (void) parseLogs:(NSString*)data {
   
   NSRange pageNotFoundRange = [data rangeOfString:@"Page Not Found"];
   
   //Temp solution when log file website does not exist (response is
   if(pageNotFoundRange.location != NSNotFound) {
      return;
   }
   else {
      
      logLine = [data componentsSeparatedByString:@"\n"];
      
      int i = 0;
      for(i = 0; i < [logLine count]; i++) {
         
         NSString *line = logLine[i];
         
         if([line length] > 0) {
            NSString* category = [line substringToIndex:5];
            
            if([category isEqualToString:@"error"]) {
               
               [errorList addObject:[[NSString alloc] initWithFormat:@"%@\n", line]];
            }
            else {
               
               [infoList addObject:[[NSString alloc] initWithFormat:@"%@\n", line]];
            }
            [fullList addObject:[[NSString alloc] initWithFormat:@"%@\n", line]];
            
            NSRange completedRange = [line rangeOfString:@"completed"];
            NSRange finBuildingRange = [line rangeOfString:@"Finished building"];
            NSRange infoBuildRange = [line rangeOfString:@"[INFO] BUILD"];
            
            if(completedRange.location != NSNotFound) {
               
               [summaryList addObject:line];
            }
            
            if(finBuildingRange.location != NSNotFound) {
               
               [summaryList addObject:line];
            }
            else {
               
               if(infoBuildRange.location != NSNotFound) {
                  
                  int i = 0;
                  for(i = 0; i < 6; i++) {
                     
                     [summaryList addObject:[[NSString alloc] initWithFormat:@"%@\n", line]];
                  }
               }
            }
         }
      }
   }
}

- (IBAction)changeSegment {
   
   if(logSegment.selectedSegmentIndex == 0) {
       
      if ((fullString.length != 0) && ![fullString isEqualToString:@""]) {
//         // NSLog(@"Full String %@", fullString);
         self.logView.text = fullString;
      }
   }
   if(logSegment.selectedSegmentIndex == 1) {
      
      self.logView.text = infoString;
   }
   if(logSegment.selectedSegmentIndex == 2) {
      
      self.logView.text = errorString;
      
   }
   if(logSegment.selectedSegmentIndex == 3) {
      
      self.logView.text = summaryString;
      
   }
   
}

- (IBAction)showFeedback:(id)sender {
   [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (void) saveLog {
   
  NSString *logData = log;
  
  NSRange pageNotFoundRange = [logData rangeOfString:@"Page Not Found"];
  
  //Temp solution when log file website does not exist
  if(pageNotFoundRange.location != NSNotFound) {
     
     UIAlertView *alertDialog;
     alertDialog = [[UIAlertView alloc]
                    initWithTitle:@"Log File"
                    message:nil
                    delegate: self
                    cancelButtonTitle: @"OK"
                    otherButtonTitles: nil];
     NSString *fileNotFoundMsg = [[NSString alloc] initWithFormat:@"No log file exists for %@", jobBuildKey];
     [alertDialog setMessage:fileNotFoundMsg];
     alertDialog.alertViewStyle=UIAlertViewStyleDefault;
     [alertDialog show];
  }
  else {
     
     NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                                                             NSDocumentDirectory,
                                                             NSUserDomainMask, YES)objectAtIndex: 0];
     
     NSString *logFilename = [[NSString alloc] initWithFormat:@"%@_log.txt", jobBuildKey];
     
     NSString *logFilePath = [docDir
                              stringByAppendingPathComponent:logFilename];
     
     if  (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager]
         createFileAtPath:logFilePath contents:nil attributes:nil];
     }
     
     NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
     //[fileHandle seekToEndOfFile];
     [fileHandle writeData:[logData
                            dataUsingEncoding:NSUTF8StringEncoding]];
     [fileHandle closeFile];
     
     unsigned long long fsize = [[NSFileHandle fileHandleForReadingAtPath:logFilePath] seekToEndOfFile];
     ////// NSLog(@"File size of log: %lld", fsize);
     
     if(fsize == logSize) {
        NSString *shortPath = [logFilePath lastPathComponent];
        NSString *pathToLog = [[NSString alloc] initWithFormat:@"Log file located at ../Documents/%@", shortPath];
        
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"Log file saved"
                       message:pathToLog
                       delegate: self
                       cancelButtonTitle: @"OK"
                       otherButtonTitles: nil];
        alertDialog.alertViewStyle=UIAlertViewStyleDefault;
        [alertDialog show];
        
     }
  }
}

- (IBAction)showActionSheet:(id)sender {
   UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
   //Action Sheet Title
   NSString *actionSheetTitle = @"Logs";
   //Action Sheet Button Titles
//   NSString *build = @"Start Build";
    NSString *helpTitle = @"Help";
   NSString *logout = @"Logout";
   NSString *cancelTitle = @"Cancel";
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSString *guest = [userDefaults stringForKey:@"guest"];
   if ([guest isEqualToString:@"guest"]) {
      //Hide play button
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:logout
                                       otherButtonTitles:helpTitle, nil];
   }else{
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:logout
                                        otherButtonTitles:helpTitle, nil];
//                                       otherButtonTitles:build, nil];
   }
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
    self.actionSh = actionSheet;
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
        if ([buttonTitle isEqualToString:@"Cancel"]) {
            //// NSLog(@"Cancel clicked");
        }else if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if ([buttonTitle isEqualToString:@"Start Build"]) {
            NSString *message = [[NSString alloc] initWithFormat:@"Are you sure you would like to start %@?", planKey];
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Confirm Build"
                           message:message
                           delegate: self
                           cancelButtonTitle: @"Cancel"
                           otherButtonTitles: @"Yes", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }else if([buttonTitle isEqualToString:@"Help"]){
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen shows you the logs of the selected job. You can save this log file to your device and open it in your favorite text editor to view it in its entirety."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }

    
   }
}

- (IBAction)downloadLog:(id)sender {
   UIAlertView *alertDialog;
   alertDialog = [[UIAlertView alloc]
                  initWithTitle:@"Download Log File"
                  message:nil
                  delegate: self
                  cancelButtonTitle: @"Cancel"
                  otherButtonTitles: @"Download", @"Previous Logs", nil];
   alertDialog.alertViewStyle=UIAlertViewStyleDefault;
   [alertDialog show];
}

- (IBAction)openLog:(id)sender {
   
   
   NSString *logData = log;
   
   NSRange pageNotFoundRange = [logData rangeOfString:@"Page Not Found"];
   
   //Temp solution when log file website does not exist
   if(pageNotFoundRange.location != NSNotFound) {
      
      UIAlertView *alertDialog;
      alertDialog = [[UIAlertView alloc]
                     initWithTitle:@"Log File"
                     message:nil
                     delegate: self
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
      NSString *fileNotFoundMsg = [[NSString alloc] initWithFormat:@"No log file exists for %@", jobBuildKey];
      [alertDialog setMessage:fileNotFoundMsg];
      alertDialog.alertViewStyle=UIAlertViewStyleDefault;
      [alertDialog show];
      
   }
   else {
      
      NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                                                              NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex: 0];
      NSString *logFilename = [[NSString alloc] initWithFormat:@"%@_log.txt", jobBuildKey];
      
      NSString *logFilePath = [docDir
                               stringByAppendingPathComponent:
                               logFilename];
      
      if([self checkIfLogExists:logFilePath] == YES) {
         
         // NSLog(@"Opening file in text editor %@", logFilePath);
         self.documentController = [[UIDocumentInteractionController alloc] init];
         self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:logFilePath]];
         
         self.documentController.delegate = self;
         
         self.documentController.UTI = @"public.plain-text";
         //[self.documentController presentOpenInMenuFromRect:CGRectZero
                                            //    inView:self.view
                                           //   animated:YES];
          [self.documentController presentPreviewAnimated:YES];
      }
      else {
         
         UIAlertView *alertDialog;
         alertDialog = [[UIAlertView alloc]
                        initWithTitle:@"Open Log"
                        message:@"Log file does not exists, please download log file"
                        delegate: self
                        cancelButtonTitle: @"Cancel"
                        otherButtonTitles: @"Download", nil];
         alertDialog.alertViewStyle=UIAlertViewStyleDefault;
         [alertDialog show];
         
         
      }
   }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
	return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
	return self.view.frame;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
   if([title isEqualToString:@"Cancel"]) {
      
   }
   else if([title isEqualToString:@"Try Again"]){
      [self processLogs];
   }
   else if([title isEqualToString:@"Retry"]){
       [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
       hud = [[MBProgressHUD alloc] initWithView:self.view];
       [self.view addSubview:hud];
       [hud setLabelText:@"Loading..."];
       hud.dimBackground = YES;
       [hud show:YES];
       [self loggingIn:0];
   }
   else if([title isEqualToString:@"Download"])
   {
      [self saveLog];
   }
   else if([title isEqualToString:@"Previous Logs"]){
      // NSLog(@"Previous Logs");
      SavedLogsViewController *slvc;
       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
       {
           UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
           slvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"savedLogs"];
       }
       else
       {
           UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
           slvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"savedLogs"];
       }
      
      
      slvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
      slvc.modalPresentationStyle=UIModalPresentationFullScreen;
      dirPath = [NSSearchPathForDirectoriesInDomains(
                                                     NSDocumentDirectory,
                                                     NSUserDomainMask, YES) objectAtIndex: 0];
      // NSLog(@"Directory %@", dirPath);
      slvc.dirPath = dirPath;
      slvc.server = server;
      slvc.path = path;
      [self.navigationController pushViewController:slvc animated:YES];
   }
   else if([title isEqualToString:@"Yes"])
   {
      //Start Build here.
      //Post to queue URL - rest/api/latest/queue
      NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
      
      if([path isKindOfClass:[NSNull class]] || path == NULL) {
         planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
      }else{
         planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
      }
       
//       client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
//       [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
//       [client setDefaultHeader:@"Accept" value:@"application/json"];
//       [client setParameterEncoding:AFJSONParameterEncoding];

      if((client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
         
         //Check if host can be reached first, before making request
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         
         
      }
      else {
         [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *result = [responseObject description];
            if (![result isKindOfClass:[NSNull class]]) {
               [[[[iToast makeText:@" Successfully posted to build queue "]
                  setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
            }else{
               [[[[[[iToast makeText:@" Could not post to build queue "]
                    setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                   setTextColor:[UIColor whiteColor]]
                  setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
            }
            
            
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([operation.response statusCode] == 401) {
                [[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
                     setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                    setTextColor:[UIColor whiteColor]]
                   setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
            }
            else {
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
            }
            // NSLog(@"Network Request Error:%@", error);
         }];
      }
   }
   else if([title isEqualToString:@"No"])
   {
      [alertView dismissWithClickedButtonIndex:1 animated:NO];
   }
    else if([title isEqualToString:@"Logout"]) {
        [client clearAuthorizationHeader];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:server]]) {
            [cookieStorage deleteCookie:each];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if([title isEqualToString:@"Dismiss"]) {
        return;
    }
   
}


- (BOOL) checkIfLogExists: (NSString*) logFilePath {
   
   BOOL fileExists = NO;
   fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logFilePath];
   
   return fileExists;
}


//Document interaction controller part
- (UIDocumentInteractionController*) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id<UIDocumentInteractionControllerDelegate>) interactionDelegate {
   
   UIDocumentInteractionController *interactionController =
   [UIDocumentInteractionController interactionControllerWithURL:fileURL];
   
   interactionController.delegate = interactionDelegate;
   
   return interactionController;
}
-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
   
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
   
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
   
}
-(void)expand:(UISegmentedControl *)segControl
{
   CGFloat viewHeight = self.view.frame.size.height;
   CGFloat contentHeight = self.logView.contentSize.height;
   //   // NSLog(@"Expand: Frame %f ContentSize %f", viewHeight, contentHeight);
   if ((viewHeight + 50) > contentHeight) {
      return;
   }
   
   if(hidden)
      return;
   
   hidden = YES;
   [UIView beginAnimations:nil context:NULL];
   [UIView setAnimationDuration:0.3];
   //set segControl to hidden
   [segControl setHidden:hidden];
   //set self.logView bounds to bounds + segControl bounds
   CGFloat extra = (self.navigationController.toolbar.bounds.size.height + 8);
   //   // NSLog(@"Seg Control %f", extra);
   CGFloat segment = segControl.bounds.size.height;
   CGFloat total = extra + segment;
   CGRect r = CGRectMake(logView.bounds.origin.x, logView.bounds.origin.y, logView.bounds.size.width, (logView.bounds.size.height + total));
   //   // NSLog(@"Seg Control %f", segControl.bounds.size.height);
   [self.logView setBounds:r];
   [UIView commitAnimations];
}

-(void)contract:(UISegmentedControl *)segControl
{
   CGFloat viewHeight = self.view.frame.size.height;
   CGFloat contentHeight = self.logView.contentSize.height;
   //   // NSLog(@"Contract: Frame %f ContentSize %f", viewHeight, contentHeight);
   if ((viewHeight + 50) > contentHeight) {
      return;
   }
   
   if(!hidden)
      return;
   
   hidden = NO;
   [UIView beginAnimations:nil context:NULL];
   [UIView setAnimationDuration:0.3];
   //set segControl to hidden
   [segControl setHidden:hidden];
   //set self.logView bounds to bounds + segControl bounds
   CGFloat extra = (self.navigationController.toolbar.bounds.size.height + 8);
   //   // NSLog(@"Nav %f", extra);
   CGFloat segment = segControl.bounds.size.height;
   CGFloat total = extra + segment;
   CGRect r = CGRectMake(logView.bounds.origin.x, logView.bounds.origin.y, logView.bounds.size.width, (logView.bounds.size.height - total));
   //   // NSLog(@"Seg Control %f", segControl.bounds.size.height);
   [self.logView setBounds:r];
   [UIView commitAnimations];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   startContentOffset = lastContentOffset = scrollView.contentOffset.y;
   //// NSLog(@"scrollViewWillBeginDragging: %f", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   CGFloat currentOffset = scrollView.contentOffset.y;
   CGFloat differenceFromStart = startContentOffset - currentOffset;
   CGFloat differenceFromLast = lastContentOffset - currentOffset;
   lastContentOffset = currentOffset;
   
   
   
   if((differenceFromStart) < 0)
   {
      // scroll up
      if(scrollView.isTracking && (abs(differenceFromLast)>1))
         [self expand:self.logSegment];
   }
   else {
      if(scrollView.isTracking && (abs(differenceFromLast)>1))
         [self contract:self.logSegment];
   }
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
   [self contract:self.logSegment];
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
            
            [self retryGetLogs];
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
