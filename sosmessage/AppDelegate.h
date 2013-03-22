//
//  AppDelegate.h
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMCategoriesViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL refreshCategories;

- (int)deviceSpecificNumberOfBlocks;
- (UIFont*)deviceSpecificCategoryFont;
- (UIFont*)deviceSpecificMessageFont;
- (UIFont*)deviceSpecificBarsFont;
- (int)deviceSpecificCategoriesHeaderSize;
- (int)deviceSpecificCategoriesFooterSize;
- (int)deviceSpecificCategoriesMarginHeight;
- (int)deviceSpecificCategoriesMarginWidth;

+ (AppDelegate *)sharedDelegate;
+ (void)logAvaiableFonts;
+ (UIColor*)buildUIColorFromARGBStringRepresentation:(NSString*)aString;
+ (UIColor*)buildUIColorFromARGBStringRepresentation:(NSString*)aString plusRed:(float)pRed plusGreen:(float)pGreen plusBlue:(float)pBlue;
+ (BOOL)isIPad;
+ (BOOL)isIAdCompliant; 
+ (BOOL)isInsterstitialAdCompliant;
+ (NSString*)applicationName;
+ (NSString*)applicationReadableName;

@end
