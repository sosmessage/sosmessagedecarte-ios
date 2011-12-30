//
//  UIColor+SOSMessage.m
//  sosmessage
//
//  Created by Arnaud K. on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+SOSMessage.h"

@implementation UIColor (SOSMessage)
-(float)hue {
    CGFloat hue;
    [self getHue:&hue saturation:nil brightness:nil alpha:nil];
    return hue;
}
@end
