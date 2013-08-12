//
//  AboutViewController.h
//  Garça
//
//  Created by Pedro Góes on 05/08/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"

@interface AboutViewController : WrapperViewController

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIImageView *leftArrow;
@property (strong, nonatomic) IBOutlet UIWebView *aboutText;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)openLink:(id)sender;

@end
