//
//  SOSMessageConstant.h
//  sosmessage
//
//  Created by Arnaud K. on 05/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark CATEGORIES

#import "NSString+SOSMessage.h"

#pragma mark HEADERS

#import "SMUrlBase.h"
#import "SMMessagesHandler.h"
#import "MBProgressHUD.h"

#import "AppDelegate.h"

#pragma mark CODE REPLACE

#define SOSFONT [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificSOSFont]
#define NB_BLOCKS [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificNumberOfBlocks]
#define CATEGORIES_HEADER_SIZE [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesHeaderSize]
#define CATEGORIES_MARGIN_WIDTH [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesMarginWidth]
#define CATEGORIES_MARGIN_HEIGTH [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesMarginHeight]

#pragma mark DICTIONNARY KEYS

#define CATEGORIES_COUNT    @"count"
#define CATEGORIES_ITEMS    @"items"

#define CATEGORY_ID         @"id"
#define CATEGORY_NAME       @"name"

#define MESSAGE_TEXT        @"text"

#pragma mark Others

#define FONT_NAME           @"Helvetica"

@protocol SOSMessageConstant <NSObject>

@end
