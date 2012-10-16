//
//  CO2MapViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 30/07/2012.
//
//

#import "CO2MapViewController.h"
#import "CO2AppDelegate.h"
#import "CCLocationController.h"

@interface CO2MapViewController ()

@end

@implementation CO2MapViewController
@synthesize map = _map;
//@synthesize lpgr = _lpgr;

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
    NSDate *t1 = [NSDate date];
    _map.showsUserLocation = YES;
    [_map setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if home or work are missing, don't load points
    
    if (![defaults objectForKey:@"home lat"]) {
        CLLocationCoordinate2D home = CLLocationCoordinate2DMake([[defaults valueForKey:@"home lat"] doubleValue], [[defaults valueForKey:@"home lng"] doubleValue]);
        MKPointAnnotation *homeAnnot = [[MKPointAnnotation alloc] init];
        homeAnnot.coordinate = home;
        homeAnnot.title = @"Home";
        [_map addAnnotation:homeAnnot];
    }
    if (![defaults objectForKey:@"work lat"]) {
        CLLocationCoordinate2D work = CLLocationCoordinate2DMake([[defaults valueForKey:@"work lat"] doubleValue], [[defaults valueForKey:@"work lng"] doubleValue]);
        MKPointAnnotation *workAnnot = [[MKPointAnnotation alloc] init];
        workAnnot.coordinate = work;
        workAnnot.title = @"Home";
        [_map addAnnotation:workAnnot];
    }
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 1.5; //user needs to press for 1.5 seconds
    [_map addGestureRecognizer:_lpgr];

    _viewDidZoom = NO;
    sheet = [[UIActionSheet alloc] initWithTitle:@"Tap and hold to place markers and set your home and work locations."
                                        delegate:nil
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"OK" ,nil];
    
    // Show the sheet
    [sheet showInView:self.view];
    sheet = nil;
    
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    locControl = [appDelegate getLocController];
    
    NSDate *t2 = [NSDate date];
    TFLog(@"Settings Map View Controller took %i seconds to load.",[t2 timeIntervalSinceDate:t1]);

}

- (void)viewDidUnload
{
    [_map.userLocation removeObserver:self forKeyPath:@"location"];
    [_map removeFromSuperview];
    [_map removeGestureRecognizer:_lpgr];
    _lpgr = nil;
    // _viewDidZoom = nil;
    [self setMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if(!_viewDidZoom){
        CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
        if (accuracy <= 65) {
            //NSLog(@"New Update: %f", accuracy);
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 0.25*METERS_PER_MILE, 0.25*METERS_PER_MILE);
            MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
            [_map setRegion:adjustedRegion animated:YES];
            _viewDidZoom = YES;
        }
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    _tempTouchPoint = [gestureRecognizer locationInView:_map];
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Is this home or work?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Home",@"Work", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Button indexes: Home = 0, Work = 1
    CLLocationCoordinate2D touchMapCoordinate = [_map convertPoint:_tempTouchPoint toCoordinateFromView:_map];
    NSNumber *lat = [[NSNumber alloc] initWithDouble:touchMapCoordinate.latitude];
    NSNumber *lng = [[NSNumber alloc] initWithDouble:touchMapCoordinate.longitude];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    
    if (buttonIndex == 0){
        //NSLog(@"Home Pressed");
        annot.title = @"Home";
        for (MKPointAnnotation *annotation in [_map annotations]) {
            if (annotation.title == @"Home") {
                [_map removeAnnotation:annotation];
                break;
            }
        }
        [defaults setObject:lat forKey:@"home lat"];
        [defaults setObject:lng forKey:@"home lng"];
        [_map addAnnotation:annot];
    }
    if (buttonIndex == 1){
        //NSLog(@"Work Pressed");
        annot.title = @"Work";
        for (MKPointAnnotation *annotation in [_map annotations]) {
            if (annotation.title == @"Work") {
                [_map removeAnnotation:annotation];
                break;
            }
        }
        [defaults setObject:lat forKey:@"work lat"];
        [defaults setObject:lng forKey:@"work lng"];
        [_map addAnnotation:annot];
    }
    [defaults synchronize];
    [locControl setUpRegionMonitoring];
}

@end
