//
//  Project.h
//  table1
//
//  Created by You Liang Low on 11/13/12.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plan.h"

@interface Project : NSObject
@property (nonatomic, strong) NSString* projectName;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSNumber* planSuccess;
@property (nonatomic, strong) NSNumber* planFailed;
@property (nonatomic, strong) NSMutableArray *plans;


-(void) setKey:(NSString *)key;
-(void) setProjectName:(NSString *)projectName;
-(void) setPlanSuccess:(NSNumber *)planSuccess;
-(void) setPlanFailed:(NSNumber *)planFailed;
-(void) setPlans:(NSMutableArray *)plans;


-(NSString*) getKey;
-(NSString*) getProjectName;
-(NSNumber*) getPlanSuccess;
-(NSNumber*) getPlanFailed;
-(NSMutableArray*) getPlans;
-(void) filter:(NSString*) plan;

@end
