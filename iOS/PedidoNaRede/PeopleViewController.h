//
//  PeopleViewController.h
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface PeopleViewController : WrapperViewController <InEventAPIControllerDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
