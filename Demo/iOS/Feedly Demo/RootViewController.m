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

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource, ASFDelegate>
{
    NSInteger _loadCounter;
}

@property(nonatomic, strong) UIBarButtonItem *refreshButton;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *tableSections;

@property(nonatomic, strong) ASFFeedly *client;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _client = [[ASFFeedly alloc] initWithClientID:kClientID
                                         clientSecret:kClientSecret];
        [_client setDelegate:self];
        
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

- (void)reset
{
    [_tableSections removeAllObjects];
    [_tableView reloadData];
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

#pragma mark - ASFDelegate

- (void)feedlyClientDidFinishLogin:(ASFFeedly *)client
{
    [client getSubscriptions];
}

- (void)feedlyClient:(ASFFeedly *)client didLoadSubscriptions:(NSArray *)subscriptions
{
    for (ASFSubscription *subscription in subscriptions)
    {
        [client getStream:[subscription ID]
                    count:10
                  ranking:ASFNewest
               unreadOnly:YES
                newerThan:0
             continuation:nil];
        
        _loadCounter++;
    }
}

- (void)feedlyClient:(ASFFeedly *)client didLoadStream:(ASFStream *)stream
{
    [self updateTableSections:stream];
    [self updateTableView];
    
    _loadCounter--;
    
    if (_loadCounter == 0)
    {
        [_refreshButton setEnabled:YES];
    }
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

#pragma mark - Actions

- (void)refresh:(id)sender
{
    self.refreshButton.enabled = NO;
    
    [self reset];
    
    [self.client loginWithViewController:self];
}

@end
