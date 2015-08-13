//
//  ASFLogInViewController.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFLogInViewController.h"

#import "ASFFeedly.h"
#import "ASFConstants.h"
#import "ASFRequestBuilder.h"

static NSString *_code;

@interface ASFLogInViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ASFLogInViewController

+ (NSString *)code {
    return _code;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *parameters = @{@"client_id" : self.clientID,
                                 @"redirect_uri" : ASFRedirectURI,
                                 @"response_type" : @"code",
                                 @"scope" : @"https://cloud.feedly.com/subscriptions"};
    
    ASFRequestBuilder *builder = [[ASFRequestBuilder alloc] init];
    
    NSURLRequest *request = [builder request:@"GET"
                                        path:ASFAuthAuthPath
                                  parameters:parameters
                                       token:nil
                                       error:nil];
    [self.webView loadRequest:request];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;
    if ([ASFFeedly openURL:URL]) {
        
        NSDictionary *parameters = ASFParametersFromQuery(URL.query);
        
        _code = parameters[@"code"];
        
        if ([self.delegate respondsToSelector:@selector(logInViewController:didFinish:)]) {
            [self.delegate logInViewController:self didFinish:nil];
        }
        
        return NO;
    }
    
    return YES;
}

@end
