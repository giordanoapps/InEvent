//
//  LogViewController.m
//  Garça
//
//  Created by Pedro Góes on 11/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "LogViewController.h"
#import "LogItemViewCell.h"
#import "ColorThemeController.h"
#import "BenchView.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Log", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [ColorThemeController tableViewCellBorderColor];
    self.tableView.rowHeight = 109;
    self.tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.orderNotifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LogItemViewCell *cell = (LogItemViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:@"LogItemViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = (LogItemViewCell *)[self.tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [self.orderNotifications objectAtIndex:indexPath.row];
    
    cell.table = (BenchView *)[dictionary objectForKey:@"table"];
    cell.numberItems.text = [dictionary objectForKey:@"numberItems"];
    cell.numberSentItems.text = [dictionary objectForKey:@"numberSentItems"];
    
    return cell;
}

@end
