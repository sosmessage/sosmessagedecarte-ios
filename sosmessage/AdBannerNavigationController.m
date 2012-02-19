//
//  PositionNavigationController.m
//  iPositionHolder
//
//  Created by Arnaud K. on 25/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdBannerNavigationController.h"
#import "SMCategoriesViewController.h"

#define BANNER_HEIGHT 50

@interface AdBannerNavigationController ()
-(void)refreshCategories;
@end

@implementation AdBannerNavigationController

@synthesize bannerVisible = _bannerVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Custom method

- (void)tearDownBanner:(ADBannerView *)banner {
    CGRect selfFrame = self.view.frame;
    [UIView animateWithDuration:0.4
                     animations:^{    
                         banner.frame = CGRectMake(0, selfFrame.size.height, selfFrame.size.width, 0);
                         UIView *content = [self.view.subviews objectAtIndex:0];
                         content.frame = CGRectMake(selfFrame.origin.x, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self refreshCategories];
                         self.bannerVisible = NO; 
                     }
     ];
}

- (void)tearUpBanner:(ADBannerView *)banner {
    CGRect selfFrame = self.view.frame;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         banner.frame = CGRectMake(0, selfFrame.size.height - BANNER_HEIGHT, selfFrame.size.width, BANNER_HEIGHT);
                         UIView *content = [self.view.subviews objectAtIndex:0];
                         content.frame = CGRectMake(selfFrame.origin.x, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height - BANNER_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         [self refreshCategories];
                         self.bannerVisible = YES;
                     }
     ];
}

#pragma mark - Categories refresh

-(void)refreshCategories {
    if (self.topViewController == self.visibleViewController) {
        SMCategoriesViewController *categories = (SMCategoriesViewController *)self.topViewController;
        [categories refreshCategories];
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication* app = [UIApplication sharedApplication];
    app.idleTimerDisabled = TRUE;
    //NSLog(@"Position Navigation Controller will appear.");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIApplication* app = [UIApplication sharedApplication];
    app.idleTimerDisabled = FALSE;    
    //NSLog(@"Position Navigation Controller will disappear.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    ADBannerView *bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    bannerView.delegate = self;
    bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    self.bannerVisible = NO;
    [self.view addSubview:bannerView];
    [self tearDownBanner:bannerView];
    [bannerView release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ADBannerView delegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (self.bannerVisible) {
        //NSLog(@"Hide banner ...");
        [self tearDownBanner:banner];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!self.bannerVisible) {
        //NSLog(@"Display banner ...");
        [self tearUpBanner:banner];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}


@end
