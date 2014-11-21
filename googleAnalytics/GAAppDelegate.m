//
//  GAAppDelegate.m
//  googleAnalytics
//
//  Created by itisdev on 11/20/14.
//  Copyright (c) 2014 trendmicro. All rights reserved.
//

#import "GAAppDelegate.h"
#import "GAHit.h"
#import "GATracker.h"
#import "GAEventHit.h"

@implementation GAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
}

- (IBAction)send:(id)sender {
    GATracker * tracker = [GATracker trackerWithID:@"UA-56518236-1"];
    [tracker sendEventWithCategory:@"ginger" action:@"1" label:@"1" value:@1];
}
@end
