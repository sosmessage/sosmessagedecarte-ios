//
//  UIButton+SOSMessage.m
//  sosmessage
//
//  Created by Arnaud K. on 08/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButton+SOSMessage.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (SOSMessage)
+(void)appendOverlaysWithHue:(float)aHue ToButton:(UIButton*)aButton {
    //A simple view to make a great effect inside the button
    UIView* buttonOverlay = [[UIView alloc] initWithFrame:aButton.frame];
    buttonOverlay.backgroundColor = [UIColor colorWithHue:aHue saturation:0.8 brightness:0.3 alpha:0.7];
    buttonOverlay.userInteractionEnabled = false;
    buttonOverlay.layer.cornerRadius = 10.0f;
    buttonOverlay.layer.masksToBounds = YES;
    buttonOverlay.autoresizingMask = aButton.autoresizingMask;
    [aButton.superview insertSubview:buttonOverlay aboveSubview:aButton];
    
    //Move button title to the label inside the simple view
    UILabel* buttonLabel = [[UILabel alloc] initWithFrame:aButton.frame];
    //Move button Title text to the overlayed label
    buttonLabel.text = aButton.currentTitle;
    [aButton setTitle:@"" forState:UIControlStateNormal];
    
    buttonLabel.numberOfLines = 2;
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textColor = [UIColor whiteColor];
    buttonLabel.font = [UIFont fontWithName:FONT_NAME size:15];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    buttonLabel.userInteractionEnabled = FALSE;
    buttonLabel.autoresizingMask = aButton.autoresizingMask;
    [aButton.superview insertSubview:buttonLabel aboveSubview:buttonOverlay];
    
    [buttonLabel release];
    [buttonOverlay release];
}
@end
