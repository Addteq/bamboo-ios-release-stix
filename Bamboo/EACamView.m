//
//  EACamView.m
//  Bamboo
//
//  Created by Emmanuel Anyiam on 8/29/14.
//  Copyright (c) 2014 Addteq. All rights reserved.
//

#import "EACamView.h"

@implementation EACamView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *) [self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *) [self layer] setSession:session];
}

@end
