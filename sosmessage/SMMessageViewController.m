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

@interface SMMessageViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPopoverControllerDelegate, ADInterstitialAdDelegate> {
    int currentMessageIndex;
    int fetchCount;
    SEL messageHandlerSelector;
}
@property (retain, nonatomic) NSDictionary* category;
@property (retain, nonatomic) SMMessagesHandler* messageHandler;
@property (retain, nonatomic) NSString* messageId;

-(void)messageFill:(NSDictionary *)message;
@end

@implementation SMMessageViewController
@synthesize backgroundView;
@synthesize messageText;
@synthesize categoryName;
@synthesize sendMessageButton;
@synthesize otherMessageButton;
@synthesize PreviousMessageButton;
@synthesize contributorLabel;
@synthesize votePlusButton;
@synthesize voteMinusButton;
@synthesize votePlusScoring;
@synthesize backButton;
@synthesize category;
@synthesize messageHandler;
@synthesize handlerMode;
@synthesize messageId;

float baseHue;

- (id)initWithCategory:(NSDictionary*)aCategory {
    self = [super initWithNibName:@"SMMessageViewController" bundle:nil];
    if (self) {
        self.category = aCategory;
        baseHue = [AppDelegate buildUIColorFromARGBStringRepresentation:[self.category objectForKey:CATEGORY_COLOR]].hue;
        
        self.view.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[self.category objectForKey:CATEGORY_COLOR]];
        self.sendMessageButton.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[self.category objectForKey:CATEGORY_COLOR]];
        
        self.votePlusScoring.font = MESSAGE_FONT;
        self.contributorLabel.font = MESSAGE_FONT;

        self.messageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
        
        //load interstitil Ad
        fetchCount = 0;
        if ([AppDelegate isInsterstitialAdCompliant]) {
            NSLog(@"Interstitial ad loaded.");
            [self cycleInterstitial];
        }
    }
    return self;
}

- (id)initWithCategory:(NSDictionary *)aCategory messageHandlerSelector:(SEL) s {
    self = [self initWithCategory:aCategory];
    if (self) {
        NSLog(@"XXX Deprecated: initWithCategory: messageHandlerSelector:");
        //messageHandlerSelector = s;
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
    
    [messageText addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    self.categoryName.text = [[self.category objectForKey:CATEGORY_NAME] capitalizedString];
    
    // Prevent from fetching another message when come back from a send modal view
    if (!self.modalViewController) {
        [self switchModePressed:nil];
    } else {
        // Force TextView's tweak to vertical align text
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

- (void)viewDidUnload
{
    [self setMessageText:nil];
    [self setCategory:nil];
    [self setCategoryName:nil];
    [self setMessageHandler:nil];
    [self setOtherMessageButton:nil];
    [self setBackgroundView:nil];
    [self setVotePlusButton:nil];
    [self setVoteMinusButton:nil];
    [self setMessageId:nil];
    [self setHandlerMode:nil];
    [self setContributorLabel:nil];
    [self setVotePlusScoring:nil];
    [self setSendMessageButton:nil];
    [self setBackButton:nil];
    [self setPreviousMessageButton:nil];
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
    return;
    
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
        [self fillNextMessage];
    }
}

- (void)dealloc {
    [messageText release];
    [category release];
    [messageHandler release];
    [otherMessageButton release];
    [backgroundView release];
    [votePlusButton release];
    [categoryName release];
    [voteMinusButton release];
    [messageId release];
    [contributorLabel release];
    [handlerMode release];
    [votePlusScoring release];
    [sendMessageButton release];
    [backButton release];
    [PreviousMessageButton release];
    [interstitial release];
    [super dealloc];
}

#pragma mark Custom methods

-(void)refreshRenders {
    NSLog(@"Deprecated");
}

-(void)resetMessageHandler {
    currentMessageIndex = 0;
    
    [messageHandler release];
    self.messageHandler = nil;

    self.messageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
    
    [self.messageHandler performSelector:messageHandlerSelector withObject:[self.category objectForKey:CATEGORY_ID]];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self fillNextMessage];
}

- (IBAction)previousButtonPressed:(id)sender {
    [self fillPreviousMessage];
}

- (IBAction)sendMessagePressed:(id)sender {
    //UIActivityViewController should be only available on iOS6
    if ([UIActivityViewController class] != nil) {
        NSLog(@"Display UIActivityView");
        UIActivityViewController *activity = [[[UIActivityViewController alloc] initWithActivityItems:@[self.messageText.text] applicationActivities:nil] autorelease];
        
        if ([AppDelegate isIPad]) {
            NSLog(@"Try open activity in a popover");
            UIButton *btnSender = (UIButton *)sender;
            UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:activity];
            aPopover.delegate = self;
            [aPopover presentPopoverFromRect:btnSender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        } else {
            [self presentModalViewController:activity animated:YES];
        }
    }
    //If something less than iOS6
    else {
        NSLog(@"Display Custom action sheet");
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
}

- (IBAction)voteButtonPressed:(id)sender {
    NSInteger vote = (sender == self.votePlusButton) ? 1 : -1;
    [self.messageHandler requestVote:vote messageId:self.messageId];
}

- (IBAction)switchModePressed:(id)sender {
    if (messageHandlerSelector == [SMMessagesHandler selectorRequestMessageRandom]) {
        NSLog(@"Switching to best message handler");
        messageHandlerSelector = [SMMessagesHandler selectorRequestMessageBest];
        [self.handlerMode setTitle:@"Random" forState:UIControlStateNormal];
    } else {
        NSLog(@"Switching to random message handler");
        messageHandlerSelector = [SMMessagesHandler selectorRequestMessageRandom];
        [self.handlerMode setTitle:@"Most liked" forState:UIControlStateNormal];
    }
    
    [self resetMessageHandler];
}


-(void)fillNextMessage {
    [self fillMessageWithDirection:1];
}

-(void)fillMessageWithDirection:(int)direction {
    if (interstitial.loaded && fetchCount > 5) {
        [interstitial presentFromViewController:self];
        fetchCount = 0;
        return;
    }
    
    if (direction < 0) {
        [self.messageHandler fetchPreviousMessage];
    } else {
        [self.messageHandler fetchNextMessage];
    }
    
    if ([AppDelegate isInsterstitialAdCompliant]) {
        fetchCount += 1;
    }
}

-(void)fillPreviousMessage {
    [self fillMessageWithDirection:-1];
}

-(void)fetchAMessage {
    NSLog(@"XXX fetchAMessage called ...");
    return;
    
    if (interstitial.loaded && fetchCount > 3) {
        [interstitial presentFromViewController:self];
        fetchCount = 0;
        return;
    }
    
    if ([AppDelegate isInsterstitialAdCompliant]) {
        fetchCount += 1;
    }
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
    [self messageFill:result];
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
        
        
        NSInteger nbVote = [[[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_PLUS] integerValue];

        self.votePlusScoring.text = [NSString stringWithFormat:@"%d like%@", nbVote, nbVote > 1 ? @"s" : @""];
        
        self.messageText.textColor = [UIColor colorWithHue:baseHue saturation:1.0 brightness:0.3 alpha:1.0];
    }

    self.PreviousMessageButton.enabled = [self.messageHandler hasPrevious];
    self.otherMessageButton.enabled = [self.messageHandler hasNext];
}

#pragma mark UIPopOverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [popoverController release];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button pressed: %d", buttonIndex);
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        NSString* btnText = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([btnText isEqual: LBL_SMS]) {
            // SMS
            MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
            controller.messageComposeDelegate = self;
            controller.body = self.messageText.text;
            [self presentModalViewController:controller animated:true];
            [controller release];
        } else if ([btnText isEqual: LBL_MAIL]) {
            // Mail
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"sosmessage %@", self.categoryName.text]];
            [controller setMessageBody:self.messageText.text isHTML:false];
            [self presentModalViewController:controller animated:true];
            [controller release];
        } else if ([btnText isEqual: LBL_TWITTER]) {
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
    //XXX todo should not be next all the times.
    [self fillNextMessage];
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self cycleInterstitial];
}

#pragma mark -

@end
