//
//  BCMItemSetupViewController.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMItemSetupViewController.h"

#import "BCMAddItem.h"

#import "BCMSearchView.h"

#import "Item.h"

#import "BCMMerchantManager.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

@interface BCMItemSetupViewController () <BCMAddItemViewProtocol, BCMSearchViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *clearSearchButton;


@property (strong, nonatomic) NSArray *merchantItems;
@property (strong, nonatomic) NSArray *filteredMerchantItems;

@property (weak, nonatomic) IBOutlet UIView *searchContainerView;

@property (strong, nonatomic) UIView *whiteOverlayView;
@property (strong, nonatomic) BCMSearchView *searchView;

@end

@implementation BCMItemSetupViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.clearSearchButton.alpha = 0.0f;
    
    if (![self isModal]) {
        [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    } else {
        [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:nil];
    }
    
    if (!self.whiteOverlayView) {
        self.whiteOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.whiteOverlayView.backgroundColor = [UIColor whiteColor];
        self.whiteOverlayView.alpha = 0.0f;
        [self.view addSubview:self.whiteOverlayView];
    }
    
    if (!self.searchView) {
        self.searchView = [BCMSearchView loadInstanceFromNib];
        self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
        self.searchView.delegate = self;
        [self.searchContainerView addSubview:self.searchView];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *bomttomConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];
        
        [self.searchContainerView addConstraints:@[ topConstraint, bomttomConstraint, leftConstraint, rightConstraint]];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.itemsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.itemsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.itemsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.merchantItems = [[BCMMerchantManager sharedInstance] itemsSortedByCurrentSortType];
    self.itemsTableView.tableFooterView = [[UIView alloc] init];
}

- (void)showAddItemViewWithItem:(Item *)item
{
    if (self.whiteOverlayView.alpha == 0.0f) {
        [self.view bringSubviewToFront:self.whiteOverlayView];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.whiteOverlayView.alpha = 1.0f;
        }];
        
        BCMAddItem *itemView = [BCMAddItem loadInstanceFromNib];
        itemView.item = item;
        itemView.delegate = self;

        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:itemView];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:376.0f];
        NSLayoutConstraint *verticalOffsetConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:298.0f];
        NSLayoutConstraint *horizontalCenterConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:heightConstraint];
        [self.view addConstraint:verticalOffsetConstraint];
        [self.view addConstraint:widthConstraint];
        [self.view addConstraint:horizontalCenterConstraint];
    }
}

- (void)reloadItemTableViewOnMainThread
{
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.itemsTableView reloadData];
    });
}

#pragma mark - Actions

- (IBAction)clearSearchAction:(id)sender
{
    [self.searchView clear];
}

- (IBAction)addAction:(id)sender
{
    [self showAddItemViewWithItem:nil];
}

- (IBAction)doneAction:(id)sender
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - BCMAddItemViewDelegate

- (void)dismissAddItemView:(BCMAddItem *)itemView
{
    [itemView removeFromSuperview];
    [UIView animateWithDuration:0.25f animations:^{
        self.whiteOverlayView.alpha = 0.0f;
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;

    if ([self.searchView.searchString length] > 0) {
        rowCount = [self.filteredMerchantItems count];
    } else {
        rowCount = [self.merchantItems count];
    }
    
    return rowCount;
}

static NSString *const kMerchantItemDefaultCellId = @"merchantItemCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    Item *item = nil;
    if ([self.searchView.searchString length] > 0) {
        item = [self.filteredMerchantItems objectAtIndex:row];
    } else {
        item  = [self.merchantItems objectAtIndex:row];
    }
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kMerchantItemDefaultCellId];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = item.name;
    NSString *currencySign = [[BCMMerchantManager sharedInstance] currencySymbol];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%.2f", currencySign, [item.price floatValue]];
    
    return cell;
}

const CGFloat kBBMerchantItemDefaultRowHeight = 38.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBMerchantItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.merchantItems objectAtIndex:indexPath.row];
    [self showAddItemViewWithItem:item];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = YES;
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;

    Item *item = nil;
    if ([self.searchView.searchString length] > 0) {
        item = [self.filteredMerchantItems objectAtIndex:row];
    } else {
        item  = [self.merchantItems objectAtIndex:row];
    }
    
    [item MR_deleteEntity];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [self reloadItemTableViewOnMainThread];
    }];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - BCMSearchViewDelegate

- (void)searchView:(BCMSearchView *)searchView didUpdateText:(NSString *)searchText
{
    if ([searchText length] > 0) {
        self.clearSearchButton.alpha = 1.0f;
        [self.searchContainerView bringSubviewToFront:self.clearSearchButton];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.1
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        self.filteredMerchantItems = [NSMutableArray arrayWithArray:[self.merchantItems filteredArrayUsingPredicate:predicate]];
    } else {
        self.clearSearchButton.alpha = 0.0f;
        self.filteredMerchantItems = nil;
    }
    [self.itemsTableView reloadData];
}

#pragma mark - BCMAddItemViewDelegate

- (void)addItemViewDidCancel:(BCMAddItem *)itemView
{
    [self dismissAddItemView:itemView];
}

- (void)addItemView:(BCMAddItem *)itemView didSaveItem:(Item *)item
{
    if (item) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissAddItemView:itemView];
            });
            [self reloadItemTableViewOnMainThread];
        }];
    }
}

@end
