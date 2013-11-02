//
//  PeopleViewCell.h
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *initial;
@property (strong, nonatomic) IBOutlet UIImageView *image;

- (void)layoutInformation:(NSDictionary *)dictionary withDesiredWordCount:(NSInteger)wordCount;

@end
