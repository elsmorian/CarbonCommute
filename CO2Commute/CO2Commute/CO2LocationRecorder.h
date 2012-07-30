//
//  CO2LocationRecorder.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CO2LocationRecorder : NSObject <NSCoding>
{
  BOOL _activelyMeasuringLocation;
}

@property (nonatomic, readonly) NSMutableArray *loggedLocations;

- (void) notifyOfNewLocation:(CLLocation *)location;
- (void) startRecording;
- (void) stopRecording;

@end
