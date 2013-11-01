//
//  PeopleViewCell.m
//  InEvent
//
//  Created by Pedro Góes on 30/10/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "PeopleViewCell.h"
#import "ColorThemeController.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"

@implementation PeopleViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureCell];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureCell];
}

- (void)dealloc {
//    [self.initial removeObserver:self forKeyPath:@"bounds"];
}

- (void)configureCell {
//    [self addObserver:self forKeyPath:@"initial" options:NSKeyValueObservingOptionNew context:NULL];
//    [self addObserver:self forKeyPath:@"bounds" options:0 context:NULL];
    
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.2f];
    [self.initial setBackgroundColor:[ColorThemeController tableViewCellBackgroundColor]];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    [self.initial.layer setCornerRadius:self.initial.frame.size.width / 2.5f];
//}


#pragma mark - Public Methods

- (void)layoutInformation:(NSDictionary *)dictionary withDesiredWordCount:(NSInteger)wordCount {
    
    if ([[dictionary objectForKey:@"facebookID"] length] > 1) {
        [self.image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=%d&height=%d", [dictionary objectForKey:@"facebookID"], (int)(self.image.frame.size.width * [[UIScreen mainScreen] scale]), (int)(self.image.frame.size.height * [[UIScreen mainScreen] scale])]] placeholderImage:[UIImage imageNamed:@"128-user"]];
        [self.image setHidden:NO];
        [self.initial setHidden:YES];
    } else if ([[dictionary objectForKey:@"image"] length] > 1) {
        [self.image setImageWithURL:[NSURL URLWithString:[[dictionary objectForKey:@"image"] stringByDecodingHTMLEntities]] placeholderImage:[UIImage imageNamed:@"128-user"]];
        [self.image setHidden:NO];
        [self.initial setHidden:YES];
    } else if ([[dictionary objectForKey:@"name"] length] > 1) {
        
        if (wordCount == 2) {
            NSString *name = [[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities];
            NSMutableArray *split = [NSMutableArray arrayWithArray:[[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "]];
            if ([split count] > 1) {
                for (int i = 0; i < [split count]; i++) {
                    if ([[split objectAtIndex:i] length] == 0) [split removeObjectAtIndex:i];
                }
                
                self.initial.text = [NSString stringWithFormat:@"%@ %@.", [[split objectAtIndex:0] substringToIndex:1], [[split objectAtIndex:1] substringToIndex:1]];
            } else {
                self.initial.text = [name substringToIndex:1];
            }
        } else {
            self.initial.text = [[[dictionary objectForKey:@"name"] stringByDecodingHTMLEntities] substringToIndex:1];
        }

        [self.image setHidden:YES];
        [self.initial setHidden:NO];
    }
}

@end
