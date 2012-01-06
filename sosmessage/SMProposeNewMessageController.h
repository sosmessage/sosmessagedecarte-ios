//
//  SMProposeNewMessageController.h
//  sosmessage
//
//  Created by Arnaud K. on 05/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMessageConstant.h"

@interface SMProposeNewMessageController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign) NSMutableArray* categories;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *categoryTextField;
@property (retain, nonatomic) IBOutlet UITextView *messageTextView;
@property (retain, nonatomic) IBOutlet UIPickerView *categoryPicker;

- (IBAction)selectCategory:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)cancelPushed:(id)sender;
- (IBAction)sendPushed:(id)sender;
- (IBAction)showPicker:(id)sender;

@end
