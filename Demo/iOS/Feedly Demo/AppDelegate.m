//
//  AppDelegate.m
//  Feedly Demo
//
//  Created by Anton Simakov on 12/25/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AppDelegate.h"
#import "SubscriptionsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SubscriptionsViewController *vc = [[SubscriptionsViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
