//
//  SMDetailViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 06/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SMMessageViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

#define LBL_SMS     @"SMS"
#define LBL_TWITTER @"Twitter"
#define LBL_MAIL    @"Mail"

@interface SMMessageViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    int currentMessageIndex;
    int fetchCount;
    SEL messageHandlerSelector;
    NSString *subTitle;
}
@property (retain, nonatomic) NSDictionary* category;
@property (retain, nonatomic) SMMessagesHandler* messageHandler;
@property (retain, nonatomic) NSString* messageId;
@property (retain, nonatomic) NSArray* messages;

-(void)messageFillWithHUD:(NSDictionary *)message;
-(void)messageFill:(NSDictionary *)message;
@end

@implementation SMMessageViewController
@synthesize backgroundView;
@synthesize titleImage;
@synthesize messageText;
@synthesize sendMessageButton;
@synthesize otherMessageButton;
@synthesize PreviousMessageButton;
@synthesize contributorLabel;
@synthesize votePlusButton;
@synthesize voteMinusButton;
@synthesize votePlusScoring;
@synthesize voteMinusScoring;
@synthesize backButton;
@synthesize category;
@synthesize messageHandler;
@synthesize messageId;
@synthesize messages;

float baseHue;

- (id)initWithCategory:(NSDictionary*)aCategory {
    self = [super initWithNibName:@"SMMessageViewController" bundle:nil];
    if (self) {
        self.category = aCategory;
        baseHue = [AppDelegate buildUIColorFromARGBStringRepresentation:[self.category objectForKey:CATEGORY_COLOR]].hue;
        self.view.backgroundColor = [UIColor whiteColor];
        self.backgroundView.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[self.category objectForKey:CATEGORY_COLOR]];
        
        //Need to force /n in button title
        //[self.otherMessageButton setTitle:@"SOS\nautre message" forState:UIControlStateNormal];
        [self.otherMessageButton appendOverlaysWithHue:baseHue];
        [self.votePlusButton appendOverlaysWithHue:baseHue];
        [self.voteMinusButton appendOverlaysWithHue:baseHue];
        [self.sendMessageButton appendOverlaysWithHue:baseHue];
        [self.backButton appendOverlaysWithHue:baseHue];
        [self.PreviousMessageButton appendOverlaysWithHue:baseHue];
        
        self.voteMinusScoring.font = MESSAGE_FONT;
        self.votePlusScoring.font = MESSAGE_FONT;
        self.contributorLabel.font = MESSAGE_FONT;

        id iMessageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
        self.messageHandler = iMessageHandler;
        [iMessageHandler release];
        
        //revert previousMessageImage
        self.PreviousMessageButton.imageView.transform = CGAffineTransformMake(-1, 0, 0, 1, 0, self.PreviousMessageButton.imageView.bounds.size.width);
        self.PreviousMessageButton.hidden = YES;
        self.otherMessageButton.hidden = YES;
        
        messageHandlerSelector = [SMMessagesHandler selectorRequestMessageRandom];
        subTitle = @"";
        
        //load interstitil Ad
        fetchCount = 0;
        if ([AppDelegate isInsterstitialAdCompliant]) {
            NSLog(@"Interstitial ad loaded.");
            [self cycleInterstitial];
        }
    }
    return self;
}

- (id)initWithCategory:(NSDictionary *)aCategory messageHandlerSelector:(SEL) s title:(NSString *)aTitle {
    self = [self initWithCategory:aCategory];
    if (self) {
        messageHandlerSelector = s;
        subTitle = aTitle;
    }
    return self;
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
 //   [self dismissModalViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated 
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRenders) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self renderTitle];
    [messageText addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    // Prevent from fetching another message when come back from a send modal view
    if (!self.modalViewController) {
        [self fetchAMessage];
    } else {
        // Froce TextView's tweak to vertical align text
        [self observeValueForKeyPath:nil ofObject:self.messageText change:nil context:nil];
    }
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
    [messageText removeObserver:self forKeyPath:@"contentSize"];
    
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTitleImage:nil];
    [self setMessageText:nil];
    [self setCategory:nil];
    [self setMessageHandler:nil];
    [self setOtherMessageButton:nil];
    [self setBackgroundView:nil];
    [self setVotePlusButton:nil];
    [self setVoteMinusButton:nil];
    [self setMessageId:nil];
    [self setContributorLabel:nil];
    [self setVotePlusScoring:nil];
    [self setVoteMinusScoring:nil];
    [self setSendMessageButton:nil];
    [self setBackButton:nil];
    [self setPreviousMessageButton:nil];
    [self setMessages:nil];
    interstitial = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}


-(BOOL)canBecomeFirstResponder 
{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (motion == UIEventSubtypeMotionShake) {
        [self fetchAMessage];
    }
}

- (void)dealloc {
    [titleImage release];
    [messageText release];
    [category release];
    [messageHandler release];
    [otherMessageButton release];
    [backgroundView release];
    [votePlusButton release];
    [voteMinusButton release];
    [messageId release];
    [contributorLabel release];
    [votePlusScoring release];
    [voteMinusScoring release];
    [sendMessageButton release];
    [backButton release];
    [PreviousMessageButton release];
    [messages release];
    [interstitial release];
    [super dealloc];
}

#pragma mark Custom methods

-(void)refreshRenders {
    [self renderTitle];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self fetchAMessage];
}

- (IBAction)previousButtonPressed:(id)sender {
    [self messageFillWithHUD:[self.messages objectAtIndex:--currentMessageIndex]];
}

- (IBAction)sendMessagePressed:(id)sender {
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:kmessage_share delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    if ([MFMessageComposeViewController canSendText]) {
        [sheet addButtonWithTitle:LBL_SMS];
    }
    if ([MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:LBL_MAIL];
    }
    if ([TWTweetComposeViewController canSendTweet]) {
        [sheet addButtonWithTitle:LBL_TWITTER];
    }
    NSLog(@"Number of buttons in action sheet: %d", sheet.numberOfButtons);
    if (sheet.numberOfButtons > 0) {
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:klabel_btn_cancel];
        [sheet showInView:self.view];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:kmessage_share_unable_title message:kmessage_share_unable delegate:nil cancelButtonTitle:klabel_btn_cancel otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)voteButtonPressed:(id)sender {
    NSInteger vote = (sender == self.votePlusButton) ? 1 : -1;
    [self.messageHandler requestVote:vote messageId:self.messageId];
}

- (void)renderTitle {
    UIGraphicsBeginImageContext(self.titleImage.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform flipTransform = CGAffineTransformMake( 1, 0, 0, -1, 0, self.titleImage.bounds.size.height);
    CGContextConcatCTM(context, flipTransform);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.titleImage.bounds);
    
    NSString* categoryName = [self.category objectForKey:CATEGORY_NAME];
    
    //Concat sosheader and category name
    NSMutableString* header = [NSMutableString stringWithFormat:@"%@%@%@", subTitle, @"sosmessage\n", [categoryName lowercaseString]];
    
    NSLog(@"Header: %@", [header lowercaseString]);
    NSInteger _stringLength=[header length];
    
    CFStringRef string =  (CFStringRef) header;
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString,CFRangeMake(0, 0), string);
    
    CGColorRef _black= [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    //CGColorRef _hue= [UIColor colorWithHue:baseHue saturation:0.9 brightness:0.7 alpha:1].CGColor;
    CGColorRef _hue= [UIColor whiteColor].CGColor;

    int stl = [subTitle length];
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, [subTitle length]),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(stl, 3),kCTForegroundColorAttributeName, _hue);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(stl + 3, 7),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(stl + 10, _stringLength - (13 + stl)),kCTForegroundColorAttributeName, _hue);
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)FONT_NAME, 20, nil);
    CFAttributedStringSetAttribute(attrString,CFRangeMake(0, _stringLength),kCTFontAttributeName,font);
    
    CTTextAlignment alignement = kCTRightTextAlignment;
    CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignement), &alignement};
    CTParagraphStyleRef paragraph = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, _stringLength), kCTParagraphStyleAttributeName, paragraph);
    CFRelease(paragraph);
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    // Create the frame and draw it into the graphics context
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(framesetter);
    CTFrameDraw(frame, context);
    CFRelease(frame);
    CFRelease(path);
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.titleImage.image = result;
}

-(void)fetchAMessage {
    if (interstitial.loaded && fetchCount > 3) {
        [interstitial presentFromViewController:self];
        fetchCount = 0;
        return;
    }
    
    if (!self.messages) {
        [self.messageHandler performSelector:messageHandlerSelector withObject:[self.category objectForKey:CATEGORY_ID]];
        //[self.messageHandler requestRandomMessageForCategory:[self.category objectForKey:CATEGORY_ID]];
        //[self.messageHandler requestBestMessageForCategory:[self.category objectForKey:CATEGORY_ID]];
    } else {
        [self messageFillWithHUD:[self.messages objectAtIndex:++currentMessageIndex]];
    }
    
    if ([AppDelegate isInsterstitialAdCompliant]) {
        fetchCount += 1;
    }
}

-(void)messageFillWithHUD:(NSDictionary *)message {
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:self.view.window] autorelease];
    [self.view addSubview:hud];
    hud.labelText = [NSString stringWithFormat:@"%@message #%d", subTitle, currentMessageIndex + 1];
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    [self messageFill:message];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    hud.labelText = klabel_loading;
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)result
{
    id response = [result objectForKey:JSON_RESPONSE];
    if ([response objectForKey:@"count"]) {
        //list of message
        self.messages = [response objectForKey:@"items"];
        currentMessageIndex = 0;
        [self messageFill:[self.messages objectAtIndex:currentMessageIndex]];
    } else {
        //only one
        [self messageFill:response];
    }
    self.otherMessageButton.hidden = NO;
    self.PreviousMessageButton.hidden = self.messages ? NO : YES;
}

-(void)messageFill:(NSDictionary *)result {
    if (self.messageText) {
        self.messageText.font = MESSAGE_FONT;
        self.messageId = [result objectForKey:MESSAGE_ID];
        if ([result objectForKey:MESSAGE_CONTRIBUTOR]) {
            self.messageText.text = [NSString stringWithFormat:@"%@\n\n\t%@", [result objectForKey:MESSAGE_TEXT], [result objectForKey:MESSAGE_CONTRIBUTOR]];
        } else {
            self.messageText.text = [NSString stringWithFormat:@"%@", [result objectForKey:MESSAGE_TEXT]];
        }

        //self.contributorLabel.text = [result objectForKey:MESSAGE_CONTRIBUTOR];
        
        NSInteger vote = [[[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_USERVOTE] integerValue];
        self.voteMinusButton.enabled = vote != -1;
        self.votePlusButton.enabled = vote != 1;
        self.voteMinusScoring.text = [NSString stringWithFormat:@"%@", [[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_MINUS]];
        self.votePlusScoring.text = [NSString stringWithFormat:@"%@", [[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_PLUS]];
        
        self.messageText.textColor = [UIColor colorWithHue:baseHue saturation:1.0 brightness:0.3 alpha:1.0];
    }
    
    if (self.messages) {
        self.PreviousMessageButton.enabled = currentMessageIndex != 0;
        self.otherMessageButton.enabled = currentMessageIndex < self.messages.count - 1;
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button pressed: %d", buttonIndex);
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        NSString* btnText = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (btnText == LBL_SMS) {
            // SMS
            MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
            controller.messageComposeDelegate = self;
            controller.body = self.messageText.text;
            [self presentModalViewController:controller animated:true];
            [controller release];
        } else if (btnText == LBL_MAIL) {
            // Mail
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            NSString* categoryName = [self.category objectForKey:CATEGORY_NAME];
            
            [controller setSubject:[NSString stringWithFormat:@"sosmessage %@", categoryName]];
            [controller setMessageBody:self.messageText.text isHTML:false];
            [self presentModalViewController:controller animated:true];
            [controller release];
        } else if (btnText == LBL_TWITTER) {
            // Twitter
            TWTweetComposeViewController* controller = [[TWTweetComposeViewController alloc] init];
            if (![controller setInitialText:self.messageText.text]) {
                [controller setInitialText:[NSString stringWithFormat:@"%@…", [self.messageText.text substringWithRange:NSMakeRange(0, 139)]]];
            }
            [self presentModalViewController:controller animated:true];
            [controller release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:TRUE];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:TRUE];
}

#pragma mark iAd - interstitial
- (void)cycleInterstitial {
    interstitial.delegate = nil;
    [interstitial release];
    
    interstitial = [[ADInterstitialAd alloc] init];
    interstitial.delegate = self;    
}

#pragma mark ADInterstitialViewDelegate methods

// When this method is invoked, the application should remove the view from the screen and tear it down.
// The content will be unloaded shortly after this method is called and no new content will be loaded in that view.
// This may occur either when the user dismisses the interstitial view via the dismiss button or
// if the content in the view has expired.
- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    [self cycleInterstitial];
    [self fetchAMessage];
}

// This method will be invoked when an error has occurred attempting to get advertisement content. 
// The ADError enum lists the possible error codes.
- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self cycleInterstitial];
}

#pragma mark -

@end
