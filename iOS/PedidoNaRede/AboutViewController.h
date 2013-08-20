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

@property (strong, nonatomic) IBOutlet UIButton *productImage;
@property (strong, nonatomic) IBOutlet UIButton *companyImage;
@property (strong, nonatomic) IBOutlet UIImageView *leftArrow;
@property (strong, nonatomic) IBOutlet UIWebView *aboutText;

- (IBAction)openProductPage:(id)sender;
- (IBAction)openCompanyPage:(id)sender;

@end
