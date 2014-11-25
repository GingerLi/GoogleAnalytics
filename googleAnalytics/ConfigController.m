//
//  ConfigController.m
//  googleAnalytics
//
//  Created by itisdev on 11/25/14.
//  Copyright (c) 2014 trendmicro. All rights reserved.
//

#import "ConfigController.h"
#include <pthread.h>

pthread_rwlock_t g_plist_rwlock;

@interface ConfigController ()
@property (strong) NSMutableDictionary * config;

@end
@implementation ConfigController

+ (ConfigController *)sharedInstance
{
    static ConfigController * controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[ConfigController alloc] init];
    });
    return controller;
}

+ (id)objectForKey:(NSString *)key
{
    return [[ConfigController sharedInstance] objectForKey:key];
}

+ (void)setObject:(id)value forKey:(NSString *)key
{
    [[ConfigController sharedInstance] setObject:value forKey:key];
}

+ (void)removeObjectForKey:(NSString *)key
{
    [[ConfigController sharedInstance] removeObjectForKey:key];
}
#pragma mark




#pragma mark

- (id)init
{
    self = [super init];
    if (self) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self configPath]]) {
            _config = [[NSMutableDictionary alloc] initWithContentsOfFile:[self configPath]];
            
        } else {
            _config = [NSMutableDictionary new];
            [self write];
        }
        
        if(pthread_rwlock_init(&g_plist_rwlock, NULL) != 0)
        {
            NSLog(@"Fail to init lock");
        }
        
    }
    return self;
}
-(void)dealloc
{
    pthread_rwlock_destroy(&g_plist_rwlock);
   
}
- (NSString *)configPath
{
    return [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), [[NSBundle mainBundle] bundleIdentifier]];
}

- (void)setObject:(id)value forKey:(NSString *)key
{
    if (0 == pthread_rwlock_wrlock(&g_plist_rwlock)) {
        [self.config addEntriesFromDictionary:@{key: value}];
        
        pthread_rwlock_unlock(&g_plist_rwlock);
    }
    
    [self write];
}

- (void)removeObjectForKey:(NSString *)key
{
    if (0 == pthread_rwlock_wrlock(&g_plist_rwlock)) {
        [self.config removeObjectForKey:key];
        pthread_rwlock_unlock(&g_plist_rwlock);
    }
    
    [self write];
}

- (id)objectForKey:(NSString *)key
{
    if (0 == pthread_rwlock_rdlock(&g_plist_rwlock)) {
        id value = [self.config valueForKeyPath:key];
        pthread_rwlock_unlock(&g_plist_rwlock);
        return value;
    }
    return nil;
}

- (void)write
{
    BOOL success = [self.config writeToFile:[self configPath] atomically:YES];
    if (!success) {
        NSLog(@"Fail to write config");
    }
}

@end
