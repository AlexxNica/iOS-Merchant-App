//
//  BCMPriceNewsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPriceNewsViewController.h"

@interface BCMPriceNewsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BCMPriceNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://zeroblock.com/mobile"]]];
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
}

@end
