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

#pragma mark -
#pragma mark Others

#define FONT_NAME           @"Helvetica"

#pragma mark CONSTANT
#define kTEXT_TOP           kcategories_top
#define kTEXT_FLOP          kcategories_flop
#define kDEFAULTS_ANOUNCES  @"kSoSAnnouncesRead"

#pragma mark -
#pragma mark Localizations

#define kmessage_propose             NSLocalizedString(@"message.propose", nil)
#define kmessage_propose_sending     NSLocalizedString(@"message.propose.sending", nil)
#define kmessage_share               NSLocalizedString(@"message.share", nil)
#define kmessage_share_unable_title  NSLocalizedString(@"message.share.unable.title", nil)
#define kmessage_share_unable        NSLocalizedString(@"message.share.unable", nil)

#define kcategories_all              NSLocalizedString(@"categories.all", nil)
#define kcategories_top              NSLocalizedString(@"categories.top", nil)
#define kcategories_flop             NSLocalizedString(@"categories.flop", nil)

#define klabel_about                 NSLocalizedString(@"label.about", nil)
#define klabel_loading               NSLocalizedString(@"label.loading", nil)
#define klabel_error_server          NSLocalizedString(@"label.error.server", nil)
#define klabel_btn_ok                NSLocalizedString(@"label.btn.ok", nil)
#define klabel_btn_ko                NSLocalizedString(@"label.btn.ok", nil)
#define klabel_btn_go                NSLocalizedString(@"label.btn.go", nil)
#define klabel_btn_cancel            NSLocalizedString(@"label.btn.cancel", nil)

#pragma mark DECLARE ASSOCIATIVE REFERENCE METHODS
typedef uintptr_t objc_AssociationPolicy;
void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
id objc_getAssociatedObject(id object, void *key);

@protocol SOSMessageConstant <NSObject>

@end
