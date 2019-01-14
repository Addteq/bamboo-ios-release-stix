
#import "UILabel+JMCVerticalAlign.h"


@implementation UILabel (JMCVerticalAlign)
- (void)jmc_alignTop {
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
  //  CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    CGSize maximumLabelSize = CGSizeMake(finalWidth, finalHeight);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGRect labelBounds = [self.text boundingRectWithSize:maximumLabelSize
                                              options:options
                                           attributes:attr
                                              context:nil];
    CGFloat correctHeight = ceilf(labelBounds.size.height);
    
    int newLinesToPad = (finalHeight  - correctHeight) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)jmc_alignBottom {
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    
 //   CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    CGSize maximumLabelSize = CGSizeMake(finalWidth, finalHeight);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGRect labelBounds = [self.text boundingRectWithSize:maximumLabelSize
                                                 options:options
                                              attributes:attr
                                                 context:nil];
    CGFloat correctHeight = ceilf(labelBounds.size.height);
    
    
    int newLinesToPad = (finalHeight  - correctHeight) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}
@end