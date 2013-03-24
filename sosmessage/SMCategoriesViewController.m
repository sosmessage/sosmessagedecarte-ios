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
@synthesize infoButton, categories, messageHandler, announcements, applicationName, refreshButton;

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
    self.creditsLabel.font = BARS_FONT;
    self.applicationName.font = BARS_FONT;
    [AppDelegate logAvaiableFonts];
}

- (void)viewDidUnload
{
    [self setInfoButton:nil];
    [self setRefreshButton:nil];
    [self setApplicationName:nil];
    [self setCreditsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    self.applicationName.text = [AppDelegate applicationReadableName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCategories) name:UIDeviceOrientationDidChangeNotification object:nil];
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
    
    //uiLabel.layer.cornerRadius = 7.0f;
    //uiLabel.layer.masksToBounds = YES;
    //uiLabel.layer.borderWidth = 0.5f;
    //uiLabel.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    return [uiLabel autorelease];
}

- (void)addSOSCategory:(NSDictionary*)category inPosX:(int)posX andPosY:(int)posY forBlock:(int)nbBlock {
    
    NSString* category_name = [category objectForKey:CATEGORY_NAME];
    int categoryBlock = nbBlock;
    
    // CATEGORY LABEL
    UILabel* uiLabel = [self buildUILabelForBlock:categoryBlock inPosX:0 andPosY:posY];
    
    uiLabel.text = [[NSString stringWithFormat:@"%@", category_name] capitalizedString];
    uiLabel.font = CATEGORY_FONT;
    uiLabel.backgroundColor = [UIColor clearColor];
    
    uiLabel.textColor = [UIColor colorWithHue:uiLabel.backgroundColor.hue saturation:1.0 brightness:0.3 alpha:1.0];
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    objc_setAssociatedObject(uiLabel, &sosMessageKey, category, 0);
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view insertSubview:uiLabel aboveSubview:self.infoButton];
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
    
    if ([workingCategories count] == 0) {
        [workingCategories release];
        return;
    } else if ([workingCategories count] == 1) {
        [self addAdvertisingBlockinPosY:0];
        [self addSOSCategory:[workingCategories objectAtIndex:0] inPosX:0 andPosY:1 forBlock:NB_BLOCKS];
        y = 2;
    } else {
        for (NSDictionary* category in workingCategories) {
            [self addSOSCategory:category inPosX:0 andPosY:[self.categories indexOfObject:category] forBlock:NB_BLOCKS];
        }
        y = [workingCategories count];
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
    float fitHeight =  ceilf((self.view.bounds.size.height - CATEGORIES_HEADER_SIZE - CATEGORIES_FOOTER_SIZE) / (y + 1.0f)); //XXX May i need to set a max-height to handle background image size

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
            
            // Add "NEW" image above the label
            NSDictionary* category = (NSDictionary*)objc_getAssociatedObject(subView, &sosMessageKey);
            
            if (category) {
                // Add env icon
                UIImage *envImg = [[UIImage imageNamed:@"sosm_top_bar_icon.png"] autorelease];
                UIImageView *envView = [[[UIImageView alloc] initWithImage:envImg] autorelease];
                int ratio = [AppDelegate isIPad] ? 1.3 : 2;
                CGFloat imgWidth = envView.frame.size.width / ratio;
                CGFloat imgHeight = envView.frame.size.height / ratio;
                
                envView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
                envView.center = CGPointMake(viewX + imgWidth * 0.8, viewY + viewHeight / 2);
                [self.view addSubview:envView];
                
                // Add New icon
                double epoch = [[category objectForKey:CATEGORY_LASTADD] doubleValue] / 1000;
                NSDate* categoryLastAdd = [NSDate dateWithTimeIntervalSince1970:epoch];
                if ([self.lastFetchingDate compare:categoryLastAdd] < 0) {
                    UIImage *img = [UIImage imageNamed:@"new_stamp.png"];
                    UIImageView* newImage = [[UIImageView alloc] initWithImage:img];
                    newImage.center = CGPointMake(viewX + 50, viewY + 10);
                    newImage.frame = subView.frame;
                    
                    [self.view addSubview:newImage];
                    [newImage release];
                }
            }
            
            // Add background image
            //NSString *imgName = category ? @"sosm_button_home.png" : @"sosm_button_home_empty.png";
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sosm_button_home_empty.png"]] autorelease];
            imageView.frame = subView.frame;
            imageView.backgroundColor = [AppDelegate buildUIColorFromARGBStringRepresentation:[category objectForKey:CATEGORY_COLOR]];
            [self.view insertSubview:imageView belowSubview:subView];
        } else if ([subView isKindOfClass:[UIImageView class]]) {
            UIImage* img = [(UIImageView*)subView image];
            float imgRation = img.size.height / img.size.width;
            subView.frame = CGRectMake(subView.frame.origin.x, floorf(subView.frame.origin.y * fitHeight), subView.frame.size.width, imgRation * subView.frame.size.width);
        }
    }
}

-(BOOL)isSubViewCategoryPart:(UIView*) view {
    return [view isKindOfClass:[UILabel class]] && view.tag == 0;
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
    
    SMMessageViewController* detail = [[SMMessageViewController alloc] initWithCategory:category messageHandlerSelector:sel];
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

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFail:(NSError *)error {
    self.refreshButton.hidden = false;
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)items
{
    self.refreshButton.hidden = true;
    
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


- (void)dealloc {
    [categories release];
    [refreshButton release];
    [announcements release];
    [messageHandler release];
    [infoButton release];
    [applicationName release];
    [_creditsLabel release];
    [super dealloc];
}
@end
