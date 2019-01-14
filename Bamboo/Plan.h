//
//  Plan.h
//  table1
//
//  Created by You Liang Low on 11/14/12.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plan : NSObject
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* project;
@property (nonatomic, strong) NSString* status;

-(void) setKey:(NSString *)key;
-(void) setName:(NSString *)name;
-(void) setProject:(NSString *)project;
-(void) setStatus:(NSString *)status;

-(NSString*) getKey;
-(NSString*) getName;
-(NSString*) getProject;
-(NSString*) getStatus;

@end
