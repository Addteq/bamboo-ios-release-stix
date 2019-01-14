//
//  BSViewController.m
//  Bamboo
//
//  Created by Matthew Burnett on 12/11/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//
#define kSuccess @"success"
#define kFailure @"failure"
#define kUnknown @"unknown"

#import "BSViewController.h"
#import "BuildItem.h"

@implementation BSViewController
@synthesize planKey;
@synthesize chartView;
@synthesize barChart;
@synthesize numBuilds;
@synthesize percentBuilds;
@synthesize numBuildStr;
@synthesize percentBuildStr;
@synthesize buildsArray;
@synthesize stateArray;
@synthesize sucPlot;
@synthesize failPlot;
@synthesize unkPlot;
@synthesize annotation;
@synthesize size;
@synthesize successData;
@synthesize failData;
@synthesize unknownData;
@synthesize lastBuildArtifacts;
@synthesize lastBuildDuration;
@synthesize lastBuildReason;
@synthesize summaryTitle;
@synthesize lastBuildState;
@synthesize maxDuration;
@synthesize success;
@synthesize failure;
@synthesize unknown;
@synthesize pageNumber;
@synthesize height;

// load the view nib and initialize the pageNumber ivar
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
    
    self.height = self.view.frame.size.height;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   stateArray = [[NSArray alloc]initWithObjects:@"Unknown", @"Successful", @"Failure", nil];
   size = [NSNumber numberWithInt:(int)[buildsArray count]];
   successData = [[NSMutableArray alloc] initWithCapacity:[size integerValue]];
   failData = [[NSMutableArray alloc] initWithCapacity:[size integerValue]];
   unknownData = [[NSMutableArray alloc] initWithCapacity:[size integerValue]];
   int i;
   success = 0;
   failure = 0;
   unknown = 0;
   maxDuration = 0;
   int totalDur = 0;
   for (i=0; i<[buildsArray count]; i++) {
      BuildItem *item = buildsArray[i];
      float duration = [item.durationSeconds floatValue];
      totalDur += duration;
      NSNumber *dur = [NSNumber numberWithFloat:duration];
      NSNumber *unknowndur = [NSNumber numberWithInteger:1];
      if (duration > maxDuration) {
         maxDuration = duration;
      }
      NSString *state = item.state;
      if ([state rangeOfString:@"Successful"].location != NSNotFound) {
         [successData addObject:dur];
         [unknownData addObject:[NSNumber numberWithInt:0]];
         [failData addObject:[NSNumber numberWithInt:0]];
         success++;
      }else if ([state rangeOfString:@"Failed"].location != NSNotFound){
         [successData addObject:[NSNumber numberWithInt:0]];
         [unknownData addObject:[NSNumber numberWithInt:0]];
         [failData addObject:dur];
         failure++;
      }else{
         [successData addObject:[NSNumber numberWithInt:0]];
          int unknownvalue = [dur intValue];
          if(unknownvalue==0){
              [unknownData addObject:unknowndur];
          }else{
              [unknownData addObject:dur];
          }
         
         [failData addObject:[NSNumber numberWithInt:0]];
         unknown++;
      }
   }
   //Number of Builds = buildsArray count
   numBuildStr = [NSString stringWithFormat:@"%lu", (unsigned long)[buildsArray count]];
   //Percent Successful = success / buildsArray count
   float percent = (((float)success / [size floatValue]) * 100.0);
   percentBuildStr = [NSString stringWithFormat:@"%.02f", percent];
   //Avg Duration Time = durationData summed / buildsArray count
       int avgDur = (totalDur / [buildsArray count]);
    // NSLog(@"Duration : %d",totalDur);
       self.numBuilds.text = [self.numBuilds.text stringByReplacingOccurrencesOfString:@"<num>"withString:numBuildStr];
       self.percentBuilds.text = [self.percentBuilds.text stringByReplacingOccurrencesOfString:@"<percent>"withString:percentBuildStr];
    
        if(avgDur ==0){
            self.avgDurBuilds.text = [self.avgDurBuilds.text stringByReplacingOccurrencesOfString:@"<string>"withString:@"0"];

        }else{
    
            self.avgDurBuilds.text = [self.avgDurBuilds.text stringByReplacingOccurrencesOfString:@"<string>"withString:[self avgDuration:avgDur]];
        }//// NSLog(@"Plan Key %@", planKey);
       NSRange key = [planKey rangeOfString:@"-"];
       if (key.location != NSNotFound) {
          self.summaryTitle.text = [self.summaryTitle.text stringByReplacingOccurrencesOfString:@"<plan>"withString:[planKey substringFromIndex:(key.location + key.length)]];
       }
       [self setBuildInfo:buildsArray[0]];
    if (pageNumber == 0) {
          //Info?
          self.chartView.hidden = YES;
          self.numBuilds.hidden = NO;
          self.percentBuilds.hidden = NO;
          self.avgDurBuilds.hidden = NO;
          self.lastBuildReason.hidden = NO;
          self.lastBuildDuration.hidden = NO;
          self.lastBuildArtifacts.hidden = NO;
       }else if(pageNumber == 1){
          [self.chartView setBackgroundColor:[UIColor blackColor]];
          //Bar Chart       
          CGRect parentRect = chartView.bounds;
           //Change here
           //Check the run environment before load the graph
           //for BIP 292
           if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
           {
               parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width*2.4, parentRect.size.height*2.45);
           }
           else
           {
               //parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width, parentRect.size.height);
               parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width, height);
           }
           //UIImageView *imgview = [[UIImageView alloc]init];
           //imgview.image = [[UIImage alloc]initWithContentsOfFile:@"label.png"];
           //[self.chartView addSubview:imgview];
          self.chartView =[(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
          self.chartView.allowPinchScaling = NO;
          [self.view addSubview:self.chartView];
          
          barChart = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
          CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
          [barChart applyTheme:theme];
          chartView.hostedGraph = barChart;
          
          // Border
          barChart.plotAreaFrame.borderLineStyle = nil;
          barChart.plotAreaFrame.cornerRadius	   = 0.0f;
          
          // Paddings
          barChart.paddingLeft   = 0.0f;
          barChart.paddingRight  = 0.0f;
          barChart.paddingTop	   = 0.0f;
          barChart.paddingBottom = 0.0f;
           [barChart setBackgroundColor:[[UIColor blackColor] CGColor]];
          if (maxDuration >= 100) {
             barChart.plotAreaFrame.paddingLeft = 60.0;
          }else{
             barChart.plotAreaFrame.paddingLeft	 = 50.0;
          }
          barChart.plotAreaFrame.paddingTop	 = 20.0;
          barChart.plotAreaFrame.paddingRight	 = 20.0;
          barChart.plotAreaFrame.paddingBottom = 50;
          
          // Add plot space for horizontal bar charts
          CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
          //get max duration for y length
          plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(maxDuration + 5)];
          //get count for x length
          plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromUnsignedInteger([buildsArray count] + 1)];
          
          CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
          CPTXYAxis *x		  = axisSet.xAxis;
          CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
          lineStyle.lineColor = [CPTColor whiteColor];
          lineStyle.lineWidth = 3.0f;
          lineStyle.lineCap = CPTLineCapTypeBar;
          x.axisLineStyle = lineStyle;
          x.majorTickLineStyle		  = lineStyle;
          x.minorTickLineStyle		  = nil;
          x.majorIntervalLength		  = CPTDecimalFromString(@"5");
          x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
          
          // Define some custom labels for the data elements
          x.labelRotation	 = 0.0f;
          x.labelingPolicy = CPTAxisLabelingPolicyNone;
           x.title=@"X-axis: Builds   Y-axis: Time(s)";
           x.titleOffset=20;
          // x.titleLocation=CPTDecimalFromInteger(0.7);
          CPTXYAxis *y = axisSet.yAxis;
          y.axisLineStyle           = lineStyle;
          y.majorTickLineStyle		  = lineStyle;
          y.minorTickLineStyle		  = nil;

          //y.title=@"Y:Build Time(s)";
           //y.titleLocation=CPTDecimalFromInteger(25.75);
          if (maxDuration > 0 && maxDuration <= 50) {
             y.majorIntervalLength		  = CPTDecimalFromString(@"5");
          }
          else if (maxDuration > 50 && maxDuration <= 100) {
             y.majorIntervalLength		  = CPTDecimalFromString(@"10");
          }
          else if (maxDuration > 100 && maxDuration <= 250) {
             y.majorIntervalLength		  = CPTDecimalFromString(@"25");
          }
          else if (maxDuration > 250 && maxDuration <= 500) {
             y.majorIntervalLength		  = CPTDecimalFromString(@"50");
          }
          else if (maxDuration > 500) {
              if(maxDuration > 5000){
                  y.majorIntervalLength		  = CPTDecimalFromString(@"5000");
              }else if(maxDuration > 1000){
                  y.majorIntervalLength		  = CPTDecimalFromString(@"1000");
              }else{
                  y.majorIntervalLength		  = CPTDecimalFromString(@"100");
              }
          }
          y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
          
          // Success bar plot
          CPTBarPlot *successPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
          successPlot.identifier = kSuccess;
          // Unknown bar plot
          CPTBarPlot *unknownPlot	= [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
          unknownPlot.identifier = kUnknown;
          // Failure bar plot
          CPTBarPlot *failurePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
          failurePlot.identifier = kFailure;
          CGFloat barX = 0.33f;
          NSArray *plots = [NSArray arrayWithObjects:successPlot, unknownPlot, failurePlot, nil];
          for ( CPTBarPlot *plot in plots ){
             plot.dataSource = self;
             plot.delegate = self;
             plot.barWidth = CPTDecimalFromFloat(0.33f);
             plot.barOffset	= CPTDecimalFromFloat(barX);
             plot.barCornerRadius = 2.0f;
             [barChart addPlot:plot toPlotSpace:plotSpace];
             barX += 0.33f;
          }

       }else if(pageNumber == 2){
          //Pie Chart
          [self.view setBackgroundColor:[UIColor blackColor]];
          [self initPlot];
       }else{
       }
}

- (NSString *)avgDuration:(int)duration{
    //Avg Duration Unit = Avg Duration Time with hour/minute/second logic from BuildInfo
    int weeks, days, hours, minutes, seconds;
    seconds = duration;
    weeks = seconds / 604800;
    seconds = seconds % 604800;
    days = seconds / 86400;
    seconds = seconds % 86400;
    hours = seconds / 3600;
    seconds = seconds % 3600;
    minutes = seconds / 60;
    seconds = seconds % 60;
    NSString *avgDurTimeStr = nil;
    if (seconds != 0) {
        if (seconds == 1) {
            avgDurTimeStr = [NSString stringWithFormat:@"%d second", seconds];
        }else{
            avgDurTimeStr = [NSString stringWithFormat:@"%d seconds", seconds];
        }
    }
    if (minutes != 0) {
        if ((minutes == 1) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d minute", minutes];
        }else if ( minutes == 1) {
            avgDurTimeStr = [NSString stringWithFormat:@"%d minute, %@", minutes, avgDurTimeStr];
        }else if(seconds == 0){
            avgDurTimeStr = [NSString stringWithFormat:@"%d minutes", minutes];
        }else{
            avgDurTimeStr = [NSString stringWithFormat:@"%d minutes, %@", minutes, avgDurTimeStr];
        }
    }
    if (hours != 0) {
        if ((hours == 1) && (minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d hour", hours];
        }else if (hours == 1) {
            avgDurTimeStr = [NSString stringWithFormat:@"%d hour, %@", hours, avgDurTimeStr];
        }else if((minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d hours", hours];
        }else{
            avgDurTimeStr = [NSString stringWithFormat:@"%d hours, %@", hours, avgDurTimeStr];
        }
    }
    if (days != 0) {
        if ((days == 1) && (hours == 0) && (minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d day", days];
        }else if ( days == 1) {
            avgDurTimeStr = [NSString stringWithFormat:@"%d day, %@", days, avgDurTimeStr];
        }else if((hours == 0) && (minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d days", days];
        }else{
            avgDurTimeStr = [NSString stringWithFormat:@"%d days, %@", days, avgDurTimeStr];
        }
    }
    if (weeks != 0) {
        if ((weeks == 1) && (days == 0) && (hours == 0) && (minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d week", weeks];
        }else if ( weeks == 1) {
            avgDurTimeStr = [NSString stringWithFormat:@"%d week, %@", weeks, avgDurTimeStr];
        }else if((days == 0) && (hours == 0) && (minutes == 0) && (seconds == 0)){
            avgDurTimeStr = [NSString stringWithFormat:@"%d weeks", weeks];
        }else{
            avgDurTimeStr = [NSString stringWithFormat:@"%d weeks, %@", weeks, avgDurTimeStr];
        }
    }
    return avgDurTimeStr;
}

- (void)setBuildInfo:(BuildItem *)item{
    //Set Build State
    self.lastBuildState.text = item.state;
    //Set Build Reason
    self.lastBuildReason.text = item.reason;
    //Set Build Duration
    int number = [item.durationSeconds intValue];
    self.lastBuildDuration.text = [self avgDuration:number];
    //Set Artifacts
    if ([item.artifacts count] >= 1) {
        int i;
        lastBuildArtifacts.text = @"";
        for(i = 0; i < [item.artifacts count]; i++){
            NSString *newText = [NSString stringWithFormat:@"%d. %@\n", i+1, item.artifacts[i]];
            [lastBuildArtifacts setText:[NSString stringWithFormat:@"%@%@", lastBuildArtifacts.text, newText]];
        }
        
    }else{
        lastBuildArtifacts.text = @"No Artifacts";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    switch (pageNumber) {
        case 1:
            return [buildsArray count];
        case 2:
            return [stateArray count];
    }
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (pageNumber) {
        case 1:
        {
            NSNumber *num = nil;
            
            if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
                switch ( fieldEnum ) {
                    case CPTBarPlotFieldBarLocation:
                        num = (NSNumber *)[NSNumber numberWithUnsignedInteger:index];
                        break;
                        
                    case CPTBarPlotFieldBarTip:
                    {
                        if ( [plot.identifier isEqual:kSuccess] ) {
                            num = successData[index];
                        }
                        if ( [plot.identifier isEqual:kUnknown] ) {
                            num = unknownData[index];
                           
                        }
                        if ( [plot.identifier isEqual:kFailure] ) {
                            num = failData[index];
                        }
                        break;
                    }
                }
            }
            
            return num;
        }
        case 2:
        {
            if(CPTPieChartFieldSliceWidth == fieldEnum){
                NSString *state = [stateArray objectAtIndex:index];
                if ([state isEqualToString:@"Failure"]) {
                    return [NSNumber numberWithInt:failure];
                }
                else if ([state isEqualToString:@"Successful"]) {
                    return [NSNumber numberWithInt:success];
                }
                else if ([state isEqualToString:@"Unknown"]) {
                    return [NSNumber numberWithInt:unknown];
                }
            }
        }
    }
    return [NSDecimalNumber zero];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
}

- (CPTFill *) sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index{
    CPTFill *color = nil;
    //Success = 1
    if (index == 1) {
        color = [CPTFill fillWithColor:[CPTColor greenColor]];
    }
    //Unknown = 0
    else if (index == 0) {
        color = [CPTFill fillWithColor:[CPTColor blueColor]];
    }
    //Failure = 2
    else if (index == 2){
        color = [CPTFill fillWithColor:[CPTColor redColor]];
    }
    return color;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    switch (pageNumber) {
        case 1:
        {
            return [[CPTTextLayer alloc] initWithText:@""];
        }
        case 2:
        {
            // 1 - Define label text style
            static CPTMutableTextStyle *labelText = nil;
            if (!labelText) {
                labelText= [[CPTMutableTextStyle alloc] init];
                labelText.color = [CPTColor whiteColor];
                labelText.fontName=@"Helvetica-Bold";
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    labelText.fontSize=24.0f;
                }else{
                    labelText.fontSize=18.0f;
                }
                
            }
            // 2 - Calculate total value
            float total = success + failure + unknown;
            // 3 - Calculate percentage value
            // 4 - Set up display label
            // 5 - Create and return layer with label text
            float percent;
            NSString *labelValue;
            NSString *state = [stateArray objectAtIndex:index];
            if ([state isEqualToString:@"Successful"]) {
                percent = (((float)success/total) * 100.0);
                if (percent == 0.0) {
                    labelValue = @"";
                }else{
                    labelValue = [NSString stringWithFormat:@"%2.1f", percent];
                }
            }
            else if ([state isEqualToString:@"Failure"]) {
                percent = (((float)failure/total) * 100.0);
                if (percent == 0.0) {
                    labelValue = @"";
                }else{
                    labelValue = [NSString stringWithFormat:@"%2.1f", percent];
                }         }
            else if ([state isEqualToString:@"Unknown"]) {
                percent = (((float)unknown/total) * 100.0);
                if (percent == 0.0) {
                    labelValue = @"";
                }else{
                    labelValue = [NSString stringWithFormat:@"%2.1f", percent];
                }
            }
            return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
        }
        default:
            return [[CPTTextLayer alloc] initWithText:@""];
    }
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    if (index < [stateArray count]) {
        //Success = 1
        if (index == 1) {
            return @"Success";
        }
        //Unknown = 0
        else if (index == 0) {
            return @"Unknown";
        }
        //Failure = 2
        else if (index == 2){
            return @"Failure";
        }
    }
    return @"N/A";
}

#pragma mark - Pie Chart Behavior
- (void) initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
}

- (void) configureHost {
   CGRect parentRect = chartView.bounds;
    //Change here
    //Check the run environment before load the graph
    //for BIP 292
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width*2.4, parentRect.size.height*2.45);
    }
    else
    {
        parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width, height);
    }
   self.chartView =[(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
   self.chartView.allowPinchScaling = NO;
   
   [self.view addSubview:self.chartView];
}

- (void) configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
    self.chartView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    // 4 - Set theme
    CPTTheme *selectedTheme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:selectedTheme];
}

- (void) configureChart {
    // 1 - Get reference to graph
    CPTGraph *graph = self.chartView.hostedGraph;
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.chartView.bounds.size.height * 0.6) / 2 ;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    pieChart.labelOffset=-80;
    // 3 - Create gradient
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
    // 4 - Add chart to graph
    [graph addPlot:pieChart];
}

- (void)configureLegend {
    // 1 - Get graph instance
    CPTGraph *graph = self.chartView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorBottomLeft;
    graph.legendDisplacement = CGPointMake(10.0, 10.0);
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}
@end
