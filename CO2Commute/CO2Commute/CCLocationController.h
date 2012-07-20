//
//  CCLocationController.h
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CCLocationControllerDelegate
- (void) locationController:(id)controller updatedLocation:(CLLocation *)location;
- (void) locationController:(id)controller newStatus:(NSString *) status;
@end

@interface CCLocationController : NSObject <CLLocationManagerDelegate> {
    NSMutableArray *_loggedLocations;
}

@property (nonatomic, assign) id<CCLocationControllerDelegate> delegate;
@property (nonatomic, retain) CLLocationManager *manager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void) registerHomeLocation;

@end
