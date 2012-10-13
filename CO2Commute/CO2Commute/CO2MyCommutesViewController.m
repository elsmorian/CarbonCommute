//
//  CO2MyCommutesViewController.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2MyCommutesViewController.h"
#import "CO2AppDelegate.h"
#import "CCLocationController.h"
#import "CO2LocationRecorder.h"


@interface CO2MyCommutesViewController ()

@end

@implementation CO2MyCommutesViewController

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
    [super viewDidLoad];
    
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CCLocationController *locControl = [appDelegate getLocController];
    
    [_currentNumberOfLocations setText:[NSString stringWithFormat:@"%i",[[locControl recorder] countCurrentCommuteLocations]]];
    
    //NSLog(@"counted %i locatins",[[locControl recorder] count]);
    //[_numberOfData setText:[NSString stringWithFormat:@"%i",[[locControl recorder] count]]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCurrentNumberOfLocations:nil];
    [self setCurrentTimeTaken:nil];
    [self setCurrentDistance:nil];
    [self setCurrentAverageSpeed:nil];
    [self setCurrentNumberOfLocations:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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

//- (IBAction)clearButton:(id)sender {
//    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
//    CCLocationController *locControl = [appDelegate getLocController];
//    //[[locControl recorder] clearLocations];
//}
@end
