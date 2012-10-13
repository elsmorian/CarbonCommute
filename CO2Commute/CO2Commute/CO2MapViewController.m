//
//  CO2MapViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 30/07/2012.
//
//

#import "CO2MapViewController.h"

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
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 1.5; //user needs to press for 1.5 seconds
    [_map addGestureRecognizer:_lpgr];
    
    _viewDidZoom = NO;
    sheet = [[UIActionSheet alloc] initWithTitle:@"Tap and hold to place markers and set your home and work locations."
                                        delegate:self
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"OK" ,nil];
    
    // Show the sheet
    [sheet showInView:self.view];
    sheet = nil;
    
}

- (void)viewDidUnload
{
    [_map.userLocation removeObserver:self forKeyPath:@"location"];
    [_map removeFromSuperview];
    [_map removeGestureRecognizer:_lpgr];
    //_lpgr = nil;
    //_viewDidZoom = nil;
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
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
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
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_map];
    CLLocationCoordinate2D touchMapCoordinate =
    [_map convertPoint:touchPoint toCoordinateFromView:_map];
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Is this home or work?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Home",@"Work", nil];
    [sheet showInView:self.view];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.title = @"Testings!";
    annot.subtitle = @"This is my home";
    [_map addAnnotation:annot];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
}

@end
