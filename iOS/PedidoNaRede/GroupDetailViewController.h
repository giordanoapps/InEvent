//
//  GroupDetailViewController.h
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface GroupDetailViewController : WrapperViewController <InEventAPIControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UIView *wrapper;
@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *description;
@property (nonatomic, strong) IBOutlet UITextField *location;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSDictionary *groupData;
@property (strong, nonatomic) NSArray *peopleData;

@end
