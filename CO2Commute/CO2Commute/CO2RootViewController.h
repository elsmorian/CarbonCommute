//
//  CO2RootViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCLocationController;

@interface CO2RootViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *loggingSwitch;
@property (nonatomic, assign) CCLocationController *locationController;
@end
