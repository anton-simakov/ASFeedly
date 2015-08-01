//
//  ASFSignInViewController.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASFSignInViewController;

@protocol ASFSignInViewControllerDelegate<NSObject>

- (void)feedlyClientAuthenticationViewController:(ASFSignInViewController *)vc
                               didFinishWithCode:(NSString *)authentication;
@end

@interface ASFSignInViewController : UIViewController

@property(nonatomic, weak) id<ASFSignInViewControllerDelegate> delegate;

- (id)initWithCliendID:(NSString *)clientID delegate:(id<ASFSignInViewControllerDelegate>)delegate;

@end
