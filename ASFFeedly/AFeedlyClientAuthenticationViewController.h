//
//  AFeedlyClientAuthenticationViewController.h
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AFeedlyClientAuthenticationViewController;

@protocol AFeedlyClientAuthenticationViewControllerDelegate<NSObject>

- (void)feedlyClientAuthenticationViewController:(AFeedlyClientAuthenticationViewController *)vc
                               didFinishWithCode:(NSString *)authentication;
@end

@interface AFeedlyClientAuthenticationViewController : UIViewController

@property(nonatomic, weak) id<AFeedlyClientAuthenticationViewControllerDelegate> delegate;

- (id)initWithCliendID:(NSString *)clientID delegate:(id<AFeedlyClientAuthenticationViewControllerDelegate>)delegate;

@end
