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
@property (nonatomic, assign) NSDate* lastFetchingDate;

-(void)renderTitle;
-(BOOL)isSubViewCategoryPart:(UIView*) view;

-(void)addAdvertisingBlockinPosY:(int)posY;
-(void)addMailPropositionBlockinPosY:(int)posY;

- (void)handleCategoryTapping:(UIGestureRecognizer *)sender;
- (void)handleMailPropositionTapping:(UIGestureRecognizer *)sender;
- (void)handleAdvertisingTapping:(UIGestureRecognizer *)sender;

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY forBlock:(int)nbBlock;
- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY;

- (void)fillEmptyBlocks:(int)nb fromPosX:(int)posX andPosY:(int)posY;
- (UILabel*)buildUILabelForBlock:(int)nbBlocks inPosX:(int)posX andPosY:(int)posY;
@end

@implementation SMCategoriesViewController
@synthesize infoButton, titleImage, categories, messageHandler, announcements;

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
    
    [self requestCategories];
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
    
    uiLabel.layer.cornerRadius = 7.0f;
    uiLabel.layer.masksToBounds = YES;
    uiLabel.layer.borderWidth = 0.5f;
    uiLabel.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    return [uiLabel autorelease];
}

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY forBlock:(int)nbBlock {
    NSString* category_name = [category objectForKey:CATEGORY_NAME];
    int categoryBlock = nbBlock;
    
    // CATEGORY LABEL
    UILabel* uiLabel = [self buildUILabelForBlock:categoryBlock inPosX:0 andPosY:posY];
    
    uiLabel.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[category objectForKey:CATEGORY_COLOR]];
    uiLabel.text = [NSString stringWithFormat:@"%@", category_name];
    uiLabel.font = CATEGORY_FONT;
    
    uiLabel.textColor = [UIColor colorWithHue:uiLabel.backgroundColor.hue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(uiLabel, &sosMessageKey, category, 0);
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel belowSubview:self.infoButton];
    
    // FLOP LABEL
    UILabel* flopLabel = [self buildUILabelForBlock:1 inPosX:categoryBlock - 1 andPosY:posY];
    flopLabel.text = kTEXT_TOP;
    flopLabel.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[category objectForKey:CATEGORY_COLOR] plusRed:-0.1 plusGreen:0.3 plusBlue:-0.1];
    flopLabel.font = [UIFont fontWithName:@"Georgia" size:13];
    flopLabel.textColor = [UIColor colorWithHue:uiLabel.backgroundColor.hue saturation:1.0 brightness:0.3 alpha:1.0];
    flopLabel.textAlignment = UITextAlignmentCenter;
    flopLabel.layer.cornerRadius = 3.0f;
    flopLabel.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(flopLabel, &sosMessageKey, category, 0);
    
    categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [flopLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:flopLabel aboveSubview:uiLabel];
    
    // TOP LABEL
    UILabel* topLabel = [self buildUILabelForBlock:1 inPosX:categoryBlock - 1 andPosY:posY];
    topLabel.text = kTEXT_FLOP;
    topLabel.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[category objectForKey:CATEGORY_COLOR] plusRed:0.3 plusGreen:-0.1 plusBlue:-0.1];
    topLabel.font = [UIFont fontWithName:@"Georgia" size:13];
    topLabel.textColor = [UIColor colorWithHue:uiLabel.backgroundColor.hue saturation:1.0 brightness:0.3 alpha:1.0];
    topLabel.textAlignment = UITextAlignmentCenter;
    topLabel.layer.cornerRadius = 3.0f;
    topLabel.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(topLabel, &sosMessageKey, category, 0);
    
    categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [topLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:topLabel aboveSubview:uiLabel];
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

-(void)addAdvertisingBlockinPosY:(int)posY {
    NSString* label = kcategories_all;
    UILabel* uiLabel = [self buildUILabelForBlock:NB_BLOCKS inPosX:0 andPosY:posY];
    uiLabel.backgroundColor = [UIColor colorWithHue:label.calculateHue saturation:0.55 brightness:0.9 alpha:0.5];
    uiLabel.text = label;
    uiLabel.font = CATEGORY_FONT;
    uiLabel.textColor = [UIColor colorWithHue:label.calculateHue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAdvertisingTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel belowSubview:self.infoButton];
}

-(void)addMailPropositionBlockinPosY:(int)posY {
    NSString* label = kmessage_propose;
    UILabel* uiLabel = [self buildUILabelForBlock:NB_BLOCKS inPosX:0 andPosY:posY];
    uiLabel.backgroundColor = [UIColor colorWithHue:label.calculateHue saturation:0.55 brightness:0.9 alpha:0.5];
    uiLabel.text = label;
    uiLabel.font = CATEGORY_FONT;
    uiLabel.textColor = [UIColor colorWithHue:label.calculateHue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMailPropositionTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel belowSubview:self.infoButton];
}

-(void)requestCategories {
    self.categories = nil;
    
    [self.messageHandler requestCategories];
}

- (void)refreshCategories {
    if ([AppDelegate sharedDelegate].refreshCategories) {
        NSLog(@"Request new categories.");
        [AppDelegate sharedDelegate].refreshCategories = NO;
        [self requestCategories];
        return;
    }
    
    NSLog(@"Categories refreshed");
    [self removeCategoriesLabel];
    NSMutableArray* workingCategories = [[NSMutableArray alloc] initWithArray:categories];
    int x = 0;
    int y = 0;
    
    if ([workingCategories count] == 1) {
        [self addAdvertisingBlockinPosY:0];
        [self addSOSCategory:[workingCategories objectAtIndex:0] inPosX:0 andPosY:1 forBlock:NB_BLOCKS];
        y = 2;
    } else {
        for (NSDictionary* category in workingCategories) {
            [self addSOSCategory:category inPosX:0 andPosY:[self.categories indexOfObject:category] forBlock:NB_BLOCKS];
        }
        y = [workingCategories count];
    }
    /* temporaly disable this feature ... As the top / flop feature is not yet perfect
     else {
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
     */
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
            
            // Top / Flop handling ... what a mess :]
            NSString *text = [((UILabel *)subView) text];
            if ([text isEqualToString:kTEXT_TOP] || [text isEqualToString:kTEXT_FLOP]) {
                int dummySpace = 1;
                float viewMinus = viewHeight * 0.1;
                viewHeight -= viewMinus;
                viewY += viewMinus / 2;
                viewX -= viewMinus / 2;
                
                if ([text isEqualToString:kTEXT_FLOP]) {
                    viewY = viewY + viewHeight - ceilf(viewHeight / 2) + dummySpace;
                }
                viewHeight = floorf(viewHeight / 2) - dummySpace;
                
                //NSLog(@"Subview: %f:%f %fx%f", viewX, viewY, viewWidth, viewHeight);
            }

            subView.frame = CGRectMake(viewX, viewY, viewWidth, viewHeight);
            
            if (text == kTEXT_TOP || text == kTEXT_FLOP) {
                continue;
            }
            
            // Add "NEW" image above the label
            NSDictionary* category = (NSDictionary*)objc_getAssociatedObject(subView, &sosMessageKey);
            
            if (category) {
                double epoch = [[category objectForKey:CATEGORY_LASTADD] doubleValue] / 1000;
                NSDate* categoryLastAdd = [NSDate dateWithTimeIntervalSince1970:epoch];
                if ([self.lastFetchingDate compare:categoryLastAdd] < 0) {
                    UIImage *img = [UIImage imageNamed:@"new_stamp.png"];
                    UIImageView* newImage = [[UIImageView alloc] initWithImage:img];
                    newImage.center = CGPointMake(viewX + 50, viewY + 10);
                    
                    [self.view addSubview:newImage];
                    [newImage release];
                }
            }
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

- (void)handleAdvertisingTapping:(UIGestureRecognizer *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SM_APP_URL]];
}

- (void)handleMailPropositionTapping:(UIGestureRecognizer *)sender {
    SMProposeNewMessageController* newMessageController = [[SMProposeNewMessageController alloc] initWithNibName:@"SMProposeNewMessageController" bundle:nil];
    newMessageController.categories = self.categories;
    [self presentModalViewController:newMessageController animated:true];
    [newMessageController release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:true];
}

- (void)handleCategoryTapping:(UIGestureRecognizer *)sender {
    UILabel* uilabel = (UILabel*)sender.view;
    NSDictionary* category = (NSDictionary*)objc_getAssociatedObject(uilabel, &sosMessageKey);
    
    SEL sel = [SMMessagesHandler selectorRequestMessageRandom];
    NSString *subtitle = @"";
    if ([uilabel.text isEqualToString:kTEXT_TOP]) {
        sel = [SMMessagesHandler selectorRequestMessageBest];
        subtitle = @"top";
    }
    if ([uilabel.text isEqualToString:kTEXT_FLOP]) {
        sel = [SMMessagesHandler selectorRequestMessageWorst];
        subtitle = @"flop";
    }
    
    SMMessageViewController* detail = [[SMMessageViewController alloc] initWithCategory:category messageHandlerSelector:sel title:subtitle];
    [self.navigationController pushViewController:detail animated:YES];
    
    [detail release];
}

- (IBAction)refreshPressed:(id)sender {
    [AppDelegate sharedDelegate].refreshCategories = YES;
    
    [self refreshCategories];
}

- (IBAction)aboutPressed:(id)sender {
    SMAboutViewController* about = [[SMAboutViewController alloc] initWithNibName:@"SMAboutViewController" bundle:nil];
    about.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:about animated:true];
    [about release];
}

#pragma mark NSNavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Only if it is the top controller aka categoriesController
    if (viewController == self) {
        [self refreshCategories];
    }
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    //NSLog(@"Try to add HUD");
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    hud.labelText = klabel_loading;
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    //NSLog(@"Try to remove HUD");
    if ([MBProgressHUD hideHUDForView:self.view animated:true]) {
        //NSLog(@"Removed");
    } else {
        //NSLog(@"Not found");
    }
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)items
{
    if ([items count] > 0) {
        //NSMutableArray* items = [[[NSMutableArray alloc] initWithArray:[response objectForKey:CATEGORIES_ITEMS]] autorelease];
        
        for (NSDictionary *item in items) {
            if ([@"announcement" isEqualToString:[item objectForKey:@"type"]]) {
                if (!self.announcements) {
                    self.announcements = [[[NSMutableArray alloc] init] autorelease];
                }
                [self.announcements addObject:item];
            }
            
            if ([@"category" isEqualToString:[item objectForKey:@"type"]]) {
                if (!self.categories) {
                    self.categories = [[[NSMutableArray alloc] init] autorelease];
                }
                [self.categories addObject:item];
                [AppDelegate sharedDelegate].refreshCategories = NO;
                
                self.lastFetchingDate = [NSDate date];
            }
        }

        if (!announcements) {
            [self handleAnnouncements];
            return;
        }
    }
    [self refreshCategories];
}

- (void)handleAnnouncements {
    if (!announcements) {
        NSLog(@"No announcements yet");
        self.announcements = [[[NSMutableArray alloc] init] autorelease];
        [self.messageHandler requestAnnouncements];
    }
    else {
        id announcement;
        do {
            announcement = self.announcements.lastObject;
            if ([self isAnnouncementAlreadyRead:announcement]) {
                [self.announcements removeLastObject];
                announcement = nil;
            }
        } while (!announcement && self.announcements.lastObject != nil);
        
        if (announcement) {
            UIAlertView *view = [[[UIAlertView alloc] init] autorelease];
            view.delegate = self;
            view.title = [announcement objectForKey:@"title"];
            view.message = [announcement objectForKey:@"text"];
            
            id url =[announcement objectForKey:@"url"];
            id buttons = [announcement objectForKey:@"buttons"];
            id btnValidate = [buttons objectForKey:@"validate"];
            id btnCancel = [buttons objectForKey:@"cancel"];
            
            if ([url length]) {
                [view addButtonWithTitle:([btnValidate length] ? btnValidate : klabel_btn_go)];
                view.cancelButtonIndex = [view addButtonWithTitle:([btnCancel length] ? btnCancel : klabel_btn_ko)];
            } else {
                view.cancelButtonIndex = [view addButtonWithTitle:([btnCancel length] ? btnCancel : klabel_btn_ok)];
            }
            
            [view show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        id url =[self.announcements.lastObject objectForKey:@"url"];
        NSURL *nsurl = [NSURL URLWithString:(NSString *)url];
        [[UIApplication sharedApplication] openURL:nsurl];
    }
    [self addAnnouncementRead:self.announcements.lastObject];
    [self.announcements removeLastObject];
}

-(void)addAnnouncementRead:(id)anAnnouncement {
    NSMutableArray *announces = [[[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_ANOUNCES] mutableCopy];
    if (!announces) {
        announces = [[NSMutableArray alloc] init];
    }
    [announces addObject:[anAnnouncement objectForKey:@"id"]];
    [[NSUserDefaults standardUserDefaults] setObject:announces forKey:kDEFAULTS_ANOUNCES];
    
    [announces release];
}

-(BOOL)isAnnouncementAlreadyRead:(id)anAnnouncement {
    NSMutableArray *announces = [[NSUserDefaults standardUserDefaults] objectForKey:kDEFAULTS_ANOUNCES];
    if (announces) {
        return [announces containsObject:[anAnnouncement objectForKey:@"id"]];
    }
    return NO;
}

#pragma mark Custom methods

-(NSDate *)lastFetchingDate {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    return (NSDate*)[settings objectForKey:kSOSLASTFETCH];
}

-(void)setLastFetchingDate:(NSDate *)lastFetchingDate {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:lastFetchingDate forKey:kSOSLASTFETCH];
}

- (void)renderTitle {
    UIGraphicsBeginImageContext(self.titleImage.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform flipTransform = CGAffineTransformMake( 1, 0, 0, -1, 0, self.titleImage.bounds.size.height);
    CGContextConcatCTM(context, flipTransform);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.titleImage.bounds);
    
    //Concat sosheader and category name
    NSMutableString* header = [NSMutableString stringWithString:@"sos"];
    if ([AppDelegate applicationName]) {
        [header appendString:[AppDelegate applicationReadableName]];
    } else {
        [header appendString:@"message"];
    }
    
    NSInteger _stringLength=[header length];
    
    CFStringRef string =  (CFStringRef) header;
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString,CFRangeMake(0, 0), string);
    
    CGColorRef _black= [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    CGColorRef _hue= [UIColor whiteColor].CGColor;
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 3),kCTForegroundColorAttributeName, _black);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(3, _stringLength - 3),kCTForegroundColorAttributeName, _hue);
    
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
    [announcements release];
    [messageHandler release];
    [infoButton release];
    [titleImage release];
    [super dealloc];
}
@end
