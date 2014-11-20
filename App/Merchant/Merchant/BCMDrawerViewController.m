//
//  BCMDrawerViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMDrawerViewController.h"

#import "AppDelegate.h"

#import "Foundation-Utility.h"

NSString *const kBCMSideNavigationViewControllerId = @"BCMSideNavigationViewControllerId";
NSString *const kBCMSideNavControllerSalesId = @"BCMPOSNavigationId";                   // POS
NSString *const kBCMSideNavControllerItemSetupId = @"BCMItemSetupNavigationId";                   // POS
NSString *const kBCMSideNavControllerTransactionsId = @"BCMTransactionsNavigationId";   // Transactions
NSString *const kBCMSideNavControllerSettingsId = @"BCMSettingsNavigationId";           // Settings
NSString *const kBCMSideNavControllerNewsId = @"BCMNewsNavigationId";                   // News

@interface BCMDrawerViewController ()

@property (strong, nonatomic) NSMutableDictionary *viewControllerDict;

@end

@implementation BCMDrawerViewController

- (instancetype)init
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *centerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMSideNavControllerSalesId];
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMSideNavigationViewControllerId];
    
    self = [super initWithCenterViewController:centerViewController leftDrawerViewController:leftViewController];
    
    if (self) {
        _viewControllerDict = [[NSMutableDictionary alloc] init];
        [_viewControllerDict setObject:centerViewController forKey:kBCMSideNavControllerSalesId];
    }
    
    return self;
}

- (void)showDetailViewControllerWithId:(NSString *)viewControllerId
{
    UIViewController *viewController = [self.viewControllerDict safeObjectForKey:viewControllerId];
    // Lazy loading required view controllers
    if (!viewController) {
        NSString *storyboardId = nil;
        if ([viewControllerId isEqualToString:kBCMSideNavControllerSalesId]) {
            storyboardId = kBCMSideNavControllerSalesId;
        } else if ([viewControllerId isEqualToString:kBCMSideNavControllerTransactionsId]) {
            storyboardId = kBCMSideNavControllerTransactionsId;
        } else if ([viewControllerId isEqualToString:kBCMSideNavControllerSettingsId]) {
            storyboardId = kBCMSideNavControllerSettingsId;
        } else if ([viewControllerId isEqualToString:kBCMSideNavControllerNewsId]) {
            storyboardId = kBCMSideNavControllerNewsId;
        } else if ([viewControllerId isEqualToString:kBCMSideNavControllerItemSetupId]) {
            storyboardId = kBCMSideNavControllerItemSetupId;
        }
        if ([storyboardId length] > 0) {
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            viewController = [mainStoryBoard instantiateViewControllerWithIdentifier:storyboardId];
            if (![storyboardId isEqualToString:kBCMSideNavControllerSettingsId]) {
                [self.viewControllerDict setObject:viewController forKey:storyboardId];
            }
        }
    }
    
    [self setCenterViewController:viewController withCloseAnimation:YES completion:nil];
}

@end
