//
//  ASFLogInViewController.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASFLogInViewControllerDelegate;

@interface ASFLogInViewController : UIViewController

@property(nonatomic, weak) id<ASFLogInViewControllerDelegate> delegate;

- (id)initWithCliendID:(NSString *)clientID delegate:(id<ASFLogInViewControllerDelegate>)delegate;

+ (NSString *)code;

@end

@protocol ASFLogInViewControllerDelegate <NSObject>

@optional
- (void)logInViewController:(ASFLogInViewController *)logInViewController didFinish:(NSError *)error;
- (void)logInViewControllerDidCancelLogIn:(ASFLogInViewController *)logInViewController;

@end
