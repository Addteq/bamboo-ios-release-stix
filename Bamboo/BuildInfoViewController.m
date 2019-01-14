//
//  BuildInfoViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 11/5/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "BuildItem.h"
#import "BuildInfoViewController.h"
#import "CTViewController.h"
#import "StagesViewController.h"
#import "CommentViewController.h"
#import "BIViewController.h"
#import "NaviController.h"
#import "CustomIOS7AlertView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface BuildInfoViewController ()

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation BuildInfoViewController
@synthesize server;
@synthesize path;
@synthesize planKey;
@synthesize viewControllers;
@synthesize scrollView;
@synthesize buildArray;
@synthesize keyArray;
@synthesize index;
@synthesize buildKeyString;
@synthesize client;
@synthesize menuButton;
@synthesize actionSheetDismiss;
//@synthesize bug;

- (void) loadView {
    [super loadView];
    CGRect newframe = self.view.frame;
    newframe.size.height = [UIScreen mainScreen].bounds.size.height+44;
    self.view.frame = newframe;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.navigationController.toolbarHidden = YES;
   [self.tabBarController setToolbarItems:nil];
   
   buildKeyString = [[buildArray objectAtIndex:index] getKey];

   // view controllers are created lazily
   // in the meantime, load the array with placeholders which will be replaced on demand
   NSMutableArray *controllers = [[NSMutableArray alloc] init];
   for (unsigned i = 0; i < [buildArray count]; i++)
   {
		[controllers addObject:[NSNull null]];
   }
   self.viewControllers = controllers;
    // a page is the width of the scroll view
   scrollView.pagingEnabled = YES;
   scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [buildArray count], 0);
   scrollView.contentOffset = CGPointMake((scrollView.frame.size.width * (int)index), 0);
   scrollView.showsHorizontalScrollIndicator = NO;
   scrollView.showsVerticalScrollIndicator = NO;
   scrollView.scrollsToTop = NO;
   scrollView.delegate = self;
   scrollView.clipsToBounds=YES;
    
   // pages are created on demand
   // load the visible page
   // load the page on either side to avoid flashes when the user starts scrolling
   //
   if ((int)index >= 1) {
      [self loadScrollViewWithPage:(index-1)];
   }
   [self loadScrollViewWithPage:index];
   [self loadScrollViewWithPage:(index+1)];
    
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setDefaultHeader:@"X-Atlassian-Token" value:@"nocheck"];
    [client setParameterEncoding:AFJSONParameterEncoding];
}
- (void)loadScrollViewWithPage:(int)page
{
   if (page < 0)
      return;
   if (page >= [buildArray count])
      return;
   
   // replace the placeholder if necessary
   BIViewController *controller = [viewControllers objectAtIndex:page];
   if ((NSNull *)controller == [NSNull null])
   {
      controller = [[BIViewController alloc] initWithNibName:@"BIViewController" bundle:nil];
      controller.numIndex = page;
      controller.buildArray = buildArray;
      controller.planKey = planKey;
      [viewControllers replaceObjectAtIndex:page withObject:controller];
   }
   
   // add the controller's view to the scroll view
   if (controller.view.superview == nil)
   {
      CGRect frame = scrollView.frame;
      frame.origin.x = frame.size.width * page;
      frame.origin.y = 0;
       frame.size.height = [UIScreen mainScreen].bounds.size.height + 44;
      controller.view.frame = frame;
      [scrollView addSubview:controller.view];

      
   }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
   // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
   // which a scroll event generated from the user hitting the page control triggers updates from
   // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
   if (pageControlUsed)
   {
      // do nothing - the scroll was initiated from the page control, not the user dragging
      return;
   }
	
   // Switch the indicator when more than 50% of the previous/next page is visible
   CGFloat pageWidth = scrollView.frame.size.width;
   int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
   index = page;
    buildKeyString = [[buildArray objectAtIndex:index] getKey];
   // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
   [self loadScrollViewWithPage:page - 1];
   [self loadScrollViewWithPage:page];
   [self loadScrollViewWithPage:page + 1];
   
    
    
   // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   pageControlUsed = NO;
}


- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.actionSheetDismiss.visible){
            [self.actionSheetDismiss dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    /*if([[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.bug removeFromSuperview];
    }*/
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated{
    /*if(![[self.navigationController.toolbar subviews] containsObject:self.bug]){
        [self.navigationController.toolbar addSubview:self.bug];
    }*/
    [super viewWillAppear:animated];
   // BIViewController *findBug;
   // _bugImage = findBug.myBugImage;
    //[self addBugIcon];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"Email has been sent.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Buttons

- (IBAction)showActionSheet:(id)sender {
   UIActionSheet *actionSheet;
    [menuButton setEnabled:NO];
   //Action Sheet Title
   NSString *actionSheetTitle = @"Build Info";
   //Action Sheet Button Titles
   NSString *build = @"Start Build";
   NSString *email  = @"Share via Email";
   NSString *logout = @"Logout";
   NSString *stages = @"Stages";
   NSString *comments = @"Comments";
   NSString *changes = @"Changes";
   NSString *cancelTitle = @"Cancel";
    NSString *helpTitle = @"Help";
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSString *guest = [userDefaults stringForKey:@"guest"];
   if ([guest isEqualToString:@"guest"]) {
      //Hide play button
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:logout
                                       otherButtonTitles:stages,helpTitle, nil];
   }else{
      actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                delegate:self
                                       cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:logout
                                       otherButtonTitles:build, changes, stages, comments,helpTitle,email, nil];
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
    self.actionSheetDismiss = actionSheet;
}

- (IBAction)showFeedback:(id)sender {
   [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
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
        //Get the name of the curnt pressed button
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Changes"]) {
            CTViewController *ctvc = [[CTViewController alloc] init];
            //// NSLog(@"BuildKey %@", buildKeyString);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                ctvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"changes"];
            }
            else {
                UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                ctvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"changes"];
            }
            ctvc.buildKey = buildKeyString;
            ctvc.server = server;
            ctvc.path = path;
            [self.navigationController pushViewController:ctvc animated:YES];
        }
        else if ([buttonTitle isEqualToString:@"Comments"]) {
            CommentViewController *cvc = [[CommentViewController alloc] init];
            //// NSLog(@"BuildKey %@", buildKeyString);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                cvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"comments"];
            }
            else {
                UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                cvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"comments"];
            }
            cvc.key = buildKeyString;
            cvc.server = server;
            cvc.path = path;
            [cvc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:cvc animated:YES];
        }
        else if ([buttonTitle isEqualToString:@"Stages"]) {
            StagesViewController *stagesvc = [[StagesViewController alloc] init];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                UIStoryboard *ipadstoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                stagesvc = [ipadstoryboard instantiateViewControllerWithIdentifier:@"stages"];
            }
            else {
                UIStoryboard *iphonestoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                stagesvc = [iphonestoryboard instantiateViewControllerWithIdentifier:@"stages"];
            }
            stagesvc.planKey = planKey;
            stagesvc.buildKey = buildKeyString;
            NSString *buildStateString = [[buildArray objectAtIndex:index] getState];
            stagesvc.buildStateString = buildStateString;
            NSString *buildNumString = [NSString stringWithFormat:@"#%@", [[buildArray objectAtIndex:index] getNumber]];
            
            stagesvc.buildNumString = buildNumString;
            stagesvc.server = server;
            stagesvc.path = path;
            [self.navigationController pushViewController:stagesvc animated:YES];
        }
        else if ([buttonTitle isEqualToString:@"Logout"]) {
            [client clearAuthorizationHeader];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStorage cookies];
            for (NSHTTPCookie *each in cookies) {
                [cookieStorage deleteCookie:each];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([buttonTitle isEqualToString:@"Start Build"]) {
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
        }
        //
        else if ([buttonTitle isEqualToString:@"Share via Email"]){
            if ([MFMailComposeViewController canSendMail]){
                MFMailComposeViewController *mailComposer =[[MFMailComposeViewController alloc] init];
                mailComposer.mailComposeDelegate = self;
                [mailComposer setToRecipients:nil];
                NSString *buildNumString = [NSString stringWithFormat:@"%@", [[buildArray objectAtIndex:index] getNumber]];
                NSString *planURL = [[NSString alloc] initWithFormat:@"%@/browse/%@-%@/artifact", server, planKey, buildNumString];
                // NSLog(@"the link is %@", planURL);
                [mailComposer setMessageBody:planURL isHTML:YES];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self presentViewController:mailComposer animated:YES completion:NULL];
                });
            }else{
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle:@"Info"
                               message:@"Email has not been setup for this device. Please go to your phone settings to add an email account"
                               delegate: self
                               cancelButtonTitle: @"Dismiss"
                               otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
            }
            
        }
        //
        else if ([buttonTitle isEqualToString:@"Help"]) {
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"Help"
                           message:@"This screen displays information for the selected build. To see other builds, scroll left or right. From here, you can start a new build, view the changes on this build, view the stages of the plan, and comment on this build."
                           delegate: self
                           cancelButtonTitle: @"Close"
                           otherButtonTitles: nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog show];
        }    }
   
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   //Get the name of the current pressed button
   NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Dismiss"]) {
        return;
    }else if ([buttonTitle isEqualToString:@"Retry"]){
        [self loggingIn:1];
    }else if ([buttonTitle isEqualToString:@"Yes"]){
      //Start Build here.
      //Post to queue URL - rest/api/latest/queue
       //Initialize httpClient
       
       if((client.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown)) {
          // NSLog(@"Reachability: %d", client.networkReachabilityStatus);
           //Check if host can be reached first, before making request
           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Cannot connect to Server" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
       }
       else {
           
           NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
           
           if([path isKindOfClass:[NSNull class]] || path == NULL) {
               planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
               // NSLog(@"planURL is%@",planURL);
           }else{
               planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
           }
           // NSLog(@"Plan URL in BuildInfo:%@", planURL);
          [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSString *result = [responseObject description];
               if (result != (id)[NSNull null]) {
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
                   if([error.description rangeOfString:@"Access is denied"].location != NSNotFound){
                       /*[[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
                            setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                           setTextColor:[UIColor whiteColor]]
                          setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];*/
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                           CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
                           [alert setContainerView: [self createAlertView]];
                           [alert setButtonTitles:[NSArray arrayWithObject:@"Dismiss"]];
                           [alert show];
                        }else{
                           UIAlertView *alertDialog;
                           UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
                           [imageView setImage:[UIImage imageNamed:@"ReddyWhite@2x.png"]];
                           
                           alertDialog = [[UIAlertView alloc]
                                          initWithTitle:@"    Unauthorized Access"
                                          message:@"You do not have permission to build!"
                                          delegate: self
                                          cancelButtonTitle: @"Dismiss"
                                          otherButtonTitles: nil];
                           
                           alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                           [alertDialog addSubview:imageView];
                           // NSLog(@"%f %f", alertDialog.frame.size.width, alertDialog.frame.size.height);
                           [alertDialog show];

                       }
                       
                    }else{
                       // need to loggin in
                       [self loggingIn:1];
                   }
                   
               }else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
                   
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
               
           }];
       }
   }
   else{
       if ([buttonTitle isEqualToString:@"Logout"]){
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


- (UIView *) createAlertView{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 80)];
    demoView.layer.cornerRadius = 8.0f;
    demoView.layer.masksToBounds = YES;
    demoView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
    [imageView setImage:[UIImage imageNamed:@"ReddyWhite@2x.png"]];
    [demoView addSubview:imageView];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 250, 30)];
    title.text = @"Unauthorized Access";
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    title.numberOfLines = 0;
    [demoView addSubview:title];
    UILabel *lblShare= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 260, 30)];
    lblShare.text=@"You do not have permission to build";
    lblShare.numberOfLines=2;
    lblShare.textColor =[UIColor blackColor];
    lblShare.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    //lblShare.font = [UIFont systemFontOfSize:14];
    lblShare.backgroundColor =[UIColor clearColor];
    [demoView addSubview:lblShare];
    return  demoView;
}

- (void) retryBuilding{
    
    NSString *planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    
    if([path isKindOfClass:[NSNull class]] || path == NULL) {
        planURL = [[NSString alloc] initWithFormat:@"/rest/api/latest/queue/%@", planKey];
    }else{
        planURL = [[NSString alloc] initWithFormat:@"%@/rest/api/latest/queue/%@", path, planKey];
    }
    // NSLog(@"Plan URL in BuildInfo:%@", planURL);
    [client postPath:planURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [responseObject description];
        if (result != (id)[NSNull null]) {
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
            /*[[[[[[iToast makeText:@" Unauthorized Access\n You do not have permission to build  "]
                 setBackgroundColor: [UIColor colorWithRed:210/255.0f green:1/255.0f blue:8/255.0f alpha:1.0f]]
                setTextColor:[UIColor whiteColor]]
               setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];*/
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                CustomIOS7AlertView *alert = [[CustomIOS7AlertView alloc] init];
                [alert setContainerView: [self createAlertView]];
                [alert setButtonTitles:[NSArray arrayWithObject:@"Dismiss"]];
                [alert show];
            }else{
            UIAlertView *alertDialog;
            UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            [imageView setImage:[UIImage imageNamed:@"ReddyWhite@2x.png"]];
            
            
            alertDialog = [[UIAlertView alloc]
                           initWithTitle:@"    Unauthorized Access"
                           message:@"You do not have permission to build!"
                           delegate: self
                           cancelButtonTitle: @"Dismiss"
                           otherButtonTitles: @"Logout", nil];
            alertDialog.alertViewStyle=UIAlertViewStyleDefault;
            [alertDialog addSubview:imageView];
            [alertDialog show];
            }
        }
        else if((client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (client.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)) {
            
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

}

- (BOOL)shouldAutomaticallyForwardRotationMethods{
   return NO;
}

- (BOOL)shouldAutorotate{
   return NO;
}

/*- (void) addBugIcon{
    UIToolbar *toolbar = ((NaviController *)self.parentViewController).toolbar;
    [toolbar setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.clipsToBounds=YES;
    self.bug = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.bug.frame = CGRectMake(731,10,28,28);
    }else{
        self.bug.frame = CGRectMake(282,10,28,28);
    }
    
   // BuildInfoViewController *pushImage = [[BuildInfoViewController alloc]initWithNibName:@"BuildInfoViewController" bundle:nil];
   // pushImage.myBug;
    [self.bug setImage:_bugImage forState:UIControlStateNormal];
    [self.bug addTarget:self action:@selector(showFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:self.bug];
    // NSLog(@"Selected bug is %@", _myBug);
}*/


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
            [self retryBuilding];
        }else{
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
}
@end
