//
//  ReaderViewCell.h
//  InEvent
//
//  Created by Pedro Góes on 08/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *enrollmentID;
@property (strong, nonatomic) IBOutlet UILabel *name;

- (void)configureCell;

@end
