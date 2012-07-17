//
//  CCViewController.h
//  CarbonCommute
//
//  Created by Chris Elsmore on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLocationController.h"

@interface CCViewController : UIViewController <CCLocationControllerDelegate> 

@property (nonatomic, retain) CCLocationController *locationController;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
- (IBAction)setHomeLocationFromCurrentLocation:(id)sender;

@end
