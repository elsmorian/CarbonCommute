//
//  CCLocationController.h
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CO2LocationRecorder;

@protocol CCLocationControllerDelegate
- (void) newStatus:(NSString *) status;
@end

@interface CCLocationController : NSObject <CLLocationManagerDelegate, NSURLConnectionDelegate>{
    NSNumber *startOfUpload;
    UIBackgroundTaskIdentifier uploadTask;
}

@property (nonatomic, assign) id<CCLocationControllerDelegate> delegate;
@property (nonatomic, retain) CLLocationManager *manager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CO2LocationRecorder *recorder;

- (NSString *) locationRecorderFilePath;
- (void) registerHomeLocation;
- (void) terminateNicely;
- (void) setUp;
- (void) setUpRegionMonitoring;
- (void) startTracking;
- (void) stopTracking:(BOOL)autoUpload;
- (void) uploadData;
- (NSSet *) getMonitoredRegions;

@end
