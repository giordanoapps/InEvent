//
//  AppDelegate.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, PaperFoldMenuControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController *menuController;

@end
