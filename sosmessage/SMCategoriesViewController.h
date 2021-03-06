//
//  ViewController.h
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SOSMessageConstant.h"
#import <MessageUI/MessageUI.h>

@interface SMCategoriesViewController : UIViewController<SMMessageDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *infoButton;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;
@property (retain, nonatomic) IBOutlet UILabel *applicationName;
@property (retain, nonatomic) IBOutlet UILabel *creditsLabel;
@property (retain, nonatomic) IBOutlet UILabel *btnLanguage;

@property (retain, nonatomic) NSMutableArray* categories;
@property (retain, nonatomic) SMMessagesHandler* messageHandler;
@property (retain, nonatomic) NSMutableArray* announcements;

- (void)refreshCategories;
- (void)removeCategoriesLabel;

- (IBAction)aboutPressed:(id)sender;
- (IBAction)refreshPressed:(id)sender;
- (IBAction)changeLanguage:(id)sender;

@end
