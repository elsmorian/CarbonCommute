//
//  CCLocationController.m
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLocationController.h"
#import "CO2LocationRecorder.h"

@implementation CCLocationController
@synthesize manager = _manager;
@synthesize currentLocation = _currentLocation;
@synthesize delegate = _delegate;
@synthesize recorder = _recorder;


//////////////
#pragma mark - Init and termiante

- (id) init
{
  self = [super init];
  if (self) {
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    [self loadLocationRecorder];
  }
  return self;
}

- (void) terminateNicely 
{
  [self saveLocationRecorder];
}


//////////////
#pragma mark - Saving and restoring location recorder

- (NSString *) locationRecorderFilePath 
{
  //NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"locationRecorder.co2"];
  //NSFileManager *filemgr = [NSFileManager defaultManager];
  NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docsDir = [dirPaths objectAtIndex:0];
  NSString *dataFilePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"loggedLocations.co2"]];

  return dataFilePath;
}

- (void) loadLocationRecorder
{
  NSString *filePath = [self locationRecorderFilePath];
  _recorder = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  if (_recorder == Nil) {
    _recorder = [[CO2LocationRecorder alloc] init];
  }  
}

- (void) saveLocationRecorder
{
  NSString *filePath = [self locationRecorderFilePath];
  NSLog(@"filePath: %@", filePath);
  NSLog(@"Archiver: %i", [NSKeyedArchiver archiveRootObject:self.recorder toFile:filePath]);
}

- (void) registerHomeLocation
{
  //CLLocation *location = self.currentLocation;
  NSLog(@"Got region (%f,%f)", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
  CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.currentLocation.coordinate 
                                                             radius:10.
                                                         identifier:@"home"];
  NSLog(@"Got region");
  [self.manager startMonitoringForRegion:region desiredAccuracy:5.];
  NSLog(@"Started Mon");
}


///////////
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  NSLog(@"Did start monitoring for region: '%@'", region.identifier);
  [self.delegate locationController:self newStatus:@"-------------------------"];
  [self.delegate locationController:self newStatus:@"Started monitoring region"];
  [self.delegate locationController:self newStatus:@"Good luck"];
  [self.delegate locationController:self newStatus:@"-------------------------"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  [self.delegate locationController:self newStatus:@"Entered region"];
  NSLog(@"Did enter region '%@'", region.identifier);
  [self stopRecording];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self.delegate locationController:self newStatus:@"Left region"];
  [self startRecording];
  NSLog(@"Did exit region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{  
  self.currentLocation = newLocation;
  [self.delegate locationController:self updatedLocation:newLocation];
  
  [self.recorder notifyOfNewLocation:newLocation];
}

- (void) startRecording
{
  [self.recorder startRecording];
  [self.manager startUpdatingLocation];
  self.manager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void) stopRecording
{
  [self.recorder stopRecording];
  [self.manager stopUpdatingLocation];
}

- (void) uploadData
{
  //NSArray *loggedLocations = self.recorder.loggedLocations;
  // TODO: Now upload the locations...
}


// FIXME: Remove these nasty methods. Only for testing purposes.
- (void) startTracking
{
  [self startRecording];
}

- (void) stopTracking
{
  [self stopRecording];
}

@end
