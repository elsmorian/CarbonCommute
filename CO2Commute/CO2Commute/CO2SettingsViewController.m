//
//  CO2SettingsViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2SettingsViewController.h"
#import "CO2AppDelegate.h"
#import "CCLocationController.h"
#import "CO2LocationRecorder.h"

@interface CO2SettingsViewController ()

@end

@implementation CO2SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CCLocationController *locControl = [appDelegate getLocController];
    defaults = [NSUserDefaults standardUserDefaults];

    
    hhdf = [[NSDateFormatter alloc] init];
    [hhdf setDateFormat:@"HH"];
    mmdf = [[NSDateFormatter alloc] init];
    [mmdf setDateFormat:@"mm"];
    
    NSString *crsid = [defaults objectForKey:@"crsid"];
    //NSString *password = [defaults objectForKey:@"password"];
    NSString *url = [defaults objectForKey:@"url"];
    NSString *commuteLength = [defaults objectForKey:@"commute length"];
    NSString *commuteStart = [defaults objectForKey:@"commute start"];
    NSString *commuteEnd = [defaults objectForKey:@"commute end"];
    
    self.accessoryView = [UIToolbar new];
    self.accessoryView.barStyle = UIBarStyleDefault;
    [self.accessoryView sizeToFit];
    UIBarButtonItem *donePickerButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self action:@selector(doneButton:)];
    NSArray *items = [NSArray arrayWithObjects: donePickerButton, nil];
    [self.accessoryView setItems:items];
    
    self.lengthInput = [[UIDatePicker alloc] init];
    self.lengthInput.datePickerMode = UIDatePickerModeCountDownTimer;
    self.lengthInput.minuteInterval = 5;
    [self.lengthInput setDate:[NSDate dateWithTimeIntervalSince1970:0] animated:YES];
    self.commuteLengthField.inputView = self.lengthInput;
    self.commuteLengthField.inputAccessoryView = self.accessoryView;
    [self.lengthInput addTarget:self action:@selector(lengthChange:) forControlEvents:UIControlEventValueChanged];
    
    self.startTimeInput = [[UIDatePicker alloc] init];
    self.startTimeInput.datePickerMode = UIDatePickerModeTime;
    self.startTimeInput.minuteInterval = 5;
    [self.startTimeInput setDate:[NSDate date] animated:YES];
    self.commuteStartField.inputView = self.startTimeInput;
    self.commuteStartField.inputAccessoryView = self.accessoryView;
    [self.startTimeInput addTarget:self action:@selector(startTimeChange:) forControlEvents:UIControlEventValueChanged];
    
    self.endTimeInput = [[UIDatePicker alloc] init];
    self.endTimeInput.datePickerMode = UIDatePickerModeTime;
    self.endTimeInput.minuteInterval = 5;
    [self.endTimeInput setDate:[NSDate date] animated:YES];
    self.commuteEndField.inputView = self.endTimeInput;
    self.commuteEndField.inputAccessoryView = self.accessoryView;
    [self.endTimeInput addTarget:self action:@selector(endTimeChange:) forControlEvents:UIControlEventValueChanged];


    
    NSString *locationsFilePath = [locControl locationRecorderFilePath];
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:locationsFilePath error:&attributesError];
    long fileSize = 0.0;
    if (!attributesError){
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        fileSize = [fileSizeNumber longLongValue] / 1024.0;
    }
    NSString *fileSizeString = nil;
    if (fileSize > 1024) {
        fileSize = fileSize / 1024.0;
        fileSizeString = [[NSString alloc] initWithFormat:@"%li MB", fileSize];
    }
    else fileSizeString = [[NSString alloc] initWithFormat:@"%li KB", fileSize];
   
    int numberOfLocations = [[locControl recorder] countAllLocations];
    NSString *locationNumberString = [[NSString alloc] initWithFormat:@"%i", numberOfLocations];
    int numberOfCommutes = [[locControl recorder] countCommutes];
    NSString *commuteNumberString = [[NSString alloc] initWithFormat:@"%i", numberOfCommutes];
    
    
    if (crsid) [self.crsIDField setText:crsid];
    //if (password) [self.passwordField setText:password];
    if (url) [self.urlField setText:url];
    
    if (commuteLength) [self.commuteLengthField setText:commuteLength];
    if (commuteStart) [self.commuteStartField setText:commuteStart];
    if (commuteEnd) [self.commuteEndField setText:commuteEnd];
    
    [self.crsIDField setDelegate:self];
    [self.passwordField setDelegate:self];
    [self.urlField setDelegate:self];
    [self.commuteLengthField setDelegate:self];
    [self.commuteStartField setDelegate:self];
    [self.commuteEndField setDelegate:self];
    
    [self.loggedDataLabel setText:fileSizeString];
    [self.loggedLocationsLabel setText:locationNumberString];
    [self.loggedCommutesLabel setText:commuteNumberString];
    
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCrsIDField:nil];
    [self setPasswordField:nil];
    [self setLoggedLocationsLabel:nil];
    [self setLoggedDataLabel:nil];
    [self setLoggedCommutesLabel:nil];
    [self setLoggedCommutesLabel:nil];
    [self setUrlField:nil];
    [self setCommuteLengthField:nil];
    [self setCommuteStartField:nil];
    [self setCommuteEndField:nil];
    [self setUseCommuteDetailsSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    switch (theTextField.tag){
        case 1:
             //CRSid field
            [theTextField resignFirstResponder];
            [self.passwordField becomeFirstResponder];
            return NO;
        case 2:
            //Password field
            [theTextField resignFirstResponder];
            return YES;
        case 3:
            [theTextField resignFirstResponder];
            return YES;
        case 4:
            [theTextField resignFirstResponder];
            
            return YES;
        case 5:
            [theTextField resignFirstResponder];
            return YES;
        case 6:
            [theTextField resignFirstResponder];
            return YES;
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    NSLog(@"%i finished editiing",theTextField.tag);
}


- (IBAction)textFieldEditEnded:(id)sender {
    switch([sender tag]){
        case 1:
            //CRSid field
            NSLog(@"%i",[sender tag]);
            [defaults setObject:[self.crsIDField text] forKey:@"crsid"];
            [defaults setObject:[NSString stringWithFormat:@"%@.locker.cam.ac.uk",[self.crsIDField text]] forKey:@"url"];
            [self.urlField setText:[NSString stringWithFormat:@"%@.locker.cam.ac.uk",[self.crsIDField text]]];
            break;
        case 2:
            //Password field
            NSLog(@"%i",[sender tag]);
            //[defaults setObject:[self.passwordField text] forKey:@"password"];
            break;
        case 3:
            //URL field
            NSLog(@"%i",[sender tag]);
            [defaults setObject:[self.urlField text] forKey:@"url"];
            break;
        case 4:
            //Commute Length field
            NSLog(@"%i",[sender tag]);
            break;
        case 5:
            //Commute Start field
            NSLog(@"%i",[sender tag]);
            break;
        case 6:
            //Commute End field
            NSLog(@"%i",[sender tag]);
            break;
    }
    [defaults synchronize];
    NSLog(@"Settings saved");
}

- (void)lengthChange:(id)sender{
    NSString *commuteLength = [[NSString alloc] initWithFormat:@"%@:%@",
                                            [hhdf stringFromDate:self.lengthInput.date],
                                            [mmdf stringFromDate:self.lengthInput.date]];
    [self.commuteLengthField setText:commuteLength];
    [defaults setObject:commuteLength forKey:@"commute length"];
}

- (void)startTimeChange:(id)sender{
    NSString *commuteStart = [[NSString alloc] initWithFormat:@"%@:%@",
                                            [hhdf stringFromDate:self.startTimeInput.date],
                                            [mmdf stringFromDate:self.startTimeInput.date]];
    [self.commuteStartField setText:commuteStart];
    [defaults setObject:commuteStart forKey:@"commute start"];
}

- (void)endTimeChange:(id)sender{
    NSString *commuteEnd = [[NSString alloc] initWithFormat:@"%@:%@",
                                            [hhdf stringFromDate:self.endTimeInput.date],
                                            [mmdf stringFromDate:self.endTimeInput.date]];
    [self.commuteEndField setText:commuteEnd];
    [defaults setObject:commuteEnd forKey:@"commute end"];
}

- (void)doneButton:(id)sender{
    [self.commuteLengthField resignFirstResponder];
    [self.commuteStartField resignFirstResponder];
    [self.commuteEndField resignFirstResponder];
    [defaults synchronize];
}
@end
