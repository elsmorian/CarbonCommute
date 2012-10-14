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
    _map.showsUserLocation = YES;
    [_map setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if home or work are missing, don't start monitoring. If they are there, do start monitoring!
    if (![defaults objectForKey:@"home"] || ![defaults objectForKey:@"work"]){
        NSLog(@"Home or work not set, not setting up geofences");
    }
    else {
        CLLocationCoordinate2D home;
        NSValue *homeValue = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"home"]];
        [homeValue getValue:&home];
        
        CLLocationCoordinate2D work;
        NSValue *workValue = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"work"]];
        [workValue getValue:&work];
        
        MKPointAnnotation *homeAnnot = [[MKPointAnnotation alloc] init];
        homeAnnot.coordinate = home;
        homeAnnot.title = @"Home";
        MKPointAnnotation *workAnnot = [[MKPointAnnotation alloc] init];
        workAnnot.coordinate = work;
        workAnnot.title = @"Work";
        [_map addAnnotation:workAnnot];
        [_map addAnnotation:homeAnnot];
    }
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 1.5; //user needs to press for 1.5 seconds
    [_map addGestureRecognizer:_lpgr];
    //_tempTouchPoint = [CGPoint ];
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
            NSLog(@"New Update: %f", accuracy);
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 0.25*METERS_PER_MILE, 0.25*METERS_PER_MILE);
            MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
            [_map setRegion:adjustedRegion animated:YES];
            _viewDidZoom = YES;
        }
    }
    //NSLog(@"New Update: %f", accuracy);
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    _tempTouchPoint = [gestureRecognizer locationInView:_map];
    //CLLocationCoordinate2D touchMapCoordinate = [_map convertPoint:touchPoint toCoordinateFromView:_map];
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Is this home or work?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Home",@"Work", nil];
    [sheet showInView:self.view];
    
    //MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    //annot.coordinate = touchMapCoordinate;
    //annot.title = @"Testings!";
    //annot.subtitle = @"This is my home";
    //[_map addAnnotation:annot];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Button indexes: Home = 0, Work = 1
    CLLocationCoordinate2D touchMapCoordinate = [_map convertPoint:_tempTouchPoint toCoordinateFromView:_map];
    NSValue *touchLocation = [NSValue valueWithBytes:&touchMapCoordinate objCType:@encode(CLLocationCoordinate2D)];
    NSData *touchData = [NSKeyedArchiver archivedDataWithRootObject:touchLocation];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    
    if (buttonIndex == 0){
        NSLog(@"Home Pressed");
        annot.title = @"Home";
        for (MKPointAnnotation *annotation in [_map annotations]) {
            if (annotation.title == @"Home") {
                [_map removeAnnotation:annotation];
                break;
            }
        }
        //init an NSNumber to store these.
        [defaults setObject:touchMapCoordinate.latitude forKey:@"home"];
        [_map addAnnotation:annot];
    }
    if (buttonIndex == 1){
        NSLog(@"Work Pressed");
        annot.title = @"Work";
        for (MKPointAnnotation *annotation in [_map annotations]) {
            if (annotation.title == @"Work") {
                [_map removeAnnotation:annotation];
                break;
            }
        }
        [defaults setObject:touchData forKey:@"work"];
        [_map addAnnotation:annot];
    }
    [defaults synchronize];
    [locControl setUpRegionMonitoring];
}

@end
