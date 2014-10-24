//
//  BCMSettingsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSettingsViewController.h"

@interface BCMSettingsViewController ()

@end

@implementation BCMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
}

@end
