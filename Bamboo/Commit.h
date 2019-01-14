//
//  Commit.h
//  Changes
//
//  Created by Matthew Burnett on 12/19/12.
//  Copyright (c) 2012 You Low Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commit : NSObject{
   NSString *author;
   NSString *message;
}
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *message;

+ (id)messageWithAuthor:(NSString*)message author:(NSString*)author;

@end
