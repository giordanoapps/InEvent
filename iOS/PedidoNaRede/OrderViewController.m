//
//  OrderViewController.m
//  PedidoNaRede
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderItemViewCell.h"
#import "CarteItemViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UIViewController+Present.h"
#import "UIImageView+WebCache.h"
#import "ODRefreshControl.h"
#import "TableToken.h"
#import "UIViewController+AKTabBarController.h"
#import "NSString+HTML.h"
#import "HumanToken.h"
#import "GAI.h"

@interface OrderViewController () {
    ODRefreshControl *refreshControl;
    NSDictionary *lastOrder;
}

@property (strong, nonatomic) NSMutableArray *itemsData;

@end

@implementation OrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [self tabTitle];
        self.accessibilityLabel = [self tabTitle];
        self.itemsData = [NSMutableArray array];
        
        // Add notification observer for new orders
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendOrder:) name:@"sendOrder" object:nil];
    }
    return self;
}

#pragma mark - AKTabBarController Category

- (NSString *)tabTitle {
    return NSLocalizedString(@"Order", nil);
}

- (NSString *)tabImageName {
    return @"32-Shopping-Basket";
}

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [ColorThemeController tableViewCellBorderColor];
    _tableView.rowHeight = 100;
    _tableView.backgroundColor = [ColorThemeController tableViewBackgroundColor];
    
    // Refresh Control
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Add notification observer for data updates (should reload data)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"updateNonCarte" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:@"orderNotification" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification

- (void)loadData {
    
    if ([self verifyTable]) {
        // Send any orders left on the stack
        if (lastOrder != nil) {
            [self sendOrder:[NSNotification notificationWithName:@"sendOrder" object:self userInfo:lastOrder]];
            lastOrder = nil;
        }
        
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[APIController alloc] initWithDelegate:self forcing:YES] orderGetOrdersForPerson:0 withToken:tokenID];
    }
}

- (void)processNotification:(NSNotification *)notification {
    [self loadData];
}

#pragma mark - Public Methods

- (void)sendOrder:(NSNotification *)notification {
    
    if ([[HumanToken sharedInstance] isMemberAuthenticated] || [self verifyTable]) {
        
        NSDictionary *userInfo = [notification userInfo];
        NSMutableDictionary *complete = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        
        // Process some of the properties
        NSInteger itemID = [[[userInfo objectForKey:@"item"] objectForKey:@"id"] integerValue];
        NSInteger amount = [[userInfo objectForKey:@"amount"] integerValue];
        NSInteger personID = [[userInfo objectForKey:@"personID"] integerValue];
        NSMutableSet *options = [userInfo objectForKey:@"orderOptions"];
        if (!options) options = [NSMutableSet setWithCapacity:0];
    
        // Set the new properties
        [complete setObject:@"..." forKey:@"title"];
        [complete setObject:@"..." forKey:@"hint"];
        [complete setObject:@"#FFFFFF" forKey:@"color"];
        [self.itemsData insertObject:complete atIndex:0];
        
        // Send the order to our servers
        NSString *tokenID = [[HumanToken sharedInstance] tokenID];
        [[[APIController alloc] initWithDelegate:self forcing:YES withUserInfo:userInfo] orderSendOrderForPerson:personID withItem:itemID withAmount:amount withOptions:options withToken:tokenID];
        
        // Reload the table
        [self.tableView reloadData];
        
    } else {
        lastOrder = [notification userInfo];
    }

//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.itemsData count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemsData count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CustomCellIdentifier = @"CustomCellIdentifier";
    OrderItemViewCell * cell = (OrderItemViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    if (cell == nil) {
        [aTableView registerNib:[UINib nibWithNibName:@"OrderItemViewCell" bundle:nil] forCellReuseIdentifier:CustomCellIdentifier];
        cell =  (OrderItemViewCell *)[aTableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    }
    
    [cell configureCell];
    
    NSDictionary *dictionary = [self.itemsData objectAtIndex:indexPath.row];
    
    if ([[[dictionary objectForKey:@"item"] objectForKey:@"images"] count] > 0) {
        [cell.orderPlate setImageWithURL:[UtilitiesController urlWithFile:[[[[dictionary objectForKey:@"item"] objectForKey:@"images"] objectAtIndex:0] objectForKey:@"image"]]];
    } else {
        [cell.orderPlate setImageWithURL:[UtilitiesController urlWithFile:@"images/128-item.png"]];
    }
    cell.orderTitle.text = [[[dictionary objectForKey:@"item"] objectForKey:@"title"] stringByDecodingHTMLEntities];
    cell.orderStatusView.backgroundColor = [UtilitiesController colorFromHexString:[dictionary objectForKey:@"color"]];
    cell.orderStatusHint.text = [[dictionary objectForKey:@"hint"] stringByDecodingHTMLEntities];
    cell.orderStatusBuffer = [[dictionary objectForKey:@"title"] stringByDecodingHTMLEntities];
    cell.orderAmount.text = [dictionary objectForKey:@"amount"];
    cell.orderStatusID = [[dictionary objectForKey:@"statusID"] integerValue];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CarteItemViewController *mivc;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mivc = [[CarteItemViewController alloc] initWithNibName:@"CarteItemViewController" bundle:nil];
    } else {
        // Find the sibling navigation controller first child and send the appropriate data
        mivc = (CarteItemViewController *)[[[self.splitViewController.viewControllers lastObject] viewControllers] objectAtIndex:0];
    }
    
    [mivc setOrderOptions:[[self.itemsData objectAtIndex:indexPath.row] objectForKey:@"orderOptions"]];
    [mivc setItemData:[[self.itemsData objectAtIndex:indexPath.row] objectForKey:@"item"]];
    [mivc setOrderMode:NO];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:mivc animated:YES];
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - APIController Delegate

- (void)apiController:(APIController *)apiController didLoadDictionaryFromServer:(NSDictionary *)dictionary {
    
    if ([apiController.method isEqualToString:@"sendOrder"]) {
        // Get the properties
        NSInteger index = [self.itemsData indexOfObject:apiController.userInfo];
        NSArray *data = [dictionary objectForKey:@"data"];
        
        // Only replace if we are sure that the indexes are properly secured
        if ([data count] > 0 && index != NSNotFound) {
            
            // Get the order object
            NSDictionary *order = [data objectAtIndex:0];
            
            [self.itemsData replaceObjectAtIndex:index withObject:order];
        }
        
    } else if ([apiController.method isEqualToString:@"getOrders"]) {
        // Update all the orders keeping a mutable array for compatibility
        self.itemsData = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"data"]];
        
        [self.tableView reloadData];
    }
    
    [refreshControl endRefreshing];
}

@end
