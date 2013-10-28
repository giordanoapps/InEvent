//
//  PeopleViewController.h
//  InEvent
//
//  Created by Pedro Góes on 14/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WrapperViewController.h"
#import "APIController.h"

@interface PeopleViewController : WrapperViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, APIControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIView *addGroupView;
@property (strong, nonatomic) IBOutlet UITextField *nameInput;
@property (strong, nonatomic) IBOutlet UIButton *addGroupButton;

@end
