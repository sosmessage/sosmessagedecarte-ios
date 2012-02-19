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

- (int)deviceSpecificNumberOfBlocks;
- (UIFont*)deviceSpecificCategoryFont;
- (UIFont*)deviceSpecificMessageFont;
- (int)deviceSpecificCategoriesHeaderSize;
- (int)deviceSpecificCategoriesMarginHeight;
- (int)deviceSpecificCategoriesMarginWidth;

+ (UIColor*)buildUIColorFromARGBStringRepresentation:(NSString*)aString;
+ (BOOL)isIAdCompliant; 
+ (NSString*)applicationName;
+ (NSString*)applicationReadableName;

@end
