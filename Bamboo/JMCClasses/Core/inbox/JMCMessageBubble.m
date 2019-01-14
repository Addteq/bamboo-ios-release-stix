/**
 Copyright 2011 Atlassian Software
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **/
//
//  Created by nick on 7/05/11.
//
//  To change this template use File | Settings | File Templates.
//
#import "JMCMessageBubble.h"

@interface JMCMessageBubble ()
@property (nonatomic, retain) UIImageView *bubble;

@end

@implementation JMCMessageBubble

@synthesize bubble, detailLabel, label;


- (id)initWithReuseIdentifier:(NSString *)cellIdentifierComment detailSize:(CGSize)detailSize leftAligned:(BOOL)leftAligned{
    
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierComment])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // this is a work-around for self.backgroundColor = [UIColor clearColor]; appearing black on iOS < 4.3 .
        UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
        transparentBackground.backgroundColor = [UIColor clearColor];
        self.backgroundView = transparentBackground;
        [transparentBackground release];
        
        bubble = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        detailLabelHeight = detailSize.height;
        
        label = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label.tag = 2;
        label.backgroundColor = [UIColor clearColor];
        // TODO: get this working correctly such that it does not truncate messages.
        label.dataDetectorTypes = UIDataDetectorTypeAll;
        label.editable = NO;
        label.scrollEnabled = NO;
        label.contentInset =  UIEdgeInsetsMake(0,0,0,0);
        label.textColor=[UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1.0];
        if (leftAligned)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, detailSize.width, detailLabelHeight)];
            }
            else
            {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, detailSize.width, detailLabelHeight)];
            }
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(-290, 0, detailSize.width, detailLabelHeight)];
            }
            else
            {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(-100, 0, detailSize.width, detailLabelHeight)];
            }
        }

        detailLabel.tag = 3;
        detailLabel.numberOfLines = 1;
        detailLabel.lineBreakMode = NSLineBreakByClipping;
        detailLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        detailLabel.textColor = [UIColor darkGrayColor];
        detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        [message addSubview:detailLabel];
        [message addSubview:bubble];
        [message addSubview:label];
        message.autoresizesSubviews = YES;
        message.tag = 22;
        [self.contentView addSubview:message];
        self.contentView.autoresizesSubviews = YES;
        
        [message release];
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    // only when layoutSubviews is called, is the contentFrame setup correctly.
    CGRect contentFrame = self.contentView.frame;
    
    CGRect detailFrame = self.detailLabel.frame;
    detailFrame.size.width = contentFrame.size.width;
    self.detailLabel.frame = detailFrame; // This is only picked up when the cell goes offscreen...
    
    CGRect bubbleFrame = self.bubble.frame;
    CGRect labelFrame = self.label.frame;
    
    if (bubbleFrame.origin.x == 0) {
        return; // only views that are right justified require relayout.
    }
    bubbleFrame.size.width = bubbleFrame.size.width;
    // set the correct x coord of the right aligned bubble
    bubbleFrame = CGRectMake(contentFrame.size.width - bubbleFrame.size.width,
                             bubbleFrame.origin.y, bubbleFrame.size.width, bubbleFrame.size.height);
    
    // the same for the label that is in the bubble
    labelFrame.origin.x = bubbleFrame.origin.x;
    labelFrame.size.width = labelFrame.size.width;
    self.label.frame = labelFrame;
    self.bubble.frame = bubbleFrame;
}

- (void)setText:(NSString *)string leftAligned:(BOOL)leftAligned withFont:(UIFont *)font size:(CGSize)constSize
{
    //depreciated
 //   CGSize size = [string sizeWithFont:font
 //                    constrainedToSize:CGSizeMake(constSize.width * 0.75, constSize.height)
 //lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size = CGSizeMake(constSize.width *0.75, constSize.height);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attr = @{NSFontAttributeName: font};
    self.label.frame = [string boundingRectWithSize:size options:options attributes:attr context:nil];
    
    UIImage * balloon;
    float balloonY = 2+detailLabelHeight;
    float labelY = detailLabelHeight;
    if (leftAligned) {
        self.label.contentInset =  UIEdgeInsetsMake(0,8,0,0);
        float width = size.width; // these 16points are to counteract the -8 edge insets that are set on the UITextView (label).
        CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
        float x = screenFrame.size.width - width;
        CGRect frame = CGRectMake(x, balloonY, width+50, size.height + 12);
        self.bubble.frame = frame;
        self.bubble.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        balloon = [[UIImage imageNamed:@"mybubble.png"] stretchableImageWithLeftCapWidth:21.0f topCapHeight:20.0f];
        self.label.frame = CGRectMake(x, labelY, width+30, size.height+12);
    } else {
        self.label.contentInset =  UIEdgeInsetsMake(0,0,0,0);
        self.bubble.frame = CGRectMake(0.0f, balloonY, size.width + 38.0f, size.height + 12.0f);
        self.bubble.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        balloon = [[UIImage imageNamed:@"yourbubble.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:20.0f];
        self.label.frame = CGRectMake(15.0f, labelY, size.width + 16, size.height+12);
    }
    
    self.bubble.image = balloon;
    self.label.text = string;
    
    CGRect newframe = self.detailLabel.frame;
    if (leftAligned)
    {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            newframe.origin.x = 290;
        }
        else
        {
            newframe.origin.x=100;
        }
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            newframe.origin.x = -290;
        }
        else
        {
            newframe.origin.x=-100;
        }
    }
    self.detailLabel.frame = newframe;

}

- (void)dealloc {
    [bubble release];
    [detailLabel release];
    [label release];
    [super dealloc];
}

@end
