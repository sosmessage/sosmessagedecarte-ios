//
//  PositionNavigationController.h
//  iPositionHolder
//
//  Created by Arnaud K. on 25/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AdBannerNavigationController : UINavigationController <ADBannerViewDelegate> {
@private
    BOOL _bannerVisible;
}
@property(nonatomic) BOOL bannerVisible;
@end
