//
//  NSString+SOSMessage.m
//  sosmessage
//
//  Created by Arnaud K. on 05/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+SOSMessage.h"
#define HUE_COLORS 24

@implementation NSString (SOSMessage)
float sizeInBlocks;

-(float)blocksCount:(UIView*)view {
    float widthWithFont = [self sizeWithFont:CATEGORY_FONT].width + 20.0;
    //NSLog(@"Width with font for %@ : %.2f", self, widthWithFont);
    float blockSize = view.bounds.size.width / NB_BLOCKS;
    //NSLog(@"Frame width: %.2f and a block: %.2f", view.frame.size.width, blockSize);
    return ceilf(widthWithFont / blockSize);    
}

-(float)calculateHue {
    int hueFromString = self.length;
    for (int i = 0; i < self.length; i++) {
        hueFromString += [self characterAtIndex:i];
    }
    float calcultedHue = (hueFromString % HUE_COLORS / (HUE_COLORS * 1.0f)) * 0.58f + 0.21f;
    //NSLog(@"For '%@' hue: %.2f", self, calcultedHue);
    return calcultedHue;
}

-(NSString *)prepositionWithSpace {
    NSString* prep = self.preposition;
    return [prep characterAtIndex:1] == '\'' ? prep : [NSString stringWithFormat:@"%@ ", prep];
}

-(NSString*)preposition {
    NSCharacterSet* letters = [NSCharacterSet characterSetWithCharactersInString:@"aeiouh"];
    return [letters characterIsMember:[[self lowercaseString] characterAtIndex:0]] ? @"d'" : @"de";
}
@end
