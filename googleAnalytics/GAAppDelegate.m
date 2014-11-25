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

#import "GAManager.h"

#import "NetworkReachabilityManager.h"

@interface GAAppDelegate()
@property(strong) GATracker * tracker;
@property (strong) GAManager * manager;
@end
@implementation GAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    _tracker = [GATracker trackerWithID:@"UA-56518236-1"];
//    _manager = [GAManager sharedInstance];
    
     [GAManager addTrackersWithIDs:@[@"UA-56518236-1",@"UA-56518236-1"]];
}

- (IBAction)send:(id)sender {
    
//    [_tracker sendEventWithCategory:@"appLaunch" action:@"1" label:@"1" value:@1];
    
   
    [GAManager sendEventWithCategory:@"manager" action:@"t" label:@"t" value:@(rand())];
}
@end
