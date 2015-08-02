//
//  ASFLogInViewController.h
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASFLogInViewController;

@protocol ASFLogInViewControllerDelegate<NSObject>

- (void)feedlyClientAuthenticationViewController:(ASFLogInViewController *)vc
                               didFinishWithCode:(NSString *)authentication;
@end

@interface ASFLogInViewController : UIViewController

@property(nonatomic, weak) id<ASFLogInViewControllerDelegate> delegate;

- (id)initWithCliendID:(NSString *)clientID delegate:(id<ASFLogInViewControllerDelegate>)delegate;

@end
