//
//  CO2RootViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2RootViewController.h"
#import "CCLocationController.h"

@interface CO2RootViewController ()

@end

@implementation CO2RootViewController
@synthesize uploadButton;
@synthesize loggingSwitch;
@synthesize loggingSpinner;
@synthesize _debugText;
@synthesize locationController = _locationController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (IBAction)switched: (UISwitch *)mySwitch{
//    NSLog(@"Event!");
//  if (mySwitch.on){
//    NSLog(@"Switched on!");
//    [_locationController startTracking];
//    [loggingSpinner startAnimating];
//    [loggingSpinner setHidden:false];
//  }
//  else {
//    [self.locationController stopTracking];
//    [loggingSpinner setHidden:false];
//    [loggingSpinner stopAnimating];
//    NSLog(@"Switched off!");
//  }
//}
- (IBAction)switched:(UISwitch *)mySwitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (mySwitch.on){
        [defaults setObject:@"Yes" forKey:@"enable tracking"];
    }
    else {
        [defaults setObject:@"No" forKey:@"enable tracking"];
    }
    [defaults synchronize];
    [_locationController setUpRegionMonitoring];
}

- (IBAction)uploadTapped:(id)sender {
    NSLog(@"Upload Tapped");
    [_locationController uploadData];
}

//- (IBAction)uploadTapped: (UIButton *)uploadButton

- (void) newStatus:(NSString *) status {
    NSString *newText = [self._debugText.text stringByAppendingFormat:@"\n%@", status];
    self._debugText.text = newText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[NSString stringWithFormat:@"%@",[defaults objectForKey:@"enable tracking"]] isEqualToString:@"No"]) {
        [self.loggingSwitch setOn:NO animated:YES];
    }
    else [self.loggingSwitch setOn:YES animated:YES];
    
    [_locationController setUp];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [self setLoggingSwitch:nil];
    [self setLoggingSpinner:nil];
    [self set_debugText:nil];
    [self setUploadButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

@end
