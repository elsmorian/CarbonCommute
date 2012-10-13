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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CCLocationController *locControl = [appDelegate getLocController];
    //NSLog(@"counted %i locatins",[[locControl recorder] count]);
    //[noLoggedLocationsLabel setText:[NSString stringWithFormat:@"%i",[[locControl recorder] count]]];
    //CLLocation *tmpLoc = [[locControl recorder] getLastLocation];
    
    //CLLocationCoordinate2D loc;
    // loc.latitude = (double) 51.501468;
	//loc.longitude = (double) -0.141596;
    //loc.latitude = tmpLoc.coordinate;
	//loc.longitude = (double) -0.141596;
    
    //CO2MapAnnotation *newAnnotation = [[CO2MapAnnotation alloc] initWithTitle:@"QUEEN!" andCoordinate: tmpLoc.coordinate];
    //[self.mapView addAnnotation:newAnnotation];
    
    NSArray *CLLocs = [[locControl recorder] getCurrentCommuteLocations];
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    //NSMutableArray *polylineCords = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D polylineCoords[[CLLocs count]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/YYYY HH:mm:ss"];
    
    NSInteger index = 0;
    
    for (CLLocation *tmpLoc in CLLocs) {
        
        polylineCoords[index] = CLLocationCoordinate2DMake(tmpLoc.coordinate.latitude, tmpLoc.coordinate.longitude);
        //polylineCoords[index] = CLLocationCoordinate2DMake(tmpLoc.coordinate.longitude, tmpLoc.coordinate.latitude);

        
        NSString *title = [NSString stringWithFormat:@"%f, at %@",tmpLoc.horizontalAccuracy,tmpLoc.timestamp];
        CO2MapAnnotation *newAnnotation = [[CO2MapAnnotation alloc] initWithTitle:title andCoordinate: tmpLoc.coordinate];
        
        if (index == 0 || index == [CLLocs count]-1) {
            [annotations addObject:newAnnotation];
        }
        
        NSLog(@"lat:%f, lng: %f at %@ ~%f",tmpLoc.coordinate.latitude,tmpLoc.coordinate.longitude,[df stringFromDate:tmpLoc.timestamp],tmpLoc.horizontalAccuracy);
        index++;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:polylineCoords count:[CLLocs count]];
    //MKPolyline *line = [MKPolyline polylineWithPoints:polylineCoords count:[CLLocs count]];
    //line.strokeColor = [UIColor redColor];
    [self.mapView addAnnotations:annotations];
    [self.mapView addOverlay:line];
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    
    return polylineView;
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
