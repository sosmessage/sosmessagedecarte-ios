//
//  SMDetailViewController.h
//  sosmessage
//
//  Created by Arnaud K. on 06/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "SOSMessageConstant.h"

@interface SMMessageViewController : UIViewController {
    ADInterstitialAd *interstitial;
}

@property (retain, nonatomic) IBOutlet UIView *backgroundView;
@property (retain, nonatomic) IBOutlet UITextView *messageText;
@property (retain, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (retain, nonatomic) IBOutlet UIButton *otherMessageButton;
@property (retain, nonatomic) IBOutlet UIButton *PreviousMessageButton;
@property (retain, nonatomic) IBOutlet UILabel *contributorLabel;

@property (retain, nonatomic) IBOutlet UIButton *votePlusButton;
@property (retain, nonatomic) IBOutlet UIButton *voteMinusButton;
@property (retain, nonatomic) IBOutlet UILabel *votePlusScoring;
@property (retain, nonatomic) IBOutlet UILabel *categoryName;
@property (retain, nonatomic) IBOutlet UILabel *shareBtnLabel;
@property (retain, nonatomic) IBOutlet UIButton *handlerMode;
@property (retain, nonatomic) IBOutlet UIButton *backButton;

- (id)initWithCategory:(NSDictionary*)aCategory;
- (id)initWithCategory:(NSDictionary *)aCategory messageHandlerSelector:(SEL)s;

- (IBAction)dismissButtonPressed:(id)sender;
- (void)refreshRenders;
- (IBAction)reloadButtonPressed:(id)sender;
- (IBAction)previousButtonPressed:(id)sender;
- (IBAction)sendMessagePressed:(id)sender;
- (IBAction)switchModePressed:(id)sender;

- (IBAction)voteButtonPressed:(id)sender;
@end
