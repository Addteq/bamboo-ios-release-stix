//
//  EACamView.h
//  Bamboo
//
//  Created by Emmanuel Anyiam on 8/29/14.
//  Copyright (c) 2014 Addteq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface EACamView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
