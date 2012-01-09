//
//  UIButton+SOSMessage.h
//  sosmessage
//
//  Created by Arnaud K. on 08/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMessageConstant.h"

@interface UIButton (SOSMessage)
+(void)appendOverlaysWithHue:(float)aHue ToButton:(UIButton*)aButton;
@end
