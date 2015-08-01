//
//  AFeedlyClientAuthenticationViewController.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/1/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AFeedlyClientAuthenticationViewController.h"
#import "AFeedlyClientConstants.h"
#import "AFeedlyClientUtility.h"

@interface AFeedlyClientAuthenticationViewController ()<UIWebViewDelegate>

@property(nonatomic, strong) NSString *clientID;
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation AFeedlyClientAuthenticationViewController

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"You cannot init this class directly. Instead, use the designated initializer"
                                 userInfo:nil];
}

- (id)initWithCliendID:(NSString *)clientID delegate:(id<AFeedlyClientAuthenticationViewControllerDelegate>)delegate
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringURL = [[request URL] absoluteString];
    
    if ([stringURL hasPrefix:kFeedlyRedirectURI])
    {
        NSUInteger codeLocation  = [stringURL rangeOfString:kFeedlyCodeKey].location + 5; // + 5 for "code="
        NSUInteger stateLocation = [stringURL rangeOfString:kFeedlyStateKey].location - 1; // - 1 for "&"
        
        NSUInteger codeLength = stateLocation - codeLocation;
        
        NSString *code = [stringURL substringWithRange:NSMakeRange(codeLocation, codeLength)];
        
        [_delegate feedlyClientAuthenticationViewController:self
                                          didFinishWithCode:code];
        
        [self dismissViewControllerAnimated:YES completion:NULL];

        return NO;
    }

    return YES;
}

- (void)start
{
    NSDictionary *parameters = @{kFeedlyClientIDKey : _clientID,
                                 kFeedlyRedirectURIKey : kFeedlyRedirectURI,
                                 kFeedlyResponseTypeKey : kFeedlyResponseTypeCode,
                                 kFeedlyScopeKey : @"https://cloud.feedly.com/subscriptions"};
    
    NSURL *URL = [AFeedlyClientUtility URLWithPath:kFeedlyAuthAuthPath parameters:parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [_webView loadRequest:request];
}

@end
