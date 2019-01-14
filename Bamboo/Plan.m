//
//  Plan.m
//  table1
//
//  Created by You Liang Low on 11/14/12.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import "Plan.h"
#import "Project.h"

@implementation Plan
@synthesize key = _key;
@synthesize name = _name;
@synthesize project = _project;
@synthesize status = _status;

-(void) setKey:(NSString *)planKey {
    _key = planKey;
}

-(void) setName:(NSString *)planName{
    _name = planName;
}

-(void) setProject:(NSString *)planProject {
    _project = planProject;
}

-(void) setStatus:(NSString *)status{
   _status = status;
}

-(NSString*) getKey {
    return _key;
}

-(NSString*) getName {
    return _name;
}

-(NSString*) getProject {
    return _project;
}

-(NSString *) getStatus {
   return _status;
}


@end
