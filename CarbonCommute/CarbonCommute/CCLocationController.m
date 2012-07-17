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
  }
  return self;
}

- (void) registerHomeLocation:(CLLocation *)location
{
  CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate 
                                                             radius:10.
                                                         identifier:@"leavingHome"];
  NSLog(@"Got region");
  [self.manager startMonitoringForRegion:region desiredAccuracy:5.];
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
  NSLog(@"Did enter region");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self.delegate locationController:self newStatus:@"Left region"];
  NSLog(@"Did exit region");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{  
  self.currentLocation = newLocation;
  [self.delegate locationController:self updatedLocation:newLocation];
}

@end
