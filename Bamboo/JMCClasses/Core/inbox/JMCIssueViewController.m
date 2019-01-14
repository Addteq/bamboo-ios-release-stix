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

#import "JMCIssueViewController.h"
#import "JMCMessageCell.h"
#import "JMCViewController.h"
#import "JMCMessageBubble.h"
#import "JMCIssueStore.h"
#import "JMC.h"

static UIFont *font;
static UIFont *titleFont;

@implementation JMCIssueViewController

static float detailLabelHeight = 21.0f;

@synthesize tableView = _tableView, issue = _issue;
@synthesize comments = _comments;
@synthesize feedbackController = _feedbackController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        font = [UIFont systemFontOfSize:14.0];
        titleFont = [UIFont boldSystemFontOfSize:14.0];
        UIBarButtonItem *replyButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                      target:self
                                                      action:@selector(didTouchReply:)];
        self.navigationItem.rightBarButtonItem = replyButton;
        [replyButton release];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kJMCNewCommentCreated object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.issue = nil;
    self.comments = nil;
    self.tableView = nil;
    self.feedbackController = nil;
    [super dealloc];
}

- (void)scrollToLastComment
{
    if ([self.comments count] > 0 && [self.tableView numberOfRowsInSection:1] > 0) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:([self.comments count] - 1) inSection:1];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    [self scrollToLastComment];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations

    return YES;
}

- (void)setUpCommentDataFor:(JMCIssue *)issue
{
    // the first comment is a dummy comment obj that stores the description of the issue
    JMCComment *description = [[JMCComment alloc] initWithAuthor:@"Author"
                                                      systemUser:YES body:self.issue.description
                                                            date:self.issue.dateCreated
                                                       requestId:self.issue.requestId];
    NSMutableArray *commentData = [NSMutableArray arrayWithObject:description];
    [commentData addObjectsFromArray:issue.comments];
    self.comments = commentData;
    [description release];
}

- (void)setIssue:(JMCIssue *)issue
{
    if (_issue != issue) {
        [_issue release];
        _issue = [issue retain];
        [self setUpCommentDataFor:issue];

    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil; // no headings
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : [self.comments count];
}

-(CGSize) detailSize 
{
    CGRect frame = self.view.frame;
    return CGSizeMake(frame.size.width, detailLabelHeight);
}

-(CGSize) bubbleSize
{
    return CGSizeMake([self detailSize].width * 0.9f, self.view.frame.size.height * 20.0f); // 20 screens of text should be ample :)
}

- (CGSize)sizeForComment:(JMCComment *)comment font:(UIFont *)commentFont
{
    CGSize bubbleSize = [self bubbleSize];
    // the text is constrained to 3/4 of the width of the bubble. see JMCMessageBubble setText...
//    CGSize constrainTo = CGSizeMake(bubbleSize.width * 0.75f, bubbleSize.height);

 //   return [comment.body sizeWithFont:commentFont constrainedToSize:constrainTo lineBreakMode:NSLineBreakByWordWrapping];
    CGSize maximumLabelSize = CGSizeMake(bubbleSize.width * 0.75f, bubbleSize.height);
    NSStringDrawingOptions options = NSLineBreakByWordWrapping;
    NSDictionary *attr = @{NSFontAttributeName:commentFont};
    CGSize textSize = [comment.body boundingRectWithSize:maximumLabelSize
                                         options:options
                                      attributes:attr
                                         context:nil].size;
    return textSize;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
   //     CGSize size = [self.issue.summary sizeWithFont:titleFont constrainedToSize:CGSizeMake(screenFrame.size.width - 20.0f, 18.0f) lineBreakMode:NSLineBreakByClipping];
        CGSize maximumLabelSize = CGSizeMake(screenFrame.size.width - 20.0f, 18.0f);
        NSStringDrawingOptions options = NSLineBreakByClipping;
        NSDictionary *attr = @{NSFontAttributeName:titleFont};
        CGSize textSize = [self.issue.summary boundingRectWithSize:maximumLabelSize
                                                     options:options
                                                  attributes:attr
                                                     context:nil].size;
        
        
        return textSize.height + 20;

    } else {
        JMCComment *comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat height = [self sizeForComment:comment font:font].height;
        return height + 15.0f + detailLabelHeight;
    }
}

static BOOL isPad(void) {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

- (UITableViewCell *)getBubbleCell:(UITableView *)tableView forMessage:(JMCComment *)comment
{
    static NSString *cellIdentifierComment = @"JMCMessageCellComment";

    JMCMessageBubble *messageCell = (JMCMessageBubble *) [tableView dequeueReusableCellWithIdentifier:cellIdentifierComment];
    
    CGSize detailSize = [self detailSize];
    CGSize frameSize = [self bubbleSize];
    
    if (messageCell == nil) {
        messageCell = [[[JMCMessageBubble alloc] initWithReuseIdentifier:cellIdentifierComment detailSize:detailSize leftAligned:comment.systemUser] autorelease];
        messageCell.label.font = font;
    }

    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //CHange here
    //Testing for Moving time sheet
    //NSString *string = [[NSString alloc]initWithFormat:@"%@ \n%@",comment.body,[dateFormatter stringFromDate:comment.date]];
    [messageCell setText:comment.body
             leftAligned:comment.systemUser
                withFont:font
                    size:frameSize];
    
    
    messageCell.detailLabel.text = [dateFormatter stringFromDate:comment.date];
    
    NSLog(@"Date %@", comment.date);
    return messageCell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"JMCMessageCell";
        JMCMessageCell *issueCell = (JMCMessageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (issueCell == nil) {

            issueCell = [[[JMCMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            issueCell.backgroundColor = [UIColor whiteColor];
            issueCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
 //           CGSize size = [self.issue.summary sizeWithFont:titleFont constrainedToSize:CGSizeMake(screenFrame.size.width - 40.0f, 18.0f) lineBreakMode:NSLineBreakByTruncatingTail];
            CGSize maximumLabelSize = CGSizeMake(screenFrame.size.width - 40.0f, 18.0f);
            NSStringDrawingOptions options = NSLineBreakByTruncatingTail;
            NSDictionary *attr = @{NSFontAttributeName: titleFont};
            CGRect labelBounds = [self.issue.summary boundingRectWithSize:maximumLabelSize
                                                         options:options
                                                      attributes:attr
                                                         context:nil];
            CGFloat correctHeight = ceilf(labelBounds.size.height);
            CGFloat correctWidth = ceilf(labelBounds.size.width);

            
            
            issueCell.title = [[[UILabel alloc] initWithFrame:CGRectMake(screenFrame.size.width * 0.1f, 10, correctWidth, correctHeight)] autorelease];
            issueCell.title.font = titleFont;
            issueCell.title.textColor = [UIColor colorWithRed:17 / 255.0f green:76 / 255.0f blue:147 / 255.0f alpha:1.0];
            issueCell.autoresizesSubviews = YES;
            issueCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            [issueCell addSubview:issueCell.title];
            issueCell.accessoryType = UITableViewCellAccessoryNone;
        }

        issueCell.title.text = self.issue.summary;

        return issueCell;

    }
    else
    {
        JMCComment *comment = [self.comments objectAtIndex:indexPath.row];
        if(indexPath.row==0){
            NSLog(@"HERE---------------------------------");
        }else{
            NSLog(@"-------------------------------------");
        }
        return [self getBubbleCell:tableView forMessage:comment];
        
    }
}

- (void)didTouchReply:(id)sender
{

    //TODO: using a UINavigationController to get the nice navigationBar at the top of the feedback view. better way to do this?
    self.feedbackController = [[[JMCViewController alloc] initWithNibName:@"JMCViewController" bundle:nil] autorelease];
    self.feedbackController.replyToIssue = self.issue;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:self.feedbackController animated:YES];
    }
    else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.feedbackController];
        navController.navigationBar.barStyle = [[JMC sharedInstance] getBarStyle];
        navController.navigationBar.tintColor = [JMC sharedInstance].options.barTintColor;
        [self presentViewController:navController animated:YES completion:nil];
        [navController release];
    }
}

-(void)refreshTable
{
    self.issue.comments = [[JMCIssueStore instance] loadCommentsFor:self.issue];
    [self setUpCommentDataFor:self.issue];
    
    [self.tableView reloadData];
    [self scrollToLastComment];
}

@end
