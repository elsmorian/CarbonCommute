//
//  CO2MyCommutesViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLocationController.h"

@interface CO2MyCommutesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    @private
    UIActionSheet *sheet;
    CCLocationController *locControl;
}

@property (nonatomic, strong) NSArray *commutes;
@property (strong, nonatomic) IBOutlet UITableView *uiTableView;

@end
