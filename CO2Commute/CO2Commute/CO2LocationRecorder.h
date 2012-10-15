//
//  CO2LocationRecorder.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern int const GPSINTERVAL;
extern int const MINGPSACCURACY;

@interface CO2LocationRecorder : NSObject <NSCoding>
{
  BOOL _activelyMeasuringLocation;
}

@property (nonatomic, readonly) NSMutableArray *loggedLocations;

///////////
#pragma mark - Core methods

- (void) notifyOfNewLocation:(CLLocation *)newLocation;
- (void) startRecording;
- (void) stopRecording;

///////////
#pragma mark - Commute Management

- (void) createNewCommute;
- (void) addLocationToCurrentCommute:(CLLocation *)newLocation;
- (void) endCurrentCommute;

///////////
#pragma mark - Commute Location Interfaces
- (NSDictionary *) getCurrentCommuteStats;
- (void) currentCommuteReplaceLastLocation:(CLLocation *)newLocation;
- (CLLocation *) getCurrentCommuteLastLocation;
- (NSArray *) getCurrentCommuteLocations;
- (void) removeCurrentCommuteLastLocation;
- (void) removeCurrentCommute;
- (BOOL) currentCommuteHasLocations;
- (int) countCommutes;
- (int) countCurrentCommuteLocations;
- (int) countAllLocations;
- (NSArray *) getCommutes;

@end
