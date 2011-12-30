//
//  NSString+SOSMessage.h
//  sosmessage
//
//  Created by Arnaud K. on 05/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SOSMessageConstant.h"

@interface NSString (SOSMessage) {

}

@property (readonly) float calculateHue;
@property (readonly) NSString* prepositionWithSpace;
@property (readonly) NSString* preposition;

-(float)blocksCount:(UIView*)view;

@end
