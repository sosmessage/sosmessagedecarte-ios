//
//  SMDetailViewController.h
//  sosmessage
//
//  Created by Arnaud K. on 06/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMessageConstant.h"

@interface SMMessageViewController : UIViewController {
    
}

@property (retain, nonatomic) IBOutlet UIView *backgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *titleImage;
@property (retain, nonatomic) IBOutlet UITextView *messageText;
@property (retain, nonatomic) IBOutlet UIButton *otherMessageButton;
@property (retain, nonatomic) IBOutlet UILabel *contributorLabel;

@property (retain, nonatomic) IBOutlet UIButton *votePlusButton;
@property (retain, nonatomic) IBOutlet UIButton *voteMinusButton;
@property (retain, nonatomic) IBOutlet UILabel *votePlusScoring;
@property (retain, nonatomic) IBOutlet UILabel *voteMinusScoring;

- (id)initWithCategory:(NSDictionary*)aCategory;
- (IBAction)dismissButtonPressed:(id)sender;
- (void)fetchAMessage;
- (void)renderTitle;
- (void)refreshRenders;
- (IBAction)reloadButtonPressed:(id)sender;

- (IBAction)voteButtonPressed:(id)sender;

@end
