//
//  CCViewController.m
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCViewController.h"

@interface CCViewController ()

@end

@implementation CCViewController
@synthesize locationLabel;
@synthesize locationController = _locationController;

//////////
#pragma mark - Init and stuff

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.locationController = [[CCLocationController alloc] init];
    self.locationController.delegate = self;
  }
  return self;
}


//////////
#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLocationLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


//////////
#pragma mark - CCLocationControllerDelegate methods

- (void) locationController:(id)controller updatedLocation:(CLLocation *)location
{
  self.locationLabel.text = [NSString stringWithFormat:@"lat: %f, lng: %f", location.coordinate.latitude, location.coordinate.longitude];
}

- (IBAction)setHomeLocationFromCurrentLocation:(id)sender {
  CLLocation *location = self.locationController.currentLocation;
  [self.locationController registerHomeLocation:location];
}
@end
