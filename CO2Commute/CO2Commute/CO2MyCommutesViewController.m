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
#import "CO2CommuteCell.h"
#import "CO2CommuteMapViewController.h"


@interface CO2MyCommutesViewController ()

@end

@implementation CO2MyCommutesViewController

@synthesize commutes;

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
    self.uiTableView.delegate = self;
    //[self.uiTableView registerClass:[CO2CommuteCell class] forCellReuseIdentifier:@"cell"];
    
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    locControl = [appDelegate getLocController];
    self.commutes = [[locControl recorder] getCommutes];
    //NSLog(@"%@",self.commutes);
    NSLog(@"loaded! %i",[self.commutes count]);
}

- (void)viewWillAppear:(BOOL)animated{
    //[super viewDidAppear];
    //NSLog(@"appeared! ");
    CO2AppDelegate *appDelegate = (CO2AppDelegate *)[[UIApplication sharedApplication] delegate];
    locControl = [appDelegate getLocController];
    self.commutes = [[locControl recorder] getCommutes];
    NSLog(@"appeared! %i",[self.commutes count]);
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setUiTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowCommuteDetails"]) {
        CO2CommuteMapViewController *commuteMapViewController = [segue destinationViewController];
        
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"%i",[myIndexPath row]);
        NSArray *commuteArray = [self.commutes objectAtIndex:[myIndexPath row]];
        //NSLog(@"commuteArray%@",commuteArray);
        commuteMapViewController.commuteDetails = commuteArray;
        
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 0 && indexPath.row == 5) {
//        // Delete Commute Cell Tapped
//        sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your last commute?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
//        [sheet showInView:self.view];
//    }
//}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    //buttonIndex = 0 for OK
//    if (buttonIndex == 0) [[locControl recorder] removeCurrentCommute];
//    //[self viewDidLoad];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%i",[self.commutes count]);
    return [self.commutes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"cell";
    //CO2CommuteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CO2CommuteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CO2CommuteCell alloc] init];
        //[cell reuseIdentifier:@"cell"];
    }
    
    // Configure the cell...
    //int i = [indexPath indexAtPosition:(indexPath.length - 1)];
    
    NSArray *cellCommute = [self.commutes objectAtIndex:indexPath.row];
    NSDictionary *data = [cellCommute objectAtIndex:0];
    int locs = [cellCommute count] - 1;
    
    id startObj = [data objectForKey:@"start"];
    id endObj = [data objectForKey:@"end"];
    NSDate *startDate;
    NSDate *endDate;
    
    
    if ([startObj isKindOfClass:[NSDate class]]){
        NSLog(@"Date!");
        startDate = startObj;
    }
    else if ([startObj isKindOfClass:[NSNumber class]]){
        NSLog(@"Number!");
        startDate = [NSDate dateWithTimeIntervalSince1970:[startObj integerValue]];
    }
    
    if ([endObj isKindOfClass:[NSDate class]]){
        NSLog(@"Date!");
        startDate = endObj;
    }
    else if ([endObj isKindOfClass:[NSNumber class]]){
        NSLog(@"Number!");
        endDate = [NSDate dateWithTimeIntervalSince1970:[endObj integerValue]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy hh:mma"];
    NSString *s_str = [dateFormatter stringFromDate:startDate];
    [dateFormatter setDateFormat:@"hh:mma"];
    NSString *e_str = [dateFormatter stringFromDate:endDate];
    NSString *txt = [NSString stringWithFormat:@"%@ - %@ (%i points)",s_str,e_str,locs];
    
    //NSLog(@"%@",txt);
    //[cell.commuteSpinner stopAnimating];
    //cell.commuteSpinner.hidden = YES;
    cell.commuteText.text = txt;
    return cell;
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
