//
//  AppDelegate.m
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "SMCategoriesViewController.h"
#import "AdBannerNavigationController.h"

@implementation AppDelegate

@synthesize window = _window, refreshCategories;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    SMCategoriesViewController *categories = [[[SMCategoriesViewController alloc] initWithNibName:@"SMCategoriesViewController" bundle:nil] autorelease];
    UINavigationController *nav;
    if ([AppDelegate isIAdCompliant]) {
        NSLog(@"With iAd");
        nav = [[[AdBannerNavigationController alloc] initWithRootViewController:categories] autorelease];
    } else {
        NSLog(@"Without iAd");
        nav = [[[UINavigationController alloc] initWithRootViewController:categories] autorelease];
    }
    nav.navigationBarHidden = YES;
    nav.delegate = categories;
    
    self.window.rootViewController = nav;
    self.refreshCategories = NO;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.refreshCategories = YES;
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark Custom methods

- (int)deviceSpecificCategoriesMarginHeight {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 7;
    }
    else {
        return 16;
    }
}

- (int)deviceSpecificCategoriesMarginWidth {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 10;
    }
    else {
        return 15;
    }
}

- (int)deviceSpecificCategoriesHeaderSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 70;
    }
    else {
        return 150;
    }
}

- (int)deviceSpecificNumberOfBlocks {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            return 5;
        } else {
            return 7;
        }
    } else {
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            return 7;
        } else {
            return 10;
        }
    }
}

-(void)logAvaiableFonts {
    for (NSString* familyName in [UIFont familyNames]) {
        for (NSString* fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"Available font: %@", fontName);
        }
    }
}

- (UIFont *)deviceSpecificMessageFont {
    int fontSize = 28;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        fontSize = 16;
    }
    return [UIFont fontWithName:@"Georgia" size:fontSize];
}

- (UIFont *)deviceSpecificCategoryFont {
    int fontSize = 30;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        fontSize = 22;
    }
    return [UIFont fontWithName:@"Georgia" size:fontSize];
}

+ (BOOL)isInsterstitialAdCompliant {
    return [AppDelegate isIAdCompliant] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+(BOOL)isIAdCompliant {
    return [AppDelegate applicationName] ? YES : NO;
}

+(NSString *)applicationName {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"SMAppName"];
}

+ (NSString*)applicationReadableName {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"SMAppReadableName"];
}

+ (UIColor*)buildUIColorFromARGBStringRepresentation:(NSString*)aString {
    return [AppDelegate buildUIColorFromARGBStringRepresentation:aString plusRed:0 plusGreen:0 plusBlue:0];
}

+ (UIColor*)buildUIColorFromARGBStringRepresentation:(NSString*)aString plusRed:(float)pRed plusGreen:(float)pGreen plusBlue:(float)pBlue {
    if ([aString length] != 9) {
        NSLog(@"Unable to calculate color from: %@", aString);
        return nil;
    }
    
    unsigned int alpha;
    unsigned int red;
    unsigned int blue;
    unsigned int green;
    
    [[NSScanner scannerWithString:[aString substringWithRange:NSMakeRange(1, 2)]] scanHexInt:&alpha];
    [[NSScanner scannerWithString:[aString substringWithRange:NSMakeRange(3, 2)]] scanHexInt:&red];
    [[NSScanner scannerWithString:[aString substringWithRange:NSMakeRange(5, 2)]] scanHexInt:&green];
    [[NSScanner scannerWithString:[aString substringWithRange:NSMakeRange(7, 2)]] scanHexInt:&blue];
    
    red = red + (red * pRed);
    blue = blue + (blue * pBlue);
    green = green + (green * pGreen);
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];    
}

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
