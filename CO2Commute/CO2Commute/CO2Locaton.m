//
//  CO2Locaton.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2Locaton.h"

@implementation CO2Locaton

- (NSDictionary *) toNSDictionary {
  
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
          [[NSNumber alloc] initWithDouble:self.coordinate.latitude], @"latitude",
          [[NSNumber alloc] initWithDouble:self.coordinate.longitude], @"longitude",
          [[NSNumber alloc] initWithDouble:self.horizontalAccuracy], @"horizontalAccuracy",
          [[NSNumber alloc] initWithDouble:self.speed], @"speed",
          [[NSNumber alloc] initWithDouble:self.course], @"course",
          [[NSNumber alloc] initWithDouble:self.altitude], @"altitude",
          [[NSNumber alloc] initWithDouble:self.verticalAccuracy], @"verticalAccuracy",
          self.timestamp, @"timestamp", nil];
  
  return dict;
}

- (NSString *) toJSONString {
  
  NSError *error;
  NSString *jsonStr;
  
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.toNSDictionary 
                                                     options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                       error:&error];
  if (! jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
  
  return jsonStr;
}

@end
