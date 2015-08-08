//
//  RootViewController.m
//  Feedly Demo
//
//  Created by Anton Simakov on 12/25/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "RootViewController.h"
#import "Cell.h"

#import "ASFFeedly.h"
#import "ASFLogInViewController.h"

static NSString *const kClientID = @"sandbox";
static NSString *const kClientSecret = @""; // Client Secret

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, ASFLogInViewControllerDelegate>

@property (nonatomic, assign) NSUInteger loadCount;
@property (nonatomic, assign) BOOL presentedLogInViewController;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *streams;
@property (nonatomic, strong) ASFFeedly *client;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _client = [[ASFFeedly alloc] initWithClientID:kClientID
                                         clientSecret:kClientSecret];
        _streams = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Feedly Demo", nil);
    
    self.refreshButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                  target:self
                                                  action:@selector(refresh:)];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    
    [self.tableView registerClass:[Cell class]
           forCellReuseIdentifier:NSStringFromClass([Cell class])];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.client isAuthorized]) {
        [self refresh:self];
    } else {
        [self presentLogInViewController:animated];
    }
}

- (void)presentLogInViewController:(BOOL)animated {
    if (self.presentedLogInViewController) {
        return;
    }
    
    self.presentedLogInViewController = YES;
    ASFLogInViewController *logInViewController = [[ASFLogInViewController alloc] init];
    logInViewController.delegate = self;
    logInViewController.clientID = kClientID;
    [self presentViewController:logInViewController animated:animated completion:nil];
}

- (void)loadSubscriptions {
    [self.client subscriptions:^(NSArray *subscriptions, NSError *error) {
        if (error) {
            // TODO:
        } else {
            for (ASFSubscription *subscription in subscriptions) {
                [self loadStream:subscription.ID];
            }
        }
    }];
}

- (void)loadStream:(NSString *)streamID {
    [self.client stream:streamID completion:^(ASFStream *stream, NSError *error) {
        if (error) {
            // TODO:
        } else {
            [self addStream:stream];
            
            if (!--self.loadCount) {
                self.refreshButton.enabled = YES;
            }
        }
    }];
    self.loadCount++;
}

- (void)addStream:(ASFStream *)stream {
    [self.streams addObject:stream];
    [self insertStream:stream];
}

- (void)insertStream:(ASFStream *)stream {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.streams.count - 1];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender {
    self.refreshButton.enabled = NO;
    [self.streams removeAllObjects];
    [self.tableView reloadData];
    [self loadSubscriptions];
}

#pragma mark - ASFLogInViewControllerDelegate

- (void)logInViewController:(ASFLogInViewController *)logInViewController didFinish:(NSError *)error {
    if (self.presentedLogInViewController) {
        self.presentedLogInViewController = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.streams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ASFStream *stream = self.streams[section];
    return stream.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell calculateHeight:CGRectGetWidth([_tableView frame])];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ASFStream *stream = self.streams[section];
    return stream.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([Cell class])];
    
    ASFStream *stream = self.streams[indexPath.section];
    ASFEntry *entry = stream.items[indexPath.row];
    
    cell.title = entry.title;
    cell.date = entry.published;
    
    return cell;
}

@end
