//
//  ASFLogInViewController.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "ASFLogInViewController.h"
#import "ASFConstants.h"
#import "ASFFeedly.h"
#import "ASFUtil.h"

static NSString *_code;

@interface ASFLogInViewController ()<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;

@end

@implementation ASFLogInViewController

+ (NSString *)code {
    return _code;
}

- (id)initWithCliendID:(NSString *)clientID delegate:(id<ASFLogInViewControllerDelegate>)delegate
{
    self = [super init];
    
    if (self)
    {
        _clientID = clientID;
        _delegate = delegate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setWebView:[[UIWebView alloc] initWithFrame:[[self view] frame]]];
    
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_webView setDelegate:self];
    
    [[self view] addSubview:_webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self start];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    NSString *absoluteString = [[request URL] absoluteString];
    
    if (![absoluteString hasPrefix:ASFRedirectURI]) {
        return YES;
    }
    
    NSDictionary *parameters = ASFParametersFromQuery(ASFQueryFromURL(URL));
    
    _code = parameters[@"code"];
    
    if ([self.delegate respondsToSelector:@selector(logInViewController:didFinish:)]) {
        [self.delegate logInViewController:self didFinish:nil];
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
    return NO;
}

- (void)start
{
    NSDictionary *parameters = @{@"client_id" : _clientID,
                                 @"redirect_uri" : ASFRedirectURI,
                                 ASFResponseTypeKey : @"code",
                                 ASFScopeKey : @"https://cloud.feedly.com/subscriptions"};
    
    NSURL *URL = [ASFUtil URLWithString:[NSString stringWithFormat:@"%@/%@", ASFEndpoint, ASFAuthAuthPath]
                             parameters:parameters];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [_webView loadRequest:request];
}

@end
