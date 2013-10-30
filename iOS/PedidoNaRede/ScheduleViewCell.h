//
//  ScheduleItemViewCell.h
//  InEvent
//
//  Created by Pedro Góes on 08/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UILabel *hour;
@property (strong, nonatomic) IBOutlet UILabel *minute;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UITextView *description;

@property (assign, nonatomic) NSInteger approved;

@end
