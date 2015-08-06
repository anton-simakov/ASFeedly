//
//  RootViewController.m
//  Feedly Demo
//
//  Created by Anton Simakov on 12/25/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "RootViewController.h"
#import "Cell.h"
#import "CellItem.h"
#import "TableSection.h"

#import "ASFFeedly.h"
#import "ASFLogInViewController.h"

static NSString *const kClientID = @"sandbox";
static NSString *const kClientSecret = @""; // Put your client secret here

static NSString *const kCellIdentifier = @"ACell";

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, ASFLogInViewControllerDelegate>
{
    NSInteger _loadCounter;
}

@property (nonatomic, strong) UIBarButtonItem *refreshButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableSections;

@property (nonatomic, assign) BOOL presentedLogInViewController;
@property (nonatomic, strong) ASFFeedly *client;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _client = [[ASFFeedly alloc] initWithClientID:kClientID
                                         clientSecret:kClientSecret];
        _tableSections = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTableView:[[UITableView alloc] initWithFrame:[[self view] bounds]
                                                    style:UITableViewStyleGrouped]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAllowsSelection:NO];
    [_tableView registerClass:[Cell class] forCellReuseIdentifier:kCellIdentifier];
    [[self view] addSubview:_tableView];
    
    [self setRefreshButton:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                         target:self
                                                                         action:@selector(refresh:)]];
    [[self navigationItem] setRightBarButtonItem:_refreshButton];
    [[self navigationItem] setTitle:@"Feedly Demo"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [_tableView setFrame:[[self view] bounds]];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![self.client isAuthorized]) {
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
            [self updateTableSections:stream];
            [self updateTableView];
            
            _loadCounter--;
            
            if (_loadCounter == 0) {
                self.refreshButton.enabled = YES;
            }
        }
    }];
    _loadCounter++;
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender {
    self.refreshButton.enabled = NO;
    [self.tableSections removeAllObjects];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TableSection *tableSection = _tableSections[section];
    return [[tableSection items] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [self setupCell:cell forIndexPath:indexPath];
    return [cell calculateHeight:CGRectGetWidth([_tableView frame])];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_tableSections[section] header];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [self setupCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(Cell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    CellItem *cellItem = [self cellItemForIndexPath:indexPath];
    
    [cell setTitle:[cellItem title]];
    [cell setDate:[cellItem date]];
}

- (CellItem *)cellItemForIndexPath:(NSIndexPath *)indexPath
{
    TableSection *tableSection = _tableSections[[indexPath section]];
    NSArray *cellItems = [tableSection items];
    return cellItems[[indexPath row]];
}

- (void)updateTableSections:(ASFStream *)stream
{
    NSMutableArray *cellItems = [NSMutableArray array];
    
    for (ASFEntry *entry in [stream items])
    {
        CellItem *cellItem = [CellItem new];
        [cellItem setTitle:[entry title]];
        [cellItem setDate:[entry publishedAsDate]];
        
        [cellItems addObject:cellItem];
    }
    
    TableSection *tableSection = [TableSection new];
    
    [tableSection setHeader:[stream title]];
    [tableSection setItems:cellItems];
    
    [_tableSections addObject:tableSection];
}

- (void)updateTableView
{
    if (![_tableSections count])
    {
        return;
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[_tableSections count] - 1];
    
    [_tableView insertSections:indexSet
              withRowAnimation:UITableViewRowAnimationTop];
}

@end
