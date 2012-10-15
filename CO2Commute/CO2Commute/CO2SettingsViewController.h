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

@property (weak, nonatomic) IBOutlet UITextField *commuteLengthField;
@property (weak, nonatomic) IBOutlet UITextField *commuteStartField;
@property (weak, nonatomic) IBOutlet UITextField *commuteEndField;
@property (nonatomic, retain) IBOutlet UIToolbar *accessoryView;


@property (nonatomic, retain) IBOutlet UIDatePicker *lengthInput;
@property (nonatomic, retain) IBOutlet UIDatePicker *startTimeInput;
@property (nonatomic, retain) IBOutlet UIDatePicker *endTimeInput;


- (IBAction)textFieldEditEnded:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *loggedLocationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedCommutesLabel;

@end
