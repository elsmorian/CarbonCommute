//
//  CCLocationController.m
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLocationController.h"

@implementation CCLocationController
@synthesize manager = _manager;
@synthesize currentLocation = _currentLocation;
@synthesize delegate = _delegate;

- (id) init
{
  self = [super init];
  if (self) {
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    _loggedLocations = [[NSMutableArray alloc] init]; 
  }
  return self;
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
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self.delegate locationController:self newStatus:@"Left region"];
  NSLog(@"Did exit region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{  
  self.currentLocation = newLocation;
  [self.delegate locationController:self updatedLocation:newLocation];
}

@end
