//
//  CO2LocationRecorder.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2LocationRecorder.h"

@implementation CO2LocationRecorder

@synthesize loggedLocations = _loggedLocations;

///////////
#pragma mark - Init

- (id) init 
{
  self = [super init];
  if (self) {
    _loggedLocations = [[NSMutableArray alloc] init];
    _activelyMeasuringLocation = NO;
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
  self = [self init];
  if (self) {
    NSMutableArray *loadedLoggedLocations = [coder decodeObjectForKey:@"loggedLocations"];
    if (loadedLoggedLocations != Nil) 
      _loggedLocations = loadedLoggedLocations;
    NSLog(@"Instantiated recorder with %i location records",[_loggedLocations count]);
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_loggedLocations forKey:@"loggedLocations"];
}


///////////
#pragma mark - Core methods

- (void) notifyOfNewLocation:(CLLocation *)location
{
  if (_activelyMeasuringLocation) {
    [_loggedLocations addObject:location];
  }
}

- (void) startRecording
{
  _activelyMeasuringLocation = YES;
}

- (void) stopRecording
{
  _activelyMeasuringLocation = NO;
}

@end
