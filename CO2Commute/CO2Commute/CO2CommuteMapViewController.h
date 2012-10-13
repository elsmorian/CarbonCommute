//
//  CO2CommuteMapViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 24/09/2012.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CO2CommuteMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
