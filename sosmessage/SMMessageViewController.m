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

@interface SMMessageViewController () {

}
@property (retain, nonatomic) NSDictionary* category;
@property (retain, nonatomic) SMMessagesHandler* messageHandler;

@end

@implementation SMMessageViewController
@synthesize titleImage;
@synthesize messageText;
@synthesize otherMessageButton;
@synthesize category;
@synthesize messageHandler;

float baseHue;

- (id)initWithCategory:(NSDictionary*)aCategory {
    self = [super initWithNibName:@"SMMessageViewController" bundle:nil];
    if (self) {
        self.category = aCategory;
        baseHue = [[self.category objectForKey:CATEGORY_NAME] hue];
        self.view.backgroundColor = [UIColor colorWithHue:baseHue saturation:0.40 brightness:0.9 alpha:1];
        
        UIView* buttonOverlay = [[UIView alloc] initWithFrame:self.otherMessageButton.frame];
        buttonOverlay.backgroundColor = [UIColor colorWithHue:baseHue saturation:0.8 brightness:0.9 alpha:0.8];
        buttonOverlay.userInteractionEnabled = false;
        buttonOverlay.layer.cornerRadius = 10.0f;
        buttonOverlay.layer.masksToBounds = YES;
        [self.view insertSubview:buttonOverlay aboveSubview:self.otherMessageButton];
        
        UILabel* buttonLabel = [[UILabel alloc] initWithFrame:self.otherMessageButton.frame];
        buttonLabel.text = @"SOS\nautre message";
        buttonLabel.numberOfLines = 2;
        buttonLabel.backgroundColor = [UIColor clearColor];
        buttonLabel.textColor = [UIColor whiteColor];
        buttonLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        buttonLabel.textAlignment = UITextAlignmentCenter;
        buttonLabel.userInteractionEnabled = FALSE;
        [self.view insertSubview:buttonLabel aboveSubview:buttonOverlay];
        
        [buttonLabel release];
        [buttonOverlay release];

        id iMessageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
        self.messageHandler = iMessageHandler;
        [iMessageHandler release];
    }
    return self;
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:true];
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
    [self fetchAMessage];
 
    [messageText addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTitleImage:nil];
    [self setMessageText:nil];
    [self setCategory:nil];
    [self setMessageHandler:nil];
    [self setOtherMessageButton:nil];
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
    [super dealloc];
}

#pragma mark Custom methods

-(void)refreshRenders {
    [self renderTitle];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self fetchAMessage];
}

- (void)renderTitle {
    UIGraphicsBeginImageContext(self.titleImage.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform flipTransform = CGAffineTransformMake( 1, 0, 0, -1, 0, self.titleImage.bounds.size.height);
    CGContextConcatCTM(context, flipTransform);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.titleImage.bounds);
    
    NSString* categoryName = [self.category objectForKey:CATEGORY_NAME];
    NSMutableString* sosHeader = [NSMutableString stringWithString:@"sosmessage\n"];
    //Handle "de" and "d'" case depending of the category name first char.
    NSCharacterSet* letters = [NSCharacterSet characterSetWithCharactersInString:@"aeiou"];
    if ([letters characterIsMember:[[categoryName lowercaseString] characterAtIndex:0]]) {
        [sosHeader appendString:@"d'"];
    } else {
        [sosHeader appendString:@"de"];
    }
    
    //Concat sosheader and category name
    NSMutableString* header = [NSMutableString stringWithFormat:@"%@%@", sosHeader, [categoryName lowercaseString]];
    
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
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)@"Helvetica", 20, nil);
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
        self.messageText.text = [result objectForKey:MESSAGE_TEXT];
        self.messageText.textColor = [UIColor colorWithHue:baseHue saturation:1.0 brightness:0.3 alpha:1.0];
    }
}

@end
