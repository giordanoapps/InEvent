//
//  LauchImageViewController.m
//  Garça
//
//  Created by Pedro Góes on 27/03/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import "LauchImageViewController.h"

@interface LauchImageViewController ()

@end

@implementation LauchImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
