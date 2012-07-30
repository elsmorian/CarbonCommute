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
    [_map.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew) context:NULL];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [_map addGestureRecognizer:lpgr];
    _viewDidZoom = false;
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)viewWillAppear:(BOOL)animated {
//    CLLocationCoordinate2D zoomlocation;
//}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if(!_viewDidZoom){
    if ([_map showsUserLocation]) {
      //CLLocationCoordinate2D zoomLocation = self.map.userLocation.coordinate;
      MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_map.userLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
      MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
      [_map setRegion:adjustedRegion animated:YES];
      _viewDidZoom = true;
    }
  }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_map];
    CLLocationCoordinate2D touchMapCoordinate =
    [_map convertPoint:touchPoint toCoordinateFromView:_map];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.title = @"Testings!";
    annot.subtitle = @"This is my home";
    [_map addAnnotation:annot];
}

@end
