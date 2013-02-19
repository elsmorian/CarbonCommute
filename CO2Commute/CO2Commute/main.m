//
//  main.m
//  CO2Commute
//
//  Created by Chris Elsmore on 19/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CO2AppDelegate.h"

#ifdef DEBUG
void eHandler(NSException *);

void eHandler(NSException *exception) {
    NSLog(@"%@", exception);
    NSLog(@"%@", [exception callStackSymbols]);
}
#endif

int main(int argc, char *argv[])
{
    #ifdef DEBUG
        NSSetUncaughtExceptionHandler(&eHandler);
    #endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CO2AppDelegate class]));
    }
}
