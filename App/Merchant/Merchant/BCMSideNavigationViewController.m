//
//  BCMSideNavigationViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSideNavigationViewController.h"

#import "MMDrawerController.h"

#import "AppDelegate.h"

#import "UIColor+Utilities.h"

typedef NS_ENUM(NSUInteger, BBSideNavigationItem) {
    BBSideNavigationItemPOS,
    BBSideNavigationItemTransactions,
    BBSideNavigationItemSettings,
    BBSideNavigationItemPriceNews,
    BBSideNavigationItemLogout,
    BBSideNavigationItemCount
};

static NSString *const kBCMSideNavControllerSalesId = @"BCMPOSNavigationId";
static NSString *const kBCMSideNavControllerTransactionsId = @"BCMTransactionsNavigationId";
static NSString *const kBCMSideNavControllerSettingsId = @"BCMSettingsNavigationId";
static NSString *const kBCMSideNavControllerNewsId = @"BCMNewsNavigationId";

@interface BCMSideNavigationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BCMSideNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerContainerView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BBSideNavigationItemCount;
}

static NSString *const kNavigationCellId = @"navigationCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:kNavigationCellId];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    cell.textLabel.textColor = [UIColor colorWithHexValue:@"a3a3a3"];

    NSString *navigationImageName = nil;
    NSString *navigationTitle = nil;

    switch (row) {
        case BBSideNavigationItemPOS: {
            navigationImageName = @"nav_pos";
            navigationTitle = NSLocalizedString(@"navigation.pos", nil);
            break;
        }
        case BBSideNavigationItemTransactions: {
            navigationImageName = @"nav_transactions";
            navigationTitle = NSLocalizedString(@"navigation.transactions", nil);
            break;
        }
        case BBSideNavigationItemSettings: {
            navigationImageName = @"nav_settings";
            navigationTitle = NSLocalizedString(@"navigation.settings", nil);
            break;
        }
        case BBSideNavigationItemPriceNews: {
            navigationImageName = @"nav_news";
            navigationTitle = NSLocalizedString(@"navigation.price_news", nil);
            break;
        }
        case BBSideNavigationItemLogout: {
            navigationImageName = @"nav_log_out";
            navigationTitle = NSLocalizedString(@"navigation.logout", nil);
            break;
        }
        default:
            break;
    }
    
    cell.imageView.image = [UIImage imageNamed:navigationImageName];
    cell.textLabel.text = navigationTitle;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    NSString *storyboardId = nil;
    
    switch (row) {
        case BBSideNavigationItemPOS: {
            storyboardId = kBCMSideNavControllerSalesId;
            break;
        }
        case BBSideNavigationItemTransactions: {
            storyboardId = kBCMSideNavControllerTransactionsId;
            break;
        }
        case BBSideNavigationItemSettings: {
            storyboardId = kBCMSideNavControllerSettingsId;
            break;
        }
        case BBSideNavigationItemPriceNews: {
            storyboardId = kBCMSideNavControllerNewsId;
            break;
        }
        case BBSideNavigationItemLogout: {
            break;
        }
        default:
            break;
    }
    
    if ([storyboardId length] > 0) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        MMDrawerController *drawer = delegate.drawerController;
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nextNavController = [mainStoryBoard instantiateViewControllerWithIdentifier:storyboardId];
        [drawer setCenterViewController:nextNavController withCloseAnimation:YES completion:nil];
    }
}

@end
