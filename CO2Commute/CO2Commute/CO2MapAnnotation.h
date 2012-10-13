//
//  CO2MapAnnotation.h
//  CO2Commute
//
//  Created by Chris Elsmore on 24/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CO2MapAnnotation : NSObject <MKAnnotation>{
    NSString *title;
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;

@end
