//
//  ViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SMCategoriesViewController.h"
#import "SMMessageViewController.h"
#import "SMAboutViewController.h"

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface SMCategoriesViewController () {
    
}
-(void)renderTitle;
-(BOOL)isSubViewCategoryPart:(UIView*) view;
-(void)addMailPropositionBlockinPosY:(int)posY;

- (void)handleCategoryTapping:(UIGestureRecognizer *)sender;
- (void)handleMailPropositionTapping:(UIGestureRecognizer *)sender;

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY forBlock:(int)nbBlock;
- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY;

- (void)fillEmptyBlocks:(int)nb fromPosX:(int)posX andPosY:(int)posY;
- (UILabel*)buildUILabelForBlock:(int)nbBlocks inPosX:(int)posX andPosY:(int)posY;
@end

@implementation SMCategoriesViewController
@synthesize infoButton;
@synthesize titleImage;
@synthesize categories;
@synthesize messageHandler;

static char sosMessageKey;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id iMessageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
    self.messageHandler = iMessageHandler;
    [iMessageHandler release];
    
    [self.messageHandler requestCategories];
}

- (void)viewDidUnload
{
    [self setInfoButton:nil];
    [self setTitleImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self renderTitle];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCategories) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark Category handling

-(UILabel*)buildUILabelForBlock:(int)nbBlocks inPosX:(int)posX andPosY:(int)posY {
    float blockSize = self.view.bounds.size.width / NB_BLOCKS;

    float rectX = floorf(blockSize * posX);
    //float rectY = posY; //origin y will be re-calculate after views are generated
    float rectWidth = ceilf(blockSize * nbBlocks);
    float rectHeight = 1; //arbitrary set to 1
    
    //NSLog(@"Place label (%@) at (%.2f;%.2f) with size (%.2f;%.2f)", label, rectX, rectY, rectWidth, rectHeight);
    
    UILabel* uiLabel = [[UILabel alloc] initWithFrame:CGRectMake(rectX, posY, rectWidth, rectHeight)];
    
    uiLabel.layer.cornerRadius = 3.0f;
    uiLabel.layer.masksToBounds = YES;
    return [uiLabel autorelease];
}

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY forBlock:(int)nbBlock {
    NSString* category_name = [category objectForKey:CATEGORY_NAME];
    
    UILabel* uiLabel = [self buildUILabelForBlock:nbBlock inPosX:posX andPosY:posY];
    
    uiLabel.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[category objectForKey:CATEGORY_COLOR]];
    uiLabel.text = [category_name capitalizedString];
    uiLabel.font = CATEGORY_FONT;

    uiLabel.textColor = [UIColor colorWithHue:uiLabel.backgroundColor.hue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(uiLabel, &sosMessageKey, category, 0);
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel belowSubview:self.infoButton];
}

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY {
    NSString* category_name = [category objectForKey:CATEGORY_NAME];
    [self addSOSCategory:category inPosX:posX andPosY:posY forBlock:[category_name blocksCount:self.view]];
}

- (void)fillEmptyBlocks:(int)nb fromPosX:(int)posX andPosY:(int)posY {
    NSLog(@"Bounds width: %.2f and Frame width: %.2f", self.view.bounds.size.width, self.view.frame.size.width);
    UILabel* emptyBlocks = [self buildUILabelForBlock:nb inPosX:posX andPosY:posY];
    
    float hue = (rand()%24) / 24.0;
    emptyBlocks.backgroundColor = [UIColor colorWithHue:hue saturation:0.05 brightness:0.9 alpha:0.5];
    
    [self.view insertSubview:emptyBlocks belowSubview:self.infoButton];
}

-(void)addMailPropositionBlockinPosY:(int)posY {
    NSString* label = @"Proposez vos messages";
    UILabel* uiLabel = [self buildUILabelForBlock:NB_BLOCKS inPosX:0 andPosY:posY];
    uiLabel.backgroundColor = [UIColor colorWithHue:label.calculateHue saturation:0.55 brightness:0.9 alpha:0.5];
    uiLabel.text = [label capitalizedString];
    uiLabel.font = CATEGORY_FONT;
    uiLabel.textColor = [UIColor colorWithHue:label.calculateHue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMailPropositionTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel belowSubview:self.infoButton];
}

- (void)refreshCategories {
    NSLog(@"Categories refreshed");
    [self removeCategoriesLabel];
    NSMutableArray* workingCategories = [[NSMutableArray alloc] initWithArray:categories];
    int x = 0;
    int y = 0;
    
    if ([workingCategories count] <= 5) {
        for (NSDictionary* category in workingCategories) {
            [self addSOSCategory:category inPosX:0 andPosY:[self.categories indexOfObject:category] forBlock:NB_BLOCKS];
        }
        y = [workingCategories count];
    } else {
        while (workingCategories.count > 0) {
            NSDictionary* category = [workingCategories objectAtIndex:0];
            int blockSize = [[category objectForKey:CATEGORY_NAME] blocksCount:self.view];
            if ((NB_BLOCKS - x < blockSize)) {
                [self fillEmptyBlocks:NB_BLOCKS - x fromPosX:x andPosY:y];
                x = 0;
                y += 1;
            }
            
            [self addSOSCategory:category inPosX:x andPosY:y];
            
            x += blockSize;
            if (x >= NB_BLOCKS) {
                y += 1;
                x = 0;
            }
            
            [workingCategories removeObjectAtIndex:0];
        }
        
        if (x < NB_BLOCKS && x > 0) {
            [self fillEmptyBlocks:NB_BLOCKS - x fromPosX:x andPosY:y];
            y++;
        }
    }
    [workingCategories release];
    
    if ([MFMailComposeViewController canSendMail]) {
        [self addMailPropositionBlockinPosY:y];
    }
    else {
        /* To be re-enabled by default when the propositions btn will be better handled */
        if (x == 0) {
            y -= 1;
        }
    }
    float fitHeight =  ceilf((self.view.bounds.size.height - CATEGORIES_HEADER_SIZE) / (y + 1.0f));
    for (UIView* subView in self.view.subviews) {
        if (subView.tag != 0) {
            continue;
        }
        
        if ([subView isKindOfClass:[UILabel class]]) {
            float viewX = subView.frame.origin.x + CATEGORIES_MARGIN_WIDTH / 2;
            float viewY = floorf(subView.frame.origin.y * fitHeight) + CATEGORIES_HEADER_SIZE - CATEGORIES_MARGIN_HEIGTH;
            float viewWidth = subView.frame.size.width - CATEGORIES_MARGIN_WIDTH;
            float viewHeight = fitHeight - CATEGORIES_MARGIN_HEIGTH;
            
            subView.frame = CGRectMake(viewX, viewY, viewWidth, viewHeight);
        } else if ([subView isKindOfClass:[UIImageView class]]) {
            UIImage* img = [(UIImageView*)subView image];
            float imgRation = img.size.height / img.size.width;
            subView.frame = CGRectMake(subView.frame.origin.x, floorf(subView.frame.origin.y * fitHeight), subView.frame.size.width, imgRation * subView.frame.size.width);
        }
    }
}

-(BOOL)isSubViewCategoryPart:(UIView*) view {
    return ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UILabel class]]) && view.tag == 0;
}

-(void)removeCategoriesLabel {
    for (UIView* subView in self.view.subviews) {
        if ([self isSubViewCategoryPart:subView]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)handleMailPropositionTapping:(UIGestureRecognizer *)sender {
    MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
    [mailer setSubject:@"[sosmessage] Proposition de message"];
    NSArray *toRecipients = [NSArray arrayWithObjects:SM_EMAIL, nil];
    [mailer setToRecipients:toRecipients];
    
    mailer.mailComposeDelegate = self;
    [self presentModalViewController:mailer animated:true];
    
    [mailer release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:true];
}

- (void)handleCategoryTapping:(UIGestureRecognizer *)sender {
    UILabel* uilabel = (UILabel*)sender.view;
    NSDictionary* category = (NSDictionary*)objc_getAssociatedObject(uilabel, &sosMessageKey);
    
    NSLog(@"Category added: %@", category);
    
    SMMessageViewController* detail = [[SMMessageViewController alloc] initWithCategory:category];
    detail.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:detail animated:true];
    [detail release];
}

- (IBAction)aboutPressed:(id)sender {
    SMAboutViewController* about = [[SMAboutViewController alloc] initWithNibName:@"SMAboutViewController" bundle:nil];
    about.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:about animated:true];
    [about release];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    hud.labelText = @"Chargement ...";
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD hideHUDForView:self.view animated:true];
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)result
{
    if ([result objectForKey:CATEGORIES_COUNT] > 0) {
        self.categories = [[[NSMutableArray alloc] initWithArray:[result objectForKey:CATEGORIES_ITEMS]] autorelease];
        [self refreshCategories];
    }
}

#pragma mark Custom methods

- (void)renderTitle {
    UIGraphicsBeginImageContext(self.titleImage.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform flipTransform = CGAffineTransformMake( 1, 0, 0, -1, 0, self.titleImage.bounds.size.height);
    CGContextConcatCTM(context, flipTransform);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.titleImage.bounds);
    
    //Concat sosheader and category name
    NSMutableString* header = [NSMutableString stringWithString:@"sosmessage\ndecarte"];
    
    NSInteger _stringLength=[header length];
    
    CFStringRef string =  (CFStringRef) header;
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString,CFRangeMake(0, 0), string);
    
    CGColorRef _black= [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    CGColorRef _hue= [UIColor whiteColor].CGColor;
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 3),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(3, 7),kCTForegroundColorAttributeName, _hue);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(11, 2),kCTForegroundColorAttributeName, _black);
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

- (void)dealloc {
    [categories release];
    [messageHandler release];
    [infoButton release];
    [titleImage release];
    [super dealloc];
}
@end
