//
//  FeedbackViewController.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 24/02/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WrapperViewController.h"
#import "APIController.h"

@class UIPlaceHolderTextView;

@interface FeedbackViewController : WrapperViewController <APIControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *box;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *messageBox;
@property (strong, nonatomic) IBOutlet UIButton *message;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UIButton *star1;
@property (strong, nonatomic) IBOutlet UIButton *star2;
@property (strong, nonatomic) IBOutlet UIButton *star3;
@property (strong, nonatomic) IBOutlet UIButton *star4;
@property (strong, nonatomic) IBOutlet UIButton *star5;

- (IBAction)processStarTap:(id)sender;
- (IBAction)sendForm:(id)sender;

@end
