//
//  OrderItemViewCell.h
//  PedidoNaRede
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarketplaceViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *dateBegin;
@property (strong, nonatomic) IBOutlet UILabel *timeBegin;
@property (strong, nonatomic) IBOutlet UILabel *dateEnd;
@property (strong, nonatomic) IBOutlet UILabel *timeEnd;
@property (strong, nonatomic) IBOutlet UIButton *status;
@property (strong, nonatomic) IBOutlet UIView *line;

@property (assign, nonatomic) NSInteger approved;
@property (assign, nonatomic) NSInteger canEnroll;

- (void)configureCell;

@end
