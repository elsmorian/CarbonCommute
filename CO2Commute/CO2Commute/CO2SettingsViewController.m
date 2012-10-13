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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *crsid = [defaults objectForKey:@"crsid"];
    NSString *password = [defaults objectForKey:@"password"];
    NSString *url = [defaults objectForKey:@"url"];
    
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
    //NSLog(@"Size: %f kB", fileSize);
    //NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    
    
    [self.crsIDField setText:crsid];
    [self.passwordField setText:password];
    [self.urlField setText:url];
    
    [self.crsIDField setDelegate:self];
    [self.passwordField setDelegate:self];
    [self.urlField setDelegate:self];
    
    [self.loggedDataLabel setText:fileSizeString];
    [self.loggedLocationsLabel setText:locationNumberString];
    
    [super viewDidLoad];
    //[_crsIDField setText:@"Loaded LOL"];
    //CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    //CCLocationController *locControl = [appDelegate getLocController];
    //NSLog(@"counted %i locatins",[[locControl recorder] count]);
    //[noLoggedLocationsLabel setText:[NSString stringWithFormat:@"%i",[[locControl recorder] count]]];
    //[appDelegate _location]

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCrsIDField:nil];
    [self setPasswordField:nil];
    [self setUrlField:nil];
    [self setLoggedLocationsLabel:nil];
    [self setLoggedDataLabel:nil];
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
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    NSLog(@"%i finished editiing",theTextField.tag);
}


- (IBAction)textFieldEditEnded:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch([sender tag]){
        case 1:
            //CRSid field
            NSLog(@"%i",[sender tag]);
            [defaults setObject:[self.crsIDField text] forKey:@"crsid"];
            break;
        case 2:
            //Password field
            NSLog(@"%i",[sender tag]);
            [defaults setObject:[self.passwordField text] forKey:@"password"];
            break;
        case 3:
            //URL field
            NSLog(@"%i",[sender tag]);
            [defaults setObject:[self.urlField text] forKey:@"url"];
            break;
    }
    [defaults synchronize];
    NSLog(@"Settings saved");
}
@end
