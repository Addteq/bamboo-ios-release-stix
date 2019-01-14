//
//  BSViewController.h
//  Bamboo
//
//  Created by Matthew Burnett on 12/11/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "CorePlot-CocoaTouch.h"

@interface BSViewController : UIViewController <CPTPlotDataSource, CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (strong, nonatomic) IBOutlet UILabel *summaryTitle;
@property (strong, nonatomic) IBOutlet UILabel *numBuilds;
@property (strong, nonatomic) IBOutlet UILabel *percentBuilds;
@property (strong, nonatomic) IBOutlet UILabel *avgDurBuilds;
@property (strong, nonatomic) IBOutlet UILabel *lastBuildState;
@property (strong, nonatomic) IBOutlet UILabel *lastBuildReason;
@property (strong, nonatomic) IBOutlet UILabel *lastBuildDuration;
@property (strong, nonatomic) IBOutlet UITextView *lastBuildArtifacts;

//Class Variables
@property (strong, nonatomic) NSString *planKey;
@property (strong, nonatomic) NSString *numBuildStr;
@property (strong, nonatomic) NSString *percentBuildStr;
@property (strong, nonatomic) NSMutableArray *buildsArray;
@property (strong, nonatomic) NSArray *stateArray;
@property (strong, nonatomic) NSMutableArray *successData;
@property (strong, nonatomic) NSMutableArray *failData;
@property (strong, nonatomic) NSMutableArray *unknownData;
@property (strong, nonatomic) NSNumber *size;
@property (nonatomic) float maxDuration;
@property (nonatomic) int success;
@property (nonatomic) int failure;
@property (nonatomic) int unknown;
@property (nonatomic) int pageNumber;
@property (nonatomic) float height;

//Chart Variables
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (strong, nonatomic) CPTXYGraph *barChart;
@property (strong, nonatomic) CPTBarPlot *sucPlot;
@property (strong, nonatomic) CPTBarPlot *failPlot;
@property (strong, nonatomic) CPTBarPlot *unkPlot;
@property (strong, nonatomic) CPTPlotSpaceAnnotation *annotation;

//Pie Chart Methods
-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;
@end
