//
//  CO2SettingsViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CO2SettingsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *crsIDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *urlField;

- (IBAction)textFieldEditEnded:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *loggedLocationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedDataLabel;

@end
