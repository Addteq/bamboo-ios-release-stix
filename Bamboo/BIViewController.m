//
//  BIViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 12/12/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "BIViewController.h"
#import "BuildItem.h"
#import "BuildInfoViewController.h"
@interface BIViewController ()
- (void)configureView;
@end

@implementation BIViewController
@synthesize buildNum;
@synthesize buildState;
//@synthesize buildStateBackground;
@synthesize buildStateBackground1;
@synthesize buildReason;
@synthesize buildRevision;
@synthesize buildPrettyTime;
@synthesize buildDuration;
@synthesize buildRelativeTime;
@synthesize buildArtifactTV;
@synthesize buildNumString;
@synthesize buildReasonString;
@synthesize buildRevisionString;
@synthesize buildPrettyTimeString;
@synthesize buildDurationString;
@synthesize buildRelativeTimeString;
@synthesize buildArtifactArray;
@synthesize buildStateString;
@synthesize buildArray;
@synthesize numIndex;
@synthesize buildNumberImage;
@synthesize buildIconImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // NSLog(@"This view ran");
        
       // _buggy = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
      //  _myBugI.image = [UIImage imageNamed:@"bugGreenL.png"];
       // [_buggy setImage:[UIImage imageNamed:@"blueBug.png"]];
        // Custom initialization
       // if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      //  {
//            CGRect ipadFrame = CGRectMake(100, 200, 50, 50);
//            UIImageView *image = [[UIImageView alloc] initWithFrame:ipadFrame];
//            image.backgroundColor = [UIColor blackColor];
       // }
    }
    return self;
}

-(void) loadView{
    [super loadView];
    CGRect newframe = self.view.frame;
    newframe.size.height = [UIScreen mainScreen].bounds.size.height+44;
    self.view.frame = newframe;
    
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
   [self configureView];
    
    
   // [self sendAction];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
    // NSLog(@"HOLLA");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
          {
                 //   CGRect ipadFrame = CGRectMake(100, 200, 50, 50);
                 //   UIImageView *image = [[UIImageView alloc] initWithFrame:ipadFrame];
                 //   image.backgroundColor = [UIColor blackColor];
        
              // NSLog(@"IN IPAD");
         }
    
}

   

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sendAction
{
//    BuildInfoViewController *pushImage = [[BuildInfoViewController alloc]initWithNibName:@"BuildInfoViewController" bundle:nil];
//    pushImage.myBug = _myBugImage;
//    [self.navigationController pushViewController:pushImage animated:YES];
//    // NSLog(@"IMAGE IS %@", _myBugImage);
  //  [self.bug addTarget:self action:@selector(bugButton:) forControlEvents:UIControlEventTouchUpInside];
   // BuildInfoViewController *bugAction;
   // bugActionaddBugIcon;
}

- (void)configureView
{
   buildNumString = [NSString stringWithFormat:@"#%@", [[buildArray objectAtIndex:numIndex] getNumber]];
   buildReasonString = [[buildArray objectAtIndex:numIndex] getReason];
   buildRevisionString = [[buildArray objectAtIndex:numIndex] getRevision];
   buildPrettyTimeString = [[buildArray objectAtIndex:numIndex] getPrettyTime];
   buildDurationString = [[buildArray objectAtIndex:numIndex] getDurationSeconds];
   buildRelativeTimeString = [[buildArray objectAtIndex:numIndex] getRelativeTime];
   buildArtifactArray = [[buildArray objectAtIndex:numIndex] getArtifacts];
   buildStateString = [[buildArray objectAtIndex:numIndex] getState];
   
  //  BuildInfoViewController *pushImage = [[BuildInfoViewController alloc]initWithNibName:@"BuildInfoViewController" bundle:nil];
  //  pushImage.myBug = _myBugImage;
  //  [self.navigationController pushViewController:pushImage animated:YES];

//   // NSLog(@"Build %@", buildNumString);
//   // NSLog(@"Build %@", buildReasonString);
//   // NSLog(@"Build %@", buildRevisionString);
//   // NSLog(@"Build %@", buildPrettyTimeString);
//   // NSLog(@"Build %@", buildDurationString);
//   // NSLog(@"Build %@", buildRelativeTimeString);
//   // NSLog(@"Build %@", buildStateString);
    
    //_buggy = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
      //_myBugI.image = [UIImage imageNamed:@"bugGreenL.png"];
    //[_buggy setImage:[UIImage imageNamed:@"withShadow"]];
    //_buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
//    CGRect frame = CGRectMake(280, 468, 30, 30);
//    _buggy = [[UIImageView alloc] initWithFrame:frame];
//    _buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
//    [self.view addSubview:_buggy];
    /*BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIPhone5 = isIPhone && ([[UIScreen mainScreen] bounds].size.height > 480.0);
    if (isIPhone5) {
        // NSLog(@"is iphone5");
        CGRect frame = CGRectMake(280, 468, 30, 30);
        _buggy = [[UIImageView alloc] initWithFrame:frame];
       // _buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
        [self.view addSubview:_buggy];
    } else {
        // NSLog(@"is iphone4");
        CGRect frame = CGRectMake(280, 380, 30, 30);
        _buggy = [[UIImageView alloc] initWithFrame:frame];
        //_buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
        [self.view addSubview:_buggy];
    }
   */
    //BOOL isIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    /*if (isIPad) {
        CGRect frame = CGRectMake(730, 925, 30, 30);
        _buggy = [[UIImageView alloc] initWithFrame:frame];
        //_buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
        [self.view addSubview:_buggy];
    }*/
   // Update the user interface for the detail item.
   if([buildStateString isEqualToString:@"Successful"]){
      UIImage *image = [UIImage imageNamed: @"GreenWhite@2x.png"];
//       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//       {
//           image = [UIImage imageNamed: @"success_stage_small.png"];
//            _buggy.image = [UIImage imageNamed:@"bugGreenL.png"];
//       }
 //     UIImage *background = [UIImage imageNamed: @"light_green.png"];
      UIImage *background1 = [UIImage imageNamed: @"GreenBackground@2x.png"];
      buildState.image = image;
 //     buildStateBackground.image = background;
      buildStateBackground1.image = background1;
       //_buggy.image = [UIImage imageNamed:@"bugGreenL.png"];
       BuildInfoViewController *pushImage = [[BuildInfoViewController alloc]initWithNibName:@"BuildInfoViewController" bundle:nil];
       //pushImage.myBug = _myBugImage;
       [self.navigationController pushViewController:pushImage animated:YES];
       // NSLog(@"IMAGE IS %@", _myBugImage);
   }else if([buildStateString isEqualToString:@"Failed"]){
      UIImage *image = [UIImage imageNamed: @"ReddyWhite@2x.png"];
//       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//       {
//           image = [UIImage imageNamed: @"ReddyWhite@2x.png"];
//       }
  //    UIImage *background = [UIImage imageNamed: @"light_red.png"];
      UIImage *background1 = [UIImage imageNamed: @"RedBackground@2x.png"];
      buildState.image = image;
 //     buildStateBackground.image = background;
      buildStateBackground1.image = background1;
       // _buggy.image = [UIImage imageNamed:@"bugRedL.png"];
   }else{
      UIImage *image = [UIImage imageNamed: @"YellowOrWhite@2x.png"];
//       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//       {
//           image = [UIImage imageNamed: @"YellowOrWhite@2x.png"];
//       }
 //     UIImage *background = [UIImage imageNamed: @"YellowOrWhiteBackground@2x.png"];
      UIImage *background1 = [UIImage imageNamed: @"YellowOrWhiteBackground@2x.png"];
      buildState.image = image;
  //    buildStateBackground.image = background;
      buildStateBackground1.image = background1;
       // _buggy.image = [UIImage imageNamed:@"bugYellowL.png"];
   }
   // [self sendImage];
    
   buildNum.text = buildNumString;
   buildReason.text = buildReasonString;
   buildRevision.text = buildRevisionString;
   buildPrettyTime.text = buildPrettyTimeString;
   int number = [buildDurationString intValue];
   int weeks, days, hours, minutes, seconds;
   seconds = number;
   weeks = seconds / 604800;
   seconds = seconds % 604800;
   days = seconds / 86400;
   seconds = seconds % 86400;
   hours = seconds / 3600;
   seconds = seconds % 3600;
   minutes = seconds / 60;
   seconds = seconds % 60;
//   // NSLog(@"time = %02d:%02d:%02d:%02d:%02d", weeks, days, hours, minutes, seconds);
   NSString *time = nil;
   if (seconds != 0) {
      if (seconds == 1) {
         time = [NSString stringWithFormat:@"%d second", seconds];
      }else{
         time = [NSString stringWithFormat:@"%d seconds", seconds];
      }
   }
   if (minutes != 0) {
      if ((minutes == 1) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d minute", minutes];
      }else if ( minutes == 1) {
         time = [NSString stringWithFormat:@"%d minute, %@", minutes, time];
      }else if(seconds == 0){
         time = [NSString stringWithFormat:@"%d minutes", minutes];
      }else{
         time = [NSString stringWithFormat:@"%d minutes, %@", minutes, time];
      }
   }
   if (hours != 0) {
      if ((hours == 1) && (minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d hour", hours];
      }else if (hours == 1) {
         time = [NSString stringWithFormat:@"%d hour, %@", hours, time];
      }else if((minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d hours", hours];
      }else{
         time = [NSString stringWithFormat:@"%d hours, %@", hours, time];
      }
   }
   if (days != 0) {
      if ((days == 1) && (hours == 0) && (minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d day", days];
      }else if ( days == 1) {
         time = [NSString stringWithFormat:@"%d day, %@", days, time];
      }else if((hours == 0) && (minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d days", days];
      }else{
         time = [NSString stringWithFormat:@"%d days, %@", days, time];
      }
   }
   if (weeks != 0) {
      if ((weeks == 1) && (days == 0) && (hours == 0) && (minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d week", weeks];
      }else if ( weeks == 1) {
         time = [NSString stringWithFormat:@"%d week, %@", weeks, time];
      }else if((days == 0) && (hours == 0) && (minutes == 0) && (seconds == 0)){
         time = [NSString stringWithFormat:@"%d weeks", weeks];
      }else{
         time = [NSString stringWithFormat:@"%d weeks, %@", weeks, time];
      }
   }
   buildDuration.text = time;
   buildRelativeTime.text = buildRelativeTimeString;
   if ([buildArtifactArray count] >= 1) {
      int i;
      buildArtifactTV.text = @"";
      for(i = 0; i < [buildArtifactArray count]; i++){
         NSString *newText = [NSString stringWithFormat:@"%d. %@\n", i+1, buildArtifactArray[i]];
         [buildArtifactTV setText:[NSString stringWithFormat:@"%@%@", buildArtifactTV.text, newText]];
      }
      
   }else{
      buildArtifactTV.text = @"No Artifacts";
   }
    
    // NSLog(@"self biviewcontorll %f",self.view.frame.size.height);
}

- (IBAction)bugButton
{
    //BuildInfoViewController *bugAction;
   // bugAction.addBugIcon;
   // [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
}

- (BOOL)shouldAutomaticallyForwardRotationMethods{
   return NO;
}

- (BOOL)shouldAutorotate{
   return NO;
}

@end
