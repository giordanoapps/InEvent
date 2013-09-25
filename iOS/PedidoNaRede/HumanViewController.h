//
//  HumanViewController.h
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@class FBProfilePictureView;

@interface HumanViewController : WrapperViewController

@property (nonatomic, strong) IBOutlet UIView *photoWrapper;
@property (nonatomic, strong) IBOutlet FBProfilePictureView *photo;
@property (nonatomic, strong) IBOutlet UIImageView *defaultPhoto;
@property (nonatomic, strong) IBOutlet UILabel *introduction;
@property (nonatomic, strong) IBOutlet UIButton *name;

@end
