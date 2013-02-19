//
//  CO2AppDelegate.h
//  CO2Commute
//
//  Created by Chris Elsmore on 19/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

@class  CCLocationController;

@interface CO2AppDelegate : UIResponder <UIApplicationDelegate> 
{
  CCLocationController *_locationController;
}

@property (strong, nonatomic) UIWindow *window;

- (CCLocationController *) getLocController;

@end
