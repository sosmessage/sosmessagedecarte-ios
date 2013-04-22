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

@end
