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

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *locationCount;
@property (strong, nonatomic) IBOutlet UILabel *locationPercent;
@property (strong, nonatomic) IBOutlet UIProgressView *locationPercentBar;
@property (strong, nonatomic) IBOutlet UILabel *locationAverageSpeed;
@property (strong, nonatomic) IBOutlet UILabel *locationDateTime;

@property (strong, nonatomic) NSArray *commuteDetails;

@end
