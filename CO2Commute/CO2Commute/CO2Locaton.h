//
//  CO2Locaton.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CO2Locaton : CLLocation

- (NSString *) toJSONString;
- (NSDictionary* ) toNSDictionary;

@end
