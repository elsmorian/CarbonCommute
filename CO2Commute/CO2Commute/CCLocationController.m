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
    TFLog(@"Location Services Enabled: %@", CLLocationManager.locationServicesEnabled ? @"YES" : @"NO");
    TFLog(@"Region Monitoring Avalible: %@", CLLocationManager.regionMonitoringAvailable ? @"YES" : @"NO");
    TFLog(@"Region Monitoring Enabled: %@", CLLocationManager.regionMonitoringEnabled? @"YES" : @"NO");
   
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:@"first run complete"] == nil){
        //Bit of a hack to trigger location authentication alert at the start of app use, before getting to the maps.
        [_manager startUpdatingLocation];
        [_manager stopUpdatingLocation];
        
        [def setObject:@"Yes" forKey:@"first run complete"];
        TFLog(@"First run setup complete");
    }
    TFLog(@"Location Authorization Status: %@", CLLocationManager.authorizationStatus ? @"YES" : @"NO");

    
    [self.delegate newStatus:@"Starting..."];
    [self.delegate newStatus:[NSString stringWithFormat:@"Location Authorization Status: %@", CLLocationManager.authorizationStatus ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Location Services Enabled: %@", CLLocationManager.locationServicesEnabled ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Region Monitoring Avalible: %@", CLLocationManager.regionMonitoringAvailable ? @"YES" : @"NO"]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Region Monitoring Enabled: %@", CLLocationManager.regionMonitoringEnabled? @"YES" : @"NO"]];
    
    if (CLLocationManager.authorizationStatus && CLLocationManager.locationServicesEnabled && CLLocationManager.regionMonitoringAvailable && CLLocationManager.regionMonitoringEnabled){
        [self setUpRegionMonitoring];
    }
    
    TFLog(@"Set up completed at: %@",[NSDate date]);
    [self.delegate newStatus:[NSString stringWithFormat:@"Set up completed at: %@",[NSDate date]]];
}

- (void) setUpRegionMonitoring {
    NSLog(@"Setting up region monitoring");
    
    //reset all region monitoring
    NSLog(@"Currently: %@", [_manager monitoredRegions]);
    for (CLRegion *region in [_manager monitoredRegions]) {
        [self.manager stopMonitoringForRegion:region];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if home or work are missing, don't start monitoring. If they are there, do start monitoring!
    if ([[NSString stringWithFormat:@"%@",[defaults objectForKey:@"enable tracking"]] isEqualToString:@"No"]) {
        TFLog(@"Not setting geofences: User specified no tracking");
    }
    else if ([defaults objectForKey:@"home lat"] == nil || [defaults objectForKey:@"work lat"] == nil){
        TFLog(@"Not setting geofences: Home Lat/Lng: %@,%@, Work Lat/Lng: %@,%@.",
              [defaults objectForKey:@"home lat"] ? @"YES" : @"NO", [defaults objectForKey:@"home lng"] ? @"YES" : @"NO",
              [defaults objectForKey:@"work lat"] ? @"YES" : @"NO", [defaults objectForKey:@"work lng"] ? @"YES" : @"NO");
        [self.delegate newStatus:[NSString stringWithFormat:@"Home or work not set, not setting up geofences"]];
    }
    else {
        CLLocationCoordinate2D home = CLLocationCoordinate2DMake([[defaults valueForKey:@"home lat"] doubleValue], [[defaults valueForKey:@"home lng"] doubleValue]);
        CLLocationCoordinate2D work = CLLocationCoordinate2DMake([[defaults valueForKey:@"work lat"] doubleValue], [[defaults valueForKey:@"work lng"] doubleValue]);
        CLRegion *homeRegion = [[CLRegion alloc] initCircularRegionWithCenter:home radius:25.0 identifier:@"home"];
        CLRegion *workRegion = [[CLRegion alloc] initCircularRegionWithCenter:work radius:25.0 identifier:@"work"];
        NSLog(@"attempting region monitoring");
        [self.delegate newStatus:[NSString stringWithFormat:@"attempting region monitoring"]];
        [self.manager startMonitoringForRegion:homeRegion];
        [self.manager startMonitoringForRegion:workRegion];
        [TestFlight passCheckpoint:@"GEOFENCES SET"];
    }

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
    
    if ([self.manager respondsToSelector:@selector(activityType)]) {
        TFLog(@"Device responds to >iOS6 activity hints!");
        self.manager.activityType = CLActivityTypeFitness;
    }
        
    //self.manager.distanceFilter = ;
    [self.recorder startRecording];
    [self.manager startUpdatingLocation];
    [TestFlight passCheckpoint:@"STARTED RECORDING"];
}

- (void) stopRecording:(BOOL)autoUpload {
    [self.manager stopUpdatingLocation];
    [self.recorder stopRecording];
    [self saveLocationRecorder];

    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [self.delegate newStatus:[NSString stringWithFormat:@"Stopped rec at: %@",[NSDate date]]];
    [self.delegate newStatus:[NSString stringWithFormat:@"Battery at: %f",device.batteryLevel]];
    TFLog(@"Stopped recording at: %@",[NSDate date]);
    TFLog(@"Battery Level at: %f",device.batteryLevel);
    device.batteryMonitoringEnabled = NO;
    NSLog(@"Stats: %@",[self.recorder getCurrentCommuteStats]);
    [TestFlight passCheckpoint:@"FINISHED RECORDING"];
    
    if (autoUpload) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[NSString stringWithFormat:@"%@",[defaults objectForKey:@"enable auto-upload"]] isEqualToString:@"Yes"]) {
            [self.delegate newStatus:[NSString stringWithFormat:@"attempting auto-upload"]];
            TFLog(@"Attempting auto-upload");
            [self uploadData];
        }
        else {
            [self.delegate newStatus:[NSString stringWithFormat:@"Auto-upload not set, not uploading."]];
            TFLog(@"Auto-upload not set, not uploading.");
        }
    }
    [TestFlight passCheckpoint:@"FINISHED RECORDING"];
}


//////////////
#pragma mark - Uploading data

- (void) uploadData
{
    //Upload data should not try and upload if no username / password exsist, and notify user.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TFLog(@"UPLOAD: Attempting commute upload...");
    [self.delegate newStatus:[NSString stringWithFormat:@"attempting commute upload..."]];

    if ([defaults objectForKey:@"url"] == nil || [defaults objectForKey:@"crsid"] == nil) {
        //display alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error: No Locker Authentication Information"
                                                        message:@"Please enter your locker username and password in the app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        TFLog(@"UPLOAD: Failed: No authentication information present");
        return;
    }
    
    if ([self.recorder.loggedLocations count] < 1){
        [self.delegate newStatus:[NSString stringWithFormat:@"UPLOAD: Failed: No commutes to upload!"]];
        TFLog(@"UPLOAD: Failed: No commutes to upload!");
        return;
    }
    
    //Initiate background-capable task and start uploading data.
    
    UIApplication *app = [UIApplication sharedApplication];
    
    uploadTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:uploadTask];
        uploadTask = UIBackgroundTaskInvalid;
    }];
    
    startOfUpload = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
    NSMutableArray *commute = [self.recorder.loggedLocations lastObject];
    NSMutableDictionary *commuteStats = commute[0];
    NSMutableArray *commuteLocations = [[NSMutableArray alloc] initWithArray:[commute objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, commute.count-1)]]];
    id objStart = [commuteStats objectForKey:@"start"];
    id objEnd = [commuteStats objectForKey:@"end"];
    id objID = [commuteStats objectForKey:@"id"];
    
    NSLog(@"CS: %@",commuteStats);
    if ([[commuteStats objectForKey:@"status"] isEqualToString:@"Ready For Upload"]) {
        TFLog(@"Data already prepped for upload");
    }
    else {
        TFLog(@"Prepping data for upload");
        
        if ([objStart isKindOfClass:[NSNumber class]]) {
            NSLog(@"Start is a Number");
        }
        else if ([objStart isKindOfClass:[NSDate class]]) {
            NSLog(@"Start is a date");
        }
        else if ([objStart isKindOfClass:[NSString class]]) {
            NSLog(@"Start is a String");
        }
        
        if ([objEnd isKindOfClass:[NSNumber class]]) {
            NSLog(@"End is a Number");
        }
        else if ([objEnd isKindOfClass:[NSDate class]]) {
            NSLog(@"End is a date");
        }
        else if ([objEnd isKindOfClass:[NSString class]]) {
            NSLog(@"End is a String");
        }
        
        
        if ([objStart isKindOfClass:[NSDate class]]){
            NSLog(@"start is a NSDate");
            NSDate *start = [commuteStats objectForKey:@"start"];
            [commuteStats setObject:[[NSNumber alloc] initWithInt:[start timeIntervalSince1970]] forKey:@"start"];
            [commuteStats setObject:[[NSNumber alloc] initWithInt:[start timeIntervalSince1970]] forKey:@"id"];
        }
        if ([objID isKindOfClass:[NSDate class]]){
            NSLog(@"ID is a NSDate");
            NSDate *myID = [commuteStats objectForKey:@"id"];
            [commuteStats setObject:[[NSNumber alloc] initWithInt:[myID timeIntervalSince1970]] forKey:@"start"];
            [commuteStats setObject:[[NSNumber alloc] initWithInt:[myID timeIntervalSince1970]] forKey:@"id"];
        }
        if ([objEnd isKindOfClass:[NSDate class]]){
            NSLog(@"end is a NSDate");
            NSDate *end = [commuteStats objectForKey:@"end"];
            [commuteStats setObject:[[NSNumber alloc] initWithInt:[end timeIntervalSince1970]] forKey:@"end"];
        }

        if ([[commuteStats objectForKey:@"status"] isEqualToString:@"In Progress"]){
            TFLog(@"Bad data, attenpting repair");
        
            NSNumber *locsLength = [commuteStats objectForKey:@"locations"];
            if ([locsLength integerValue] != [commuteLocations count]){
                [commuteStats setObject:[[NSNumber alloc] initWithInt:[commuteLocations count]] forKey:@"locations"];
            }
            
        }
        
        [commuteStats setObject:@"Ready For Upload" forKey:@"status"];
    
    }
    
                
    
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
    if (![NSJSONSerialization isValidJSONObject: dataDict]){
        TFLog(@"JSON ERROR: Not a valid JSON Object");
        [self.delegate newStatus:[NSString stringWithFormat:@"JSON ERROR: Not a valid JSON Object"]];
    }
    else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        if (error) {
            TFLog(@"JSON ERROR: %@",error);
            [self.delegate newStatus:[NSString stringWithFormat:@"JSON ERROR: %@",error]];
        }
        else {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/push/test5",[defaults objectForKey:@"url"]]];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            //NSString *utfLen = [NSString stringWithFormat:@"%u", [jsonStr length]];
            
            //NSData *reqData = [NSData dataWithBytes:[jsonStr UTF8String] length:[jsonStr length]];
            //[request setValue:utfLen forHTTPHeaderField:@"Content-Length"];
            //[request setHTTPBodyStream:[NSInputStream inputStreamWithData:reqData]];
            [request setHTTPBody:[NSData dataWithBytes:[jsonStr UTF8String] length:[jsonStr length]]];
            [request setNetworkServiceType:NSURLNetworkServiceTypeBackground];
            
            
            TFLog(@"Upload of %i points took %f secs to assemble.",[routeDict count],[[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[startOfUpload integerValue]]]);
            [self.delegate newStatus:[NSString stringWithFormat:@"Upload of %i points took %f secs to assemble.",[routeDict count],[[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[startOfUpload integerValue]]]]];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
}


// FIXME: Remove these??
- (void) startTracking
{
    [self startRecording];
}

- (void) stopTracking:(BOOL) autoUpload
{
    [self stopRecording:autoUpload];
}

- (NSSet *) getMonitoredRegions
{
    return [self.manager monitoredRegions];
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
    UIApplication *app = [UIApplication sharedApplication];
    TFLog(@"Background time left: %d seconds..",[app backgroundTimeRemaining]);
    
    if ([strData isEqualToString:@"ok"]) {
        TFLog(@"UPLOAD: Successfull upload in %d seconds",[[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[startOfUpload integerValue]]]);
        [self.delegate newStatus:[NSString stringWithFormat:@"UPLOAD: Successfull upload"]];
        [TestFlight passCheckpoint:@"UPLOAD SUCCESS"];
        
        [self.recorder.loggedLocations removeLastObject];
        [self saveLocationRecorder];
        
        if ([self.recorder.loggedLocations count] > 0){
            if ([app backgroundTimeRemaining] < 60) {
                if (uploadTask != UIBackgroundTaskInvalid) {
                    [app endBackgroundTask:uploadTask];
                    uploadTask = UIBackgroundTaskInvalid;
                }
            }
            else {
                [self uploadData];
            }
        }
        else {
            TFLog(@"UPLOAD: All commutes uploaded.");
            if (uploadTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:uploadTask];
                uploadTask = UIBackgroundTaskInvalid;
            }
        }
    }
    else {
        TFLog(@"UPLOAD: Bad responce, will retry later.");
        [self.delegate newStatus:[NSString stringWithFormat:@"UPLOAD: Bad responce, will retry later."]];
        if (uploadTask != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:uploadTask];
            uploadTask = UIBackgroundTaskInvalid;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *errorTxt = [error localizedDescription];
    //[self.delegate newStatus:[NSString stringWithFormat:@"CONN: ConnectionError: %@", errorTxt]];
    TFLog(@"UPLOAD: Connection error: %@", errorTxt);
    [self.delegate newStatus:[NSString stringWithFormat:@"UPLOAD: Connection error: %@", errorTxt]];
    [self saveLocationRecorder]; //save state of commutes.
}



///////////
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  TFLog(@"Did start monitoring for region: '%@'", region.identifier);
  [self.delegate newStatus:[NSString stringWithFormat:@"Started Mon for %@, at %@",region.identifier, [NSDate date]]];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    TFLog(@"Did fail to monitor for region: '%@' due to: %@", region.identifier, [error localizedDescription]);
    [self.delegate newStatus:[NSString stringWithFormat:@"Did fail to monitor for region: '%@' due to: %@", region.identifier, [error localizedDescription]]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    TFLog(@"Changed location auth status: '%i'", status);
    [self.delegate newStatus:[NSString stringWithFormat:@"Changed location auth status: '%i'", status]];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  [self.delegate newStatus:[NSString stringWithFormat:@"Entered region %@, at %@",region.identifier, [NSDate date]]];
    if ([self.recorder isRecording]) {
      [self.delegate newStatus:[NSString stringWithFormat:@"Was recording, stopping.. %@", [NSDate date]]];
      [self stopRecording:YES];
    }
    else {
      [self.delegate newStatus:[NSString stringWithFormat:@"Was not recording, no need to stop."]];
    }
  NSLog(@"Did enter region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self.delegate newStatus:[NSString stringWithFormat:@"Exited region %@, at %@",region.identifier, [NSDate date]]];
  if ([self.recorder isRecording]) {
    [self.delegate newStatus:[NSString stringWithFormat:@"Is already recording, no need to start."]];
  }
  else {
    [self.delegate newStatus:[NSString stringWithFormat:@"Not already recording, starting.. at %@", [NSDate date]]];
    [self startRecording];
  }
  NSLog(@"Did exit region '%@'", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  self.currentLocation = newLocation;  
  [self.recorder notifyOfNewLocation:newLocation];
}

@end
