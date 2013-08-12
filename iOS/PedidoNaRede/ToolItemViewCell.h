//
//  ToolItemViewCell.h
//  Garça
//
//  Created by Pedro Góes on 17/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolItemViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *iconImage;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *description;

- (void)configureCell;

@end
