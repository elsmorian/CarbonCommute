//
//  CO2CommuteMapViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 24/09/2012.
//
//

#import "CO2CommuteMapViewController.h"
#import "CO2MapAnnotation.h"
#import "CO2AppDelegate.h"
#import "CO2LocationRecorder.h"
#import "CCLocationController.h"


@interface CO2CommuteMapViewController ()

@end

@implementation CO2CommuteMapViewController

@synthesize mapView;
@synthesize locationAverageSpeed;
@synthesize locationCount;
@synthesize locationPercent;
@synthesize locationPercentBar;
@synthesize locationDateTime;
@synthesize commuteDetails;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"init!");
    }
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"load!");
    [super viewDidLoad];
    NSDate *t1 = [NSDate date];
    
    NSArray *CLLocs = [self.commuteDetails subarrayWithRange:NSMakeRange(1, [self.commuteDetails count]-1)];
    NSLog(@"%@",self.commuteDetails[0]);
    
    //NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D polylineCoords[[CLLocs count]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/YYYY HH:mm"];
    
    NSInteger index = 0;
    MKMapRect zoomRect = MKMapRectNull;
    
    for (CLLocation *tmpLoc in CLLocs) {
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(tmpLoc.coordinate.latitude, tmpLoc.coordinate.longitude);
        polylineCoords[index] = point;
        MKMapPoint mapPoint = MKMapPointForCoordinate(point);
        MKMapRect pointRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0, 1000);
        
        if (MKMapRectIsNull(zoomRect)){
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
//        if (index == 0 || index == [CLLocs count]-1) {
//            NSString *title = [df stringFromDate:tmpLoc.timestamp];
//            CO2MapAnnotation *newAnnotation = [[CO2MapAnnotation alloc] initWithTitle:title andCoordinate: tmpLoc.coordinate];
//            //[annotations addObject:newAnnotation];
//        }
        index++;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:polylineCoords count:[CLLocs count]];

    //[self.mapView addAnnotations:annotations];
    [self.mapView addOverlay:line];
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
    
    NSDate *t2 = [NSDate date];
    TFLog(@"Commute Map took %f secs to load commute with %i points.",[t2 timeIntervalSinceDate:t1],[CLLocs count]);
    [TestFlight passCheckpoint:@"VEIWED A COMMUTE"];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    NSLog(@"Provided line view");
    return polylineView;
}

//- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
//{
//	MKAnnotationView *annotationView = [views objectAtIndex:0];
//	id <MKAnnotation> mp = [annotationView annotation];
//	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
//	[mv setRegion:region animated:YES];
//	[mv selectAnnotation:mp animated:YES];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setLocationCount:nil];
    [self setLocationPercent:nil];
    [self setLocationPercentBar:nil];
    [self setLocationDateTime:nil];
    [super viewDidUnload];
}
@end
