//
//  OrderItemViewCell.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderItemViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *orderPlate;
@property (strong, nonatomic) IBOutlet UILabel *orderTitle;
@property (strong, nonatomic) IBOutlet UIControl *orderStatusView;
@property (strong, nonatomic) IBOutlet UILabel *orderStatusHint;
@property (strong, nonatomic) IBOutlet UILabel *orderAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderAmount;

@property (strong, nonatomic) NSString *orderStatusBuffer;
@property (assign, nonatomic) NSInteger *orderStatusID;

- (void)configureCell;

@end
