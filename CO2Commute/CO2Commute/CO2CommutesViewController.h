//
//  CO2CommutesViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 30/11/2012.
//
//

#import <UIKit/UIKit.h>

@interface CO2CommutesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSArray *tableViewArray;
}

@property (nonatomic, retain) NSArray *tableViewArray;

@end
