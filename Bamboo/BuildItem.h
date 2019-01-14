//
//  BuildItem.h
//  buildtest
//
//  Created by Matthew Burnett on 11/15/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildItem : NSObject
//Properties
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *revision;
@property (nonatomic, strong) NSString *prettyTime;
@property (nonatomic, strong) NSString *durationDesc;
@property (nonatomic, strong) NSString *relativeTime;
@property (nonatomic, strong) NSString *durationSeconds;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSMutableArray *artifacts;

//Setters
-(void)setKey:(NSString *)key;
-(void)setNumber:(NSString *)number;
-(void)setRevision:(NSString *)revision;
-(void)setPrettyTime:(NSString *)prettyTime;
-(void)setDurationDesc:(NSString *)durationDesc;
-(void)setRelativeTime:(NSString *)relativeTime;
-(void)setDurationSeconds:(NSString *)durationSeconds;
-(void)setReason:(NSString *)reason;
-(void)setState:(NSString *)state;
-(void)setArtifacts:(NSMutableArray *)artifacts;

//Getters
-(NSString *)getKey;
-(NSString *)getNumber;
-(NSString *)getRevision;
-(NSString *)getPrettyTime;
-(NSString *)getDurationDesc;
-(NSString *)getRelativeTime;
-(NSString *)getDurationSeconds;
-(NSString *)getReason;
-(NSString *)getState;
-(NSMutableArray *)getArtifacts;
@end
