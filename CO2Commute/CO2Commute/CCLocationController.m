//
//  CCLocationController.m
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLocationController.h"
#import "CO2LocationRecorder.h"
#import "CO2Locaton.h"

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

- (void) setUp{
    TFLog(@"Setting up app...");
    TFLog(@"Location AuthorizationS tatus: %@", CLLocationManager.authorizationStatus ? @"YES" : @"NO");
    TFLog(@"Location Services Enabled: %@", CLLocationManager.locationServicesEnabled ? @"YES" : @"NO");
    TFLog(@"Region Monitoring Avalible: %@", CLLocationManager.regionMonitoringAvailable ? @"YES" : @"NO");
    TFLog(@"Region Monitoring Enabled: %@", CLLocationManager.regionMonitoringEnabled? @"YES" : @"NO");
    
    [self.delegate newStatus:@"Starting..."];
    [self.delegate newStatus:[NSString stringWithFormat:@"Location Authorization Status: %@", CLLocationManager.authorizationStatus ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Location Services Enabled: %@", CLLocationManager.locationServicesEnabled ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Region Monitoring Avalible: %@", CLLocationManager.regionMonitoringAvailable ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Region Monitoring Enabled: %@", CLLocationManager.regionMonitoringEnabled? @"YES" : @"NO"]];

    [self setUpRegionMonitoring];
    
    TFLog(@"Set up completed at: %@",[NSDate date]);
    [self.delegate newStatus:[NSString stringWithFormat:@"Set up completed at: %@",[NSDate date]]];
}

- (void) setUpRegionMonitoring {
    NSLog(@"Setting up region monitoring");
    
    //reset all region monitoring
    for (CLRegion *region in [_manager monitoredRegions]) {
        [self.manager stopMonitoringForRegion:region];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if home or work are missing, don't start monitoring. If they are there, do start monitoring!
    if (![defaults objectForKey:@"home lat"] || ![defaults objectForKey:@"work lat"]){
        TFLog(@"Not setting geofences: Home Lat/Lng: %@,%@, Work Lat/Lng: %@,%@.",
              [defaults objectForKey:@"home lat"] ? @"YES" : @"NO", [defaults objectForKey:@"home lng"] ? @"YES" : @"NO",
              [defaults objectForKey:@"work lat"] ? @"YES" : @"NO", [defaults objectForKey:@"work lng"] ? @"YES" : @"NO");
        [self.delegate newStatus:[NSString stringWithFormat:@"Home or work not set, not setting up geofences"]];
    }
    else {
        CLLocationCoordinate2D home = CLLocationCoordinate2DMake([[defaults valueForKey:@"home lat"] doubleValue], [[defaults valueForKey:@"home lng"] doubleValue]);
        CLLocationCoordinate2D work = CLLocationCoordinate2DMake([[defaults valueForKey:@"work lat"] doubleValue], [[defaults valueForKey:@"work lng"] doubleValue]);
        CLRegion *homeRegion = [[CLRegion alloc] initCircularRegionWithCenter:home radius:15.0 identifier:@"home"];
        CLRegion *workRegion = [[CLRegion alloc] initCircularRegionWithCenter:work radius:15.0 identifier:@"work"];
        [self.manager startMonitoringForRegion:homeRegion desiredAccuracy:5.0];
        [self.manager startMonitoringForRegion:workRegion desiredAccuracy:5.0];
    }
    TFLog(@"Monitored regions: %@", [_manager monitoredRegions]);
    [self.delegate newStatus:[NSString stringWithFormat:@"Monitored regions: %@", [_manager monitoredRegions]]];
}


//////////////
#pragma mark - Saving and restoring location recorder

- (NSString *) locationRecorderFilePath 
{
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


//////////////
#pragma mark - Registering locations and recording intentions

- (void) registerHomeLocation
{
  NSLog(@"Got region (%f,%f)", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
  CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.currentLocation.coordinate 
                                                             radius:10.
                                                         identifier:@"home"];
  NSLog(@"Got region");
  [self.manager startMonitoringForRegion:region desiredAccuracy:5.];
  NSLog(@"Started Mon");
}

- (void) startRecording
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [self.delegate newStatus:[NSString stringWithFormat:@"Started rec at: %@",[NSDate date]]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Battery at: %f",device.batteryLevel]];
    TFLog(@"Battery Level at: %f",device.batteryLevel);
    NSLog(@"Started recording at: %@",[NSDate date]);
    device.batteryMonitoringEnabled = NO;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //self.manager.distanceFilter = ;
    [self.recorder startRecording];
    [self.manager startUpdatingLocation];
}

- (void) stopRecording
{
    [self.manager stopUpdatingLocation];
    [self.recorder stopRecording];
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [self.delegate newStatus:[NSString stringWithFormat:@"Stopped rec at: %@",[NSDate date]]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Battery at: %f",device.batteryLevel]];
    TFLog(@"Stopped recording at: %@",[NSDate date]);
    TFLog(@"Battery Level at: %f",device.batteryLevel);
    device.batteryMonitoringEnabled = NO;
    NSLog(@"Stats: %@",[self.recorder getCurrentCommuteStats]);
}


//////////////
#pragma mark - Uploading data

- (void) uploadData
{
    //Upload data should not try and upload if no username / password exsist, and notify user.
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //else:
    NSArray *locs = self.recorder.loggedLocations;
    //NSMutableArray *JSONCommute = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSArray *commute in locs){
        NSLog(@"%i",index);
        NSLog(@"%@",commute[0]);
        index++;
    }
    
//    index = 0;
//    for (NSArray *commute in locs){
//    for (id obj in commute) {
//        if (index == 0){
//            NSDictionary *stats = obj;
//            NSDate *start = [stats objectForKey:@"start"];
//            NSDate *end = [stats objectForKey:@"end"];
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                 [stats objectForKey:@"status"], @"status",
//                                                 [stats objectForKey:@"mean speed"], @"mean speed",
//                                                 [stats objectForKey:@"modal speed"], @"modal speed",
//                                                 [stats objectForKey:@"median speed"], @"median speed",
//                                                 [stats objectForKey:@"max speed"], @"max speed",
//                                                 [stats objectForKey:@"min speed"], @"min speed",
//                                                 start.timeIntervalSince1970, @"start",
//                                                 end.timeIntervalSince1970, @"end",
//                                                 [stats objectForKey:@"locations"], @"locations", nil];
//            [JSONCommute addObject:dict];
//        }
//        else{
//            CLLocation *loc = obj;
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [[NSNumber alloc] initWithDouble:loc.coordinate.latitude], @"latitude",
//                                  [[NSNumber alloc] initWithDouble:loc.coordinate.longitude], @"longitude",
//                                  [[NSNumber alloc] initWithDouble:loc.horizontalAccuracy], @"horizontalAccuracy",
//                                  [[NSNumber alloc] initWithDouble:loc.speed], @"speed",
//                                  [[NSNumber alloc] initWithDouble:loc.course], @"course",
//                                  [[NSNumber alloc] initWithDouble:loc.altitude], @"altitude",
//                                  [[NSNumber alloc] initWithDouble:loc.verticalAccuracy], @"verticalAccuracy",
//                                  [[NSNumber alloc] initWithInt: loc.timestamp.timeIntervalSince1970 ], @"id", nil];
//            [JSONCommute addObject:dict];
//        }
//        index++;
//    }
//    }
//
//    NSError *error;
//    NSString *jsonStr;
//    
//    for (NSDictionary *dict in JSONCommute) {
//        //Add each object togeth in an array in a String
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",jsonStr);
//    }

    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSONCommute options:0 error:&error];
//    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(jsonStr);
    //[self uploadNextData];
}

- (void) uploadNextData
{
    NSLog(@"UPLOAD");
    
    NSMutableArray *locs = self.recorder.loggedLocations;
    NSMutableString *postStr = [NSMutableString stringWithFormat:@"{\"data\":["];
    
    int limit = 1;
    for(int it=0;it<limit;it++) {
        
        if ([locs count] < 1) {
            break;
        }
        CLLocation *loc = locs[[locs count]-1];
        [locs removeLastObject];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [[NSNumber alloc] initWithDouble:loc.coordinate.latitude], @"latitude",
                [[NSNumber alloc] initWithDouble:loc.coordinate.longitude], @"longitude",
                [[NSNumber alloc] initWithDouble:loc.horizontalAccuracy], @"horizontalAccuracy",
                [[NSNumber alloc] initWithDouble:loc.speed], @"speed",
                [[NSNumber alloc] initWithDouble:loc.course], @"course",
                [[NSNumber alloc] initWithDouble:loc.altitude], @"altitude",
                [[NSNumber alloc] initWithDouble:loc.verticalAccuracy], @"verticalAccuracy",
                [[NSNumber alloc] initWithInt: loc.timestamp.timeIntervalSince1970 ], @"id", nil];
        
        NSError *error;
        NSString *jsonStr;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        
        if (! jsonData) {
            [self.delegate newStatus:[NSString stringWithFormat:@"Got an error: %@", error]];
        } else {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        if (it == limit-1){
            [postStr appendString:jsonStr];
        } else {
            [postStr appendString:[NSString stringWithFormat:@"%@,",jsonStr]];
        }
    }
    
        
        [postStr appendString:@"]}"];

        NSLog(@"%@",postStr);
        
        NSURL *url = [NSURL URLWithString:@"http://db1.locker.cam.ac.uk/push/test1"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[NSData dataWithBytes:[postStr UTF8String] length:[postStr length]]];
    
        [NSURLConnection connectionWithRequest:request delegate:self];
}


//- (void) uploadData
//{
//    [self.delegate newStatus:[NSString stringWithFormat:@"Uploading..."]];
//    int limit = 1;
//    //while ([self.recorder hasLocations]) {
//    NSMutableString *postStr = [NSMutableString stringWithFormat:@"{\"data\":["];
//    for(int it=0;it<limit;it++) {
//        //it++;
//        //NSLog(@"sending a loc: %i",it);
//        CLLocation *loc = [self.recorder getLastLocation];
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [[NSNumber alloc] initWithDouble:loc.coordinate.latitude], @"latitude",
//                              [[NSNumber alloc] initWithDouble:loc.coordinate.longitude], @"longitude",
//                              [[NSNumber alloc] initWithDouble:loc.horizontalAccuracy], @"horizontalAccuracy",
//                              [[NSNumber alloc] initWithDouble:loc.speed], @"speed",
//                              [[NSNumber alloc] initWithDouble:loc.course], @"course",
//                              [[NSNumber alloc] initWithDouble:loc.altitude], @"altitude",
//                              [[NSNumber alloc] initWithDouble:loc.verticalAccuracy], @"verticalAccuracy",
//                              //[[NSDate alloc]loc.timestamp, @"timestamp",
//                              [[NSNumber alloc] initWithInt: loc.timestamp.timeIntervalSince1970 ], @"id", nil];
//                              //[NSString stringWithFormat:@"2"], @"id", nil];
//        NSError *error;
//        NSString *jsonStr;
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
//                                                           options:0// NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                             error:&error];
//        if (! jsonData) {
//            [self.delegate newStatus:[NSString stringWithFormat:@"Got an error: %@", error]];
//        } else {
//            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
//        if (it == limit-1){
//            [postStr appendString:jsonStr];
//        } else {
//            [postStr appendString:[NSString stringWithFormat:@"%@,",jsonStr]];
//        }
//    }
//    
//    [postStr appendString:@"]}"];
//    
//    NSURL *url = [NSURL URLWithString:@"http://db1.locker.cam.ac.uk/push/test1"];
//            
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[NSData dataWithBytes:[postStr UTF8String] length:[postStr length]]];
//    
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    
//    [self.delegate newStatus:[NSString stringWithFormat:@"Sent!"]];
//    
//    for(int it=0;it<limit;it++) {
//        //NSLog(@"removed");
//        [self.recorder removeLastLocation];
//    }
//    [self.delegate newStatus:[NSString stringWithFormat:@"All Done!"]];
//    
//    NSLog(@"==============All sent!===========");
//    [self saveLocationRecorder];
//
//}


// FIXME: Remove these nasty methods. Only for testing purposes.
- (void) startTracking
{
    [self startRecording];
}

- (void) stopTracking
{
    [self stopRecording];
}


///////////
#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"CONN: Auth Sent!");
    NSString *username = @"user1";
    NSString *password = @"user1";
    
    NSURLCredential *credential = [NSURLCredential
                                   credentialWithUser:username
                                   password:password
                                   persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[self.data setLength:0];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    [self.delegate newStatus:[NSString stringWithFormat:@"CONN: HTTP Code: %i",[httpResponse statusCode]]];
    //NSLog(@"CONN: HTTP Code: %i",[httpResponse statusCode]);
    //NSDictionary *dic = [httpResponse allHeaderFields];
    //NSLog(@"CONN: Rx Response");
    //for (id key in dic) {
    //
    //    NSLog(@"key: %@, value: %@", key, [dic objectForKey:key]);
    //
    //}
    NSMutableArray *locs = self.recorder.loggedLocations;
    if ([locs count] > 0 && [httpResponse statusCode] == 200) {
        NSLog(@"OK, %i more To Come!",[locs count]);
        //[self saveLocationRecorder];
        //[self uploadNextData];
    }
    if ([locs count] == 0){
        [self saveLocationRecorder];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    //[self.data appendData:d];
    NSString *strData = [[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];
    //NSString *okays = [[NSString alloc] initWithFormat:@"ok"];
    if ([strData isEqualToString:@"ok"]) {
        NSLog(@"OKES!");
        [self uploadNextData];
    }
    //NSLog(@"CONN: Rx Data: %@", strData);
    //[self.delegate newStatus:[NSString stringWithFormat:@"Rx Data: %@",strData]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *errorTxt = [error localizedDescription];
    [self.delegate newStatus:[NSString stringWithFormat:@"CONN: ConnectionError: %@", errorTxt]];
    //NSLog(@"CONN: Rx Error");
}



///////////
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  NSLog(@"Did start monitoring for region: '%@'", region.identifier);
  [self.delegate newStatus:[NSString stringWithFormat:@"Started Mon for %@, at %@",region.identifier, [NSDate date]]];
  //[self.delegate newStatus:[NSString stringWithFormat:@"AuthorizationStatus: %@", CLLocationManager.authorizationStatus ? @"YES" : @"NO"]];

}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  //[self.delegate locationController:self newStatus:@"Entered region"];
  [self.delegate newStatus:[NSString stringWithFormat:@"Entered region %@, at %@",region.identifier, [NSDate date]]];
  NSLog(@"Did enter region '%@'", region.identifier);
  [self stopRecording];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  //[self.delegate locationController:self newStatus:@"Left region"];
  [self.delegate newStatus:[NSString stringWithFormat:@"Exited region %@, at %@",region.identifier, [NSDate date]]];
  [self startRecording];
  NSLog(@"Did exit region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  self.currentLocation = newLocation;
  //[self.delegate locationController:self updatedLocation:newLocation];
  
  [self.recorder notifyOfNewLocation:newLocation];
}

@end
