//
//  Commit.m
//  Changes
//
//  Created by Matthew Burnett on 12/19/12.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import "Commit.h"

@implementation Commit
@synthesize message;
@synthesize author;

+ (id)messageWithAuthor:(NSString *)message author:(NSString *)author
{
   Commit *newCommit = [[self alloc] init];
   [newCommit setMessage:message];
   [newCommit setAuthor:author];
   return newCommit;
}

@end
