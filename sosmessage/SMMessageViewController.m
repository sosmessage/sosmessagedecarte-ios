//
//  SMDetailViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 06/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SMMessageViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

#define LBL_SMS     @"SMS"
#define LBL_TWITTER @"Twitter"
#define LBL_MAIL    @"Mail"

@interface SMMessageViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {

}
@property (retain, nonatomic) NSDictionary* category;
@property (retain, nonatomic) SMMessagesHandler* messageHandler;
@property (retain, nonatomic) NSString* messageId;

@end

@implementation SMMessageViewController
@synthesize backgroundView;
@synthesize titleImage;
@synthesize messageText;
@synthesize sendMessageButton;
@synthesize otherMessageButton;
@synthesize contributorLabel;
@synthesize votePlusButton;
@synthesize voteMinusButton;
@synthesize votePlusScoring;
@synthesize voteMinusScoring;
@synthesize backButton;
@synthesize category;
@synthesize messageHandler;
@synthesize messageId;

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
        
        self.voteMinusScoring.font = MESSAGE_FONT;
        self.votePlusScoring.font = MESSAGE_FONT;
        self.contributorLabel.font = MESSAGE_FONT;

        id iMessageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
        self.messageHandler = iMessageHandler;
        [iMessageHandler release];
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
    [super dealloc];
}

#pragma mark Custom methods

-(void)refreshRenders {
    [self renderTitle];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self fetchAMessage];
}

- (IBAction)sendMessagePressed:(id)sender {
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"Envoyer le message" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
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
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Annuler"];
        [sheet showInView:self.view];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Impossible" message:@"Vous ne disposez d'aucun moyen pour envoyer le message a vos comparses." delegate:nil cancelButtonTitle:@"Dommage" otherButtonTitles: nil];
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
    NSMutableString* header = [NSMutableString stringWithFormat:@"%@%@%@", @"sosmessage\n", categoryName.preposition, [categoryName lowercaseString]];
    
    NSLog(@"Header: %@", [header lowercaseString]);
    NSInteger _stringLength=[header length];
    
    CFStringRef string =  (CFStringRef) header;
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString,CFRangeMake(0, 0), string);
    
    CGColorRef _black= [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    //CGColorRef _hue= [UIColor colorWithHue:baseHue saturation:0.9 brightness:0.7 alpha:1].CGColor;
    CGColorRef _hue= [UIColor whiteColor].CGColor;
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 3),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(3, 7),kCTForegroundColorAttributeName, _hue);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(10, 3),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(13, _stringLength - 13),kCTForegroundColorAttributeName, _hue);
    
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
    [self.messageHandler requestRandomMessageForCategory:[self.category objectForKey:CATEGORY_ID]];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    hud.labelText = @"Chargement ...";
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)result
{
    if (self.messageText) {
        self.messageText.font = MESSAGE_FONT;
        self.messageId = [result objectForKey:MESSAGE_ID];
        self.messageText.text = [NSString stringWithFormat:@"%@\n\n\t%@", [result objectForKey:MESSAGE_TEXT], [result objectForKey:MESSAGE_CONTRIBUTOR]];
        //self.contributorLabel.text = [result objectForKey:MESSAGE_CONTRIBUTOR];
        
        NSInteger vote = [[[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_USERVOTE] integerValue];
        self.voteMinusButton.enabled = vote != -1;
        self.votePlusButton.enabled = vote != 1;
        self.voteMinusScoring.text = [NSString stringWithFormat:@"%@", [[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_MINUS]];
        self.votePlusScoring.text = [NSString stringWithFormat:@"%@", [[result objectForKey:MESSAGE_VOTE] objectForKey:VOTE_PLUS]];
        
        self.messageText.textColor = [UIColor colorWithHue:baseHue saturation:1.0 brightness:0.3 alpha:1.0];
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
            
            [controller setSubject:[NSString stringWithFormat:@"SOS Message %@%@", [categoryName prepositionWithSpace], categoryName]];
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

@end
