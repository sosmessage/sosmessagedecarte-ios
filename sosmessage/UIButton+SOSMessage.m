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
-(void)appendOverlaysWithHue:(float)aHue {
    self.alpha = 0.7f;
    
    //A simple view to make a great effect inside the button
    UIView* buttonOverlay = [[UIView alloc] initWithFrame:self.frame];
    buttonOverlay.backgroundColor = [UIColor colorWithHue:aHue saturation:0.8 brightness:0.3 alpha:0.3];
    buttonOverlay.userInteractionEnabled = false;
    
    buttonOverlay.layer.cornerRadius = 8.0f;
    buttonOverlay.layer.masksToBounds = YES;
    
    buttonOverlay.autoresizingMask = self.autoresizingMask;
    
    //[self.superview insertSubview:buttonOverlay aboveSubview:self];
//    [self.superview insertSubview:buttonOverlay belowSubview:self];
    
    [buttonOverlay release];    
}

+(void)overlayView {
}

+(void)overlayLabel {
}
@end
