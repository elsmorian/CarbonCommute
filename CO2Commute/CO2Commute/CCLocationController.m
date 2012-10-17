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
#import "PDKeychainBindings.h"

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
    if ([[NSString stringWithFormat:@"%@",[defaults objectForKey:@"enable tracking"]] isEqualToString:@"No"]) {
        TFLog(@"Not setting geofences: User specified no tracking");
    }
    else if (![defaults objectForKey:@"home lat"] || ![defaults objectForKey:@"work lat"]){
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
    [self.delegate newStatus:[NSString stringWithFormat:@"Monitored regions: %@", [_manager monitoredRegions]]];
    TFLog(@"Monitored regions: %@", [_manager monitoredRegions]);

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[NSString stringWithFormat:@"%@",[defaults objectForKey:@"enable auto-upload"]] isEqualToString:@"Yes"]) {
        [self uploadData];
    }
}


//////////////
#pragma mark - Uploading data

- (void) uploadData
{
    //Upload data should not try and upload if no username / password exsist, and notify user.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TFLog(@"UPLOAD: Attempting commute upload...");
    
//    NSLog(@"%@",[defaults objectForKey:@"url"]);
//    NSLog(@"%@",[defaults objectForKey:@"user"]);
    if (![defaults objectForKey:@"url"] || ![defaults objectForKey:@"crsid"]) {
        //display alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error: No Locker Authentication Information"
                                                        message:@"Please enter your locker username and password in the app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        TFLog(@"UPLOAD: Failed: No authentication information present");
    }
    else {
        if ([self.recorder.loggedLocations count] > 0){
            NSDate *ts1 = [NSDate date];
            NSMutableArray *commute = [self.recorder.loggedLocations lastObject];
            NSMutableDictionary *commuteStats = commute[0];
            NSLog(@"%@", commuteStats);
            
            id objStart = [commuteStats objectForKey:@"start"];
            if ([objStart isMemberOfClass:[NSDate class]]){
                NSDate *start = objStart;
                [commuteStats setObject:[[NSNumber alloc] initWithInt:[start timeIntervalSince1970]] forKey:@"start"];
                [commuteStats setObject:[[NSNumber alloc] initWithInt:[start timeIntervalSince1970]] forKey:@"id"];
                NSDate *end = [commuteStats objectForKey:@"end"];
                [commuteStats setObject:[[NSNumber alloc] initWithInt:[end timeIntervalSince1970]] forKey:@"end"];
            }
            
            NSMutableArray *commuteLocations = [[NSMutableArray alloc] initWithArray:[commute objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, commute.count-1)]]];
            NSMutableArray *routeDict = [[NSMutableArray alloc] init];
            
            for (CLLocation *loc in commuteLocations){
                [routeDict addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                        [[NSNumber alloc] initWithDouble:loc.coordinate.latitude], @"latitude",
                        [[NSNumber alloc] initWithDouble:loc.coordinate.longitude], @"longitude",
                        [[NSNumber alloc] initWithDouble:loc.horizontalAccuracy], @"horizontalAccuracy",
                        [[NSNumber alloc] initWithDouble:loc.speed], @"speed",
                        [[NSNumber alloc] initWithDouble:loc.course], @"course",
                        [[NSNumber alloc] initWithDouble:loc.altitude], @"altitude",
                        [[NSNumber alloc] initWithDouble:loc.verticalAccuracy], @"verticalAccuracy",
                        [[NSNumber alloc] initWithInt: loc.timestamp.timeIntervalSince1970 ], @"ts", nil]];
            }
            [commuteStats setObject:routeDict forKey:@"route"];
            
            NSArray *dataArray = [[NSArray alloc] initWithObjects:commuteStats, nil];
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys: dataArray, @"data", nil];
                                      
            NSString *jsonStr;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/push/test2",[defaults objectForKey:@"url"]]];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[NSData dataWithBytes:[jsonStr UTF8String] length:[jsonStr length]]];
            
            TFLog(@"Upload of %i points took %f secs to assemble.",[routeDict count],[[NSDate date] timeIntervalSinceDate:ts1]);

            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
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


///////////
#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    TFLog(@"UPLOAD: Authentication handshake");
    if (challenge.previousFailureCount < 3) {
        PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
        NSString *password = [keyChain objectForKey:@"password"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"crsid"];
        
        NSURLCredential *credential = [NSURLCredential
                                       credentialWithUser:username
                                       password:password
                                       persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error: Incorrect Locker Authentication Information"
                                                        message:@"Please check your locker username and password in the app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        TFLog(@"UPLOAD: Authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    TFLog(@"UPLOAD: Got HTTP Code: %i",[httpResponse statusCode]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if ([strData isEqualToString:@"ok"]) {
        TFLog(@"UPLOAD: Successfull upload");
        
        [self.recorder.loggedLocations removeLastObject];
        [self saveLocationRecorder];
        
        if ([self.recorder.loggedLocations count] > 0) [self uploadData];
        else TFLog(@"UPLOAD: All commutes uploaded.");
    }
    else TFLog(@"UPLOAD: Bad responce, will retry later.");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *errorTxt = [error localizedDescription];
    [self.delegate newStatus:[NSString stringWithFormat:@"CONN: ConnectionError: %@", errorTxt]];
    TFLog(@"UPLOAD: Connection error: %@", errorTxt);
}



///////////
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  NSLog(@"Did start monitoring for region: '%@'", region.identifier);
  [self.delegate newStatus:[NSString stringWithFormat:@"Started Mon for %@, at %@",region.identifier, [NSDate date]]];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  [self.delegate newStatus:[NSString stringWithFormat:@"Entered region %@, at %@",region.identifier, [NSDate date]]];
  NSLog(@"Did enter region '%@'", region.identifier);
  [self stopRecording];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self.delegate newStatus:[NSString stringWithFormat:@"Exited region %@, at %@",region.identifier, [NSDate date]]];
  [self startRecording];
  NSLog(@"Did exit region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  self.currentLocation = newLocation;  
  [self.recorder notifyOfNewLocation:newLocation];
}

@end
