//
//  Allocation.m
//  Allocation
//
//  Created by Pedro Góes on 01/05/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "Allocation.h"

@implementation Allocation

- (void)setUp {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    menuViewController = appDelegate.menuController;
}

- (void)testAppDelegate {
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
}

- (void)testMenu {
    STAssertNotNil(menuViewController, @"Cannot find the root view controller");
}

@end
