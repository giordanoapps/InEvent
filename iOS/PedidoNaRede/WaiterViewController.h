//
//  WaiterViewController.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 02/01/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@interface WaiterViewController : WrapperViewController <UIAlertViewDelegate, APIControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)cancel:(id)sender;

@end
