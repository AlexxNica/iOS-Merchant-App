//
//  BCMPOSViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPOSViewController.h"
#import "BCMItemSetupViewController.h"
#import "BCMCustomAmountView.h"
#import "BCMSearchView.h"
#import "BCMTextField.h"
#import "BCMQRCodeTransactionView.h"

#import "Item.h"
#import "Transaction.h"
#import "PurchasedItem.h"

#import "UIView+Utilities.h"

typedef NS_ENUM(NSUInteger, BCMPOSSection) {
    BCMPOSSectionCustomItem,
    BCMPOSSectionItems,
    BCMPOSSectionCount
};

@interface BCMPOSViewController () <BCMCustomAmountViewDelegate, BCMQRCodeTransactionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalTransactionAmountLbl;
@property (weak, nonatomic) IBOutlet UILabel *transactionItemCountLbl;

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) NSArray *merchantItems;
@property (strong, nonatomic) NSMutableArray *simpleItems;

@property (strong, nonatomic) IBOutlet UIView *customAmountContainerView;
@property (strong, nonatomic) IBOutlet BCMCustomAmountView *customAmountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;

@property (strong, nonatomic) IBOutlet UIView *searchContainerView;
@property (strong, nonatomic) BCMSearchView *searchView;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) BCMQRCodeTransactionView *transactionView;
@property (strong, nonatomic) UIControl *trasactionOverlay;

@end

@implementation BCMPOSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.simpleItems = [[NSMutableArray alloc] init];
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    
    self.customAmountView = [BCMCustomAmountView loadInstanceFromNib];
    self.customAmountView.delegate = self;
    self.customAmountView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customAmountContainerView addSubview:self.customAmountView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeBottomMargin relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeBottomMargin multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeLeftMargin relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeLeftMargin multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.customAmountView attribute:NSLayoutAttributeRightMargin relatedBy:NSLayoutRelationEqual toItem:self.customAmountContainerView attribute:NSLayoutAttributeRightMargin multiplier:1.0 constant:0.0f];

    [self.customAmountContainerView addConstraints:@[ topConstraint, bottomConstraint, leftConstraint, rightConstraint ]];
    
    self.topMarginConstraint.constant = CGRectGetHeight(self.view.frame);
    
    self.searchView = [BCMSearchView loadInstanceFromNib];
    self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchContainerView addSubview:self.searchView];
    
    [self.searchContainerView addSubview:self.editButton];
    
    NSLayoutConstraint *topSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *bottomSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *leftSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchContainerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *rightSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.editButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0f];
    
    [self.searchContainerView addConstraints:@[ topSearchViewConstraint, bottomSearchViewConstraint, leftSearchViewConstraint, rightSearchViewConstraint]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];

    [self updateTransctionInformation];
    
    [self.itemsTableView reloadData];
}

- (void)hideTransactionView
{
    [self.trasactionOverlay removeFromSuperview];
    self.trasactionOverlay.alpha = 0.25f;
    [self.transactionView removeFromSuperview];
}

#pragma mark - Actions

- (void)dismissCharge:(id)sender
{
    [self hideTransactionView];
}

- (IBAction)chargeAction:(id)sender
{
    // Create transaction for purchase
    Transaction *transaction = [Transaction MR_createEntity];
    transaction.creation_date = [NSDate date];
    
    // Create purchased items
    for (NSDictionary *dict in self.simpleItems) {
        // Creating purchased items from known items in transactin
        PurchasedItem *pItem = [PurchasedItem MR_createEntity];
        pItem.name = [dict objectForKeyedSubscript:kItemNameKey];
        pItem.price = [dict objectForKeyedSubscript:kItemPriceKey];
        [transaction addPurchasedItemsObject:pItem];
    }
    
    if (!self.trasactionOverlay) {
        self.trasactionOverlay = [[UIControl alloc] initWithFrame:self.view.bounds];
        [self.trasactionOverlay addTarget:self action:@selector(dismissCharge:) forControlEvents:UIControlEventTouchUpInside];
        self.trasactionOverlay.backgroundColor = [UIColor blackColor];
        self.trasactionOverlay.alpha = 0.25f;
        [self.view addSubview:self.trasactionOverlay];
    } else {
        [self.view addSubview:self.trasactionOverlay];
    }
    [UIView animateWithDuration:0.05f animations:^{
        self.trasactionOverlay.alpha = 0.65f;
    }];
    
    if (!self.transactionView) {
        self.transactionView = [BCMQRCodeTransactionView loadInstanceFromNib];
    }
    self.transactionView.delegate = self;
    self.transactionView.activeTransaction = transaction;
    self.transactionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.transactionView];
    
    NSLayoutConstraint *topSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0f];
    NSLayoutConstraint *bottomSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-30.0f];
    NSLayoutConstraint *leftSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:30.0f];
    NSLayoutConstraint *rightSearchViewConstraint = [NSLayoutConstraint constraintWithItem:self.transactionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-30.0f];
    
    [self.view addConstraints:@[ topSearchViewConstraint, bottomSearchViewConstraint, leftSearchViewConstraint, rightSearchViewConstraint] ];
}

- (void)updateTransctionInformation
{
    NSString *itemCountText = @"";
    
    if ([self.simpleItems count] == 1) {
        itemCountText = [NSString stringWithFormat:@"(%lu item)", (unsigned long)[self.simpleItems count]];
    } else {
        itemCountText = [NSString stringWithFormat:@"(%lu items)", (unsigned long)[self.simpleItems count]];
    }
    self.transactionItemCountLbl.text = itemCountText;
    self.totalTransactionAmountLbl.text = [NSString stringWithFormat:@"$%.2f", [self transactionSum]];
}

- (CGFloat)transactionSum
{
    CGFloat sum = 0.00f;
    
    for (NSDictionary *itemDict in self.simpleItems) {
        NSNumber *itemPrice = [itemDict objectForKey:kItemPriceKey];
        if (itemPrice) {
            sum += [itemPrice floatValue];
        }
    }
    
    return sum;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return BCMPOSSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;

    if (section == BCMPOSSectionCustomItem) {
        rowCount = 1;
    } else if (section == BCMPOSSectionItems) {
        rowCount = [self.merchantItems count];
    }
    
    return rowCount;
}

static NSString *const kPOSItemDefaultCellId = @"POSItemCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;

    if (section == BCMPOSSectionCustomItem) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPOSItemDefaultCellId];
        cell.textLabel.text = @"Custom";
        cell.detailTextLabel.text = @"+";
    } else if (section == BCMPOSSectionItems) {
        Item *item = [self.merchantItems objectAtIndex:row];
        cell = [tableView dequeueReusableCellWithIdentifier:kPOSItemDefaultCellId];
        
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", [item.price floatValue]];
    }
    
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

const CGFloat kBBPOSItemDefaultRowHeight = 38.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBPOSItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == BCMPOSSectionCustomItem) {
        [self showCustomAmountView];
    } else if (section == BCMPOSSectionItems) {
        Item *item = [self.merchantItems objectAtIndex:row];

        NSDictionary *itemDict = [item itemAsDict];
        [self.simpleItems addObject:itemDict];
        [self updateTransctionInformation];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BCMCustomAmountViewDelegate

- (void)showCustomAmountView
{
    [self.customAmountView clear];
    [self.view bringSubviewToFront:self.customAmountContainerView];
    self.topMarginConstraint.constant = 8.0f;
    [self.customAmountView.customAmountTextField becomeFirstResponder];
}

- (void)hideCustomAmountView
{
    [self.view sendSubviewToBack:self.customAmountContainerView];
    self.topMarginConstraint.constant = CGRectGetHeight(self.view.frame);
}

- (void)customAmountViewDidCancelEntry:(BCMCustomAmountView *)amountView
{
    [self hideCustomAmountView];
}

- (void)customAmountView:(BCMCustomAmountView *)amountView addCustomAmount:(CGFloat)amount
{
    NSDictionary *itemDict = @{ kItemNameKey : @"Custom" , kItemPriceKey : [NSNumber numberWithFloat:amount] };
    [self.simpleItems addObject:itemDict];
    [self updateTransctionInformation];
    [self hideCustomAmountView];
}

#pragma mark - BCMQRCodeTransactionViewDelegate

- (void)transactionViewDidComplete:(BCMQRCodeTransactionView *)transactionView
{
    
}

- (void)transactionViewDidClear:(BCMQRCodeTransactionView *)transactionView
{
    [self hideTransactionView];
}

@end
