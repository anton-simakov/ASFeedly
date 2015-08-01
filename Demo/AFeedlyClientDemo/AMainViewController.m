//
//  AMainViewController.m
//  AFeedlyClientDemo
//
//  Created by Anton Simakov on 12/25/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

#import "AMainViewController.h"
#import "ACell.h"
#import "ACellItem.h"
#import "ATableSection.h"

#import "AFeedlyClient.h"
#import "AFeedlyClientAuthenticationViewController.h"

static NSString *const kClientID = @"sandbox"; // Put your Client ID here
static NSString *const kClientSecret = @""; // Put your Client Secret here

static NSString *const kCellIdentifier = @"ACell";

@interface AMainViewController ()<UITableViewDelegate, UITableViewDataSource, AFeedlyClientDelegate>
{
    NSInteger _loadCounter;
}

@property(nonatomic, strong) UIBarButtonItem *refreshButton;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *tableSections;

@property(nonatomic, strong) AFeedlyClient *feedlyClient;

@end

@implementation AMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _feedlyClient = [[AFeedlyClient alloc] initWithClientID:kClientID
                                                   clientSecret:kClientSecret];
        [_feedlyClient setDelegate:self];
        
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
    [_tableView registerClass:[ACell class] forCellReuseIdentifier:kCellIdentifier];
    [[self view] addSubview:_tableView];
    
    [self setRefreshButton:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                         target:self
                                                                         action:@selector(refresh:)]];
    [[self navigationItem] setRightBarButtonItem:_refreshButton];
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
    ATableSection *tableSection = _tableSections[section];
    return [[tableSection items] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
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
    ACell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [self setupCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(ACell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    ACellItem *cellItem = [self cellItemForIndexPath:indexPath];
    
    [cell setTitle:[cellItem title]];
    [cell setDate:[cellItem date]];
}

- (ACellItem *)cellItemForIndexPath:(NSIndexPath *)indexPath
{
    ATableSection *tableSection = _tableSections[[indexPath section]];
    NSArray *cellItems = [tableSection items];
    return cellItems[[indexPath row]];
}

#pragma mark - AFeedlyClientDelegate

- (void)feedlyClientDidFinishLogin:(AFeedlyClient *)client
{
    [client getSubscriptions];
}

- (void)feedlyClient:(AFeedlyClient *)client didLoadSubscriptions:(NSArray *)subscriptions
{
    for (AFeedlyClientSubscription *subscription in subscriptions)
    {
        [client getStream:[subscription ID]
                    count:10
                  ranking:AFeedlyClientRankingNewest
               unreadOnly:YES
                newerThan:0
             continuation:nil];
        
        _loadCounter++;
    }
}

- (void)feedlyClient:(AFeedlyClient *)client didLoadStream:(AFeedlyClientStream *)stream
{
    [self updateTableSections:stream];
    [self updateTableView];
    
    _loadCounter--;
    
    if (_loadCounter == 0)
    {
        [_refreshButton setEnabled:YES];
    }
}

- (void)updateTableSections:(AFeedlyClientStream *)stream
{
    NSMutableArray *cellItems = [NSMutableArray array];
    
    for (AFeedlyClientEntry *entry in [stream items])
    {
        ACellItem *cellItem = [ACellItem new];
        [cellItem setTitle:[entry title]];
        [cellItem setDate:[entry publishedAsDate]];
        
        [cellItems addObject:cellItem];
    }
    
    ATableSection *tableSection = [ATableSection new];
    
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
    
    [self.feedlyClient loginWithViewController:self];
}

@end
