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
#import "UIColor+SOSMessage.h"
#import "UIButton+SOSMessage.h"

#pragma mark HEADERS

#import "SMUrlBase.h"
#import "SMMessagesHandler.h"
#import "MBProgressHUD.h"
#import "SMProposeNewMessageController.h"

#import "AppDelegate.h"

#pragma mark CODE REPLACE

#define CATEGORY_FONT [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoryFont]
#define MESSAGE_FONT [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificMessageFont]
#define NB_BLOCKS [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificNumberOfBlocks]
#define CATEGORIES_HEADER_SIZE [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesHeaderSize]
#define CATEGORIES_MARGIN_WIDTH [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesMarginWidth]
#define CATEGORIES_MARGIN_HEIGTH [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceSpecificCategoriesMarginHeight]

#pragma mark DICTIONNARY KEYS

#define JSON_RESPONSE       @"response"
#define JSON_META           @"meta"

#define META_CODE           @"code"
#define META_ERROR_TYPE     @"errorType"
#define META_ERROR_DETAILS  @"errorDetails"

#define CATEGORIES_COUNT    @"count"
#define CATEGORIES_ITEMS    @"items"

#define CATEGORY_ID         @"id"
#define CATEGORY_NAME       @"name"
#define CATEGORY_COLOR      @"color"
#define CATEGORY_LASTADD    @"lastAddedMessageAt"

#define MESSAGE_ID          @"id"
#define MESSAGE_TEXT        @"text"
#define MESSAGE_CONTRIBUTOR @"contributorName"
#define MESSAGE_RATING      @"rating"
#define RATING_VALUE        @"value"
#define MESSAGE_VOTE        @"vote"
#define VOTE_USERVOTE       @"userVote"
#define VOTE_PLUS           @"plus"
#define VOTE_MINUS          @"minus"

#define kSOSUUID            @"sosmessage.uuid.key"
#define kSOSLASTFETCH       @"sosmessage.categories.fetchDate"

#pragma mark Others

#define FONT_NAME           @"Helvetica"

#pragma mark CONSTANT
#define kTEXT_TOP           @"TOP"
#define kTEXT_FLOP          @"FLOP"

#pragma mark DECLARE ASSOCIATIVE REFERENCE METHODS
typedef uintptr_t objc_AssociationPolicy;
void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
id objc_getAssociatedObject(id object, void *key);

@protocol SOSMessageConstant <NSObject>

@end
