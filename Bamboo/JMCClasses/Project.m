//
//  Project.m
//  table1
//
//  Created by You Liang Low on 11/13/12.
//	Edited by Yung Chang on 3/5/13
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import "Project.h"

@implementation Project
@synthesize projectName = _projectName;
@synthesize key = _key;
@synthesize planSuccess = _planSuccess;
@synthesize planFailed = _planFailed;
@synthesize plans = _plans;

-(void) setKey:(NSString *)projectKey {
    _key = projectKey;
}

-(void) setProjectName:(NSString *)projectName1{
    _projectName = projectName1;
}

-(void) setPlanFailed:(NSNumber *)planFailed {
    _planFailed = planFailed;
}

-(void) setPlanSuccess:(NSNumber *)planSuccess {
    _planSuccess = planSuccess;
}

-(void) setPlans:(NSMutableArray *)plans{
    _plans = plans;
}

-(NSString*) getKey {
    return _key;
}

-(NSString*) getProjectName {
    return _projectName;
}

-(NSNumber*) getPlanSuccess {
    return _planSuccess;
}

-(NSNumber*) getPlanFailed {
    return _planFailed;
}

-(NSMutableArray*) getPlans {
    return _plans;
}

-(void) filter:(NSString*) searchText{
    // NSLog(@"Plans count:%lu",(unsigned long)[_plans count]);
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_plans];
    for(int i = 0; i < [tempArray count]; i++) {
        Plan *plan = [tempArray objectAtIndex:i];
        NSString *planName = [plan getName];
        // NSLog(@"NAME=%@", planName);
        if([planName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound) {
            // NSLog(@"true");
            
        }
        else {
            // NSLog(@"false");
            [tempArray removeObject:plan];
            i--;
        }
        
    }
    _plans = tempArray;
}


@end
