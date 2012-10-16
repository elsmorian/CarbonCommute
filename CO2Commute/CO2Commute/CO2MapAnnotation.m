//
//  CO2MapAnnotation.m
//  CO2Commute
//
//  Created by Chris Elsmore on 24/09/2012.
//
//

#import "CO2MapAnnotation.h"

@implementation CO2MapAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d
{
    self = [super init];
    title = ttl;
    coordinate = c2d;
    return self;
}

@end
