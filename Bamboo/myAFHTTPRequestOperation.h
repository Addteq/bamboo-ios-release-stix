//
//  myAFHTTPRequestOperation.h
//  Bamboo
//
//  Created by Weifeng Zheng on 7/9/13.
//  Copyright (c) 2013 Weifeng Zheng. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface myAFHTTPRequestOperation : AFHTTPRequestOperation
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
@end

