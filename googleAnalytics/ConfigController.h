//
//  ConfigController.h
//  googleAnalytics
//
//  Created by itisdev on 11/25/14.
//  Copyright (c) 2014 trendmicro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigController : NSObject
+ (ConfigController *)sharedInstance;
+ (id)objectForKey:(NSString *)key;
+ (void)setObject:(id)value forKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;
@end
