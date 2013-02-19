//
//  CO2AppDelegate.m
//  CO2Commute
//
//  Created by Chris Elsmore on 19/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2AppDelegate.h"
#import "CCLocationController.h"
#import "CO2RootViewController.h"

#define TESTING 1

@implementation CO2AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    NSDate *ts1 = [NSDate date];
    _locationController = [[CCLocationController alloc] init];
  
    // Nasty stuff to let the main view controller know about the controller.
    UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
    CO2RootViewController *rootVC = [[navController viewControllers] objectAtIndex:0];
    rootVC.locationController = _locationController;
    _locationController.delegate = rootVC;
    
    //Configure TestFlight Integration
    #ifdef TESTING
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #endif
    [TestFlight takeOff:@"a4976ae5b04e2fb808ad7260a8f510eb_MTQyMjU2MjAxMi0xMC0xNSAwODoyMjowMS40NDgyOTY"];
    //TFLog(@"App did launch with options: %@",launchOptions);
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    NSArray *appleKeys = [[NSArray alloc] initWithObjects:@"AppleICUForce24HourTime", @"AppleITunesStoreItemKinds", @"AppleKeyboards", @"AppleKeyboardsExpanded", @"AppleLanguages", @"AppleLocale", @"NSInterfaceStyle", @"NSLanguages", @"TVOutStatus", nil];
    [appDefaults removeObjectsForKeys:appleKeys];
    TFLog(@"User settings: %@", appDefaults);
    NSDate *ts2 = [NSDate date];
    TFLog(@"App took %f secs to launch with options: %@",[ts2 timeIntervalSinceDate:ts1],launchOptions);
    
    //First Launch Stuff:
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:@"first run complete"] == nil){
        [def removeObjectForKey:@"password"];
        [def setObject:@"Yes" forKey:@"enable tracking"];
        [def setObject:@"Yes" forKey:@"enable auto-upload"];
        [def setObject:@"No" forKey:@"enable commute-details"];
    }
    
    [TestFlight passCheckpoint:@"APP LAUNCH"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  [_locationController terminateNicely];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (CCLocationController *)getLocController
{
    return _locationController;
}

@end
