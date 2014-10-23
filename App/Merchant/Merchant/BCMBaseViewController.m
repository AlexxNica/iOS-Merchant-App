//
//  BCMBaseViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMBaseViewController.h"

#import "MMDrawerController.h"

#import "AppDelegate.h"

@interface BCMBaseViewController ()

@property (assign, nonatomic) BCMNavigationType leftNavigationType;
@property (assign, nonatomic) BCMNavigationType rightNavigationType;

@end

@implementation BCMBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"block_chain_header_logo"]];
}

- (void)addNavigationType:(BCMNavigationType)type position:(BCMNavigationPosition)position selector:(SEL)selector
{
    NSString *imageName = nil;
    
    switch (type) {
        case BCMNavigationTypeHamburger:
            imageName = @"hamburger";
            break;
        default:
            break;
    }
    
    SEL barButtonSelector = @selector(navigationSelector:);
    if (selector) {
        barButtonSelector = selector;
    }
    UIImage *barButtonImage = [UIImage imageNamed:imageName];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self action:barButtonSelector];
    barButtonItem.tintColor = [UIColor whiteColor];
    
    if (position == BCMNavigationPositionRight) {
        self.rightNavigationType = type;
        self.navigationItem.rightBarButtonItem = barButtonItem;
    } else if (position == BCMNavigationPositionLeft) {
        self.leftNavigationType = type;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
}

- (void)navigationSelector:(id)sender
{
    BCMNavigationType navigationType = BCMNavigationTypeNone;
    if (self.navigationItem.rightBarButtonItem == sender) {
        navigationType = self.rightNavigationType;
    } else if (self.navigationItem.leftBarButtonItem == sender) {
        navigationType = self.leftNavigationType;
    }
    
    switch (navigationType) {
        case BCMNavigationTypeHamburger: {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            MMDrawerController *drawerController = appDelegate.drawerController;
            [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
