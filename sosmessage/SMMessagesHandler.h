//
//  SMMessagesHandler.h
//  sosmessage
//
//  Created by Arnaud K. on 14/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SOSMessageConstant.h"

@protocol SMMessageDelegate;

@interface SMMessagesHandler : NSObject

@property (assign) id <SMMessageDelegate,NSObject> delegate;
@property (assign) NSInteger lastStatusCode;

+ (SEL) selectorRequestMessageRandom;
+ (SEL) selectorRequestMessageBest;
+ (SEL) selectorRequestMessageWorst;

- (id)initWithDelegate:(id)delegate;
- (void)requestUrl:(NSString*)url;
- (void)requestPOSTUrl:(NSString*)url params:(NSDictionary*)params;

- (void)requestCategories;
- (void)requestAnnouncements;
- (void)requestVote:(NSInteger)vote messageId:(NSString*)messageId;
- (void)requestRandomMessageForCategory:(NSString*)aCategoryId;
- (void)requestWorstMessageForCategory:(NSString*)aCategoryId;
- (void)requestBestMessageForCategory:(NSString*)aCategoryId;
- (void)requestProposeMessage:(NSString*)aMessage author:(NSString*)anAuthor category:(NSString*)aCategoryId;

@end

@protocol SMMessageDelegate
@optional
- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)result;
- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinish:(id)data;

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFail:(NSError *)error;

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler;
- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler;


@end
