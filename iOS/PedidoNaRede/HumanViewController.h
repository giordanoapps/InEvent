//
//  HumanViewController.h
//  Garça
//
//  Created by Pedro Góes on 24/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@class FBProfilePictureView;

@interface HumanViewController : WrapperViewController <APIControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *photoWrapper;
@property (nonatomic, strong) IBOutlet FBProfilePictureView *photo;
@property (nonatomic, strong) IBOutlet UIImageView *defaultPhoto;
@property (nonatomic, strong) IBOutlet UILabel *introduction;
@property (nonatomic, strong) IBOutlet UIButton *name;

- (void)checkSession;

@end
