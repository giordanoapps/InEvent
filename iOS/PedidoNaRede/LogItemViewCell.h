//
//  LogItemViewCell.h
//  Garça
//
//  Created by Pedro Góes on 11/04/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BenchView;

@interface LogItemViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet BenchView *table;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImage;
@property (nonatomic, strong) IBOutlet UILabel *numberItems;
@property (nonatomic, strong) IBOutlet UILabel *numberItemsText;
@property (nonatomic, strong) IBOutlet UILabel *numberSentItems;
@property (nonatomic, strong) IBOutlet UILabel *numberSentItemsText;

- (void)configureCell;

@end
