//
//  ToolViewController.m
//  Garça
//
//  Created by Pedro Góes on 17/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "ToolViewController.h"
#import "ToolItemViewCell.h"
#import "ColorThemeController.h"

@interface ToolViewController () {
    NSArray *images;
    NSArray *titles;
    NSArray *descriptions;
}

@end

@implementation ToolViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    images = @[@"egretBlue", @"egretGreen", @"egretOrange", @"egretPurple"];
    titles = @[NSLocalizedString(@"Waiter", nil), NSLocalizedString(@"Order", nil), NSLocalizedString(@"Reservation", nil), NSLocalizedString(@"Chat", nil)];
    descriptions = @[NSLocalizedString(@"Easy way to call the waiter", nil), NSLocalizedString(@"Order directly from your table!", nil), NSLocalizedString(@"Make a reservation from home", nil), NSLocalizedString(@"Talk to anyone on the bar", nil)];
    
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
    return [images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ToolItemViewCell *cell = (ToolItemViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:@"ToolItemViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = (ToolItemViewCell *)[self.tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    }
    
    [cell configureCell];
    
    cell.iconImage.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    cell.name.text = [titles objectAtIndex:indexPath.row];
    cell.description.text = [descriptions objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
