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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [self setWindow:[[UIWindow alloc] initWithFrame:bounds]];
    
    SubscriptionsViewController *vc = [[SubscriptionsViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [[self window] setRootViewController:nc];
    [[self window] makeKeyAndVisible];
    return YES;
}

@end
