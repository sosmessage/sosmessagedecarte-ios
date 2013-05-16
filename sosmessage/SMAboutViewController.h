//
//  SMAboutViewController.h
//  sosmessage
//
//  Created by Arnaud K. on 26/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMessageConstant.h"
#import <MessageUI/MessageUI.h>

@interface SMAboutViewController : UIViewController

- (IBAction)backPressed:(id)sender;
- (IBAction)otherAppsPressed:(id)sender;

- (IBAction)mailPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)liseTwitterPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UITextView *ourMessage;
@property (retain, nonatomic) IBOutlet UILabel *lblAbout;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnOtherApp;

@property (retain, nonatomic) IBOutlet UILabel *lblAketomic;
@property (retain, nonatomic) IBOutlet UIButton *btnAketomic;
@property (retain, nonatomic) IBOutlet UILabel *lblLkemen;
@property (retain, nonatomic) IBOutlet UIButton *btnLkemen;

@end
