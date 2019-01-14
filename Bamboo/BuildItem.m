//
//  BuildItem.m
//  buildtest
//
//  Created by Matthew Burnett on 11/15/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import "BuildItem.h"

@implementation BuildItem
//Properties
@synthesize key = _key;
@synthesize number = _number;
@synthesize revision = _revision;
@synthesize prettyTime = _prettyTime;
@synthesize durationDesc = _durationDesc;
@synthesize relativeTime = _relativeTime;
@synthesize durationSeconds = _durationSeconds;
@synthesize reason = _reason;
@synthesize state = _state;
@synthesize artifacts = _artifacts;

//Setters
-(void)setKey:(NSString *)key{
   _key = key;
}
-(void)setNumber:(NSString *)number{
   _number = number;
}
-(void)setRevision:(NSString *)revision{
   _revision = revision;
}
-(void)setPrettyTime:(NSString *)prettyTime{
   _prettyTime = prettyTime;
}
-(void)setDurationDesc:(NSString *)durationDesc{
   _durationDesc = durationDesc;
}
-(void)setRelativeTime:(NSString *)relativeTime{
   _relativeTime = relativeTime;
}
-(void)setDurationSeconds:(NSString *)durationSeconds{
   _durationSeconds = durationSeconds;
}
-(void)setReason:(NSString *)reason{
   _reason = reason;
}
-(void)setState:(NSString *)state{
   _state = state;
}
-(void)setArtifacts:(NSMutableArray *)artifacts{
   _artifacts = artifacts;
}

//Getters
-(NSString *)getKey{
   return _key;
}
-(NSString *)getNumber{
   return _number;
}
-(NSString *)getRevision{
   return _revision;
}
-(NSString *)getPrettyTime{
   return _prettyTime;
}
-(NSString *)getDurationDesc{
   return _durationDesc;
}
-(NSString *)getRelativeTime{
   return _relativeTime;
}
-(NSString *)getDurationSeconds{
   return _durationSeconds;
}
-(NSString *)getReason{
   return _reason;
}
-(NSString *)getState{
   return _state;
}
-(NSMutableArray *)getArtifacts{
   return _artifacts;
}
@end
