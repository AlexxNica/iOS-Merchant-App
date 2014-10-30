//
//  BCMPOSViewController.m
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPOSViewController.h"

#import "BCMCustomAmountView.h"
#import "BCMTextField.h"

#import "Item.h"

#import "UIView+Utilities.h"

typedef NS_ENUM(NSUInteger, BCMPOSSection) {
    BCMPOSSectionCustomItem,
    BCMPOSSectionItems,
    BCMPOSSectionCount
};

@interface BCMPOSViewController () <BCMCustomAmountViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalTransactionAmountLbl;
@property (weak, nonatomic) IBOutlet UILabel *transactionItemCountLbl;

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) NSArray *merchantItems;
@property (strong, nonatomic) NSMutableArray *currentTransaction;

@property (strong, nonatomic) IBOutlet UIView *customAmountContainerView;
@property (strong, nonatomic) IBOutlet BCMCustomAmountView *customAmountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;

@end

@implementation BCMPOSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.currentTransaction = [[NSMutableArray alloc] init];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];

    [self updateTransctionInformation];
    
    [self.itemsTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chargeAction:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Patience" message:@"In a future delivery." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}

- (void)updateTransctionInformation
{
    NSString *itemCountText = @"";
    
    if ([self.currentTransaction count] == 1) {
        itemCountText = [NSString stringWithFormat:@"(%lu item)", (unsigned long)[self.currentTransaction count]];
    } else {
        itemCountText = [NSString stringWithFormat:@"(%lu items)", (unsigned long)[self.currentTransaction count]];
    }
    self.transactionItemCountLbl.text = itemCountText;
    self.totalTransactionAmountLbl.text = [NSString stringWithFormat:@"$%.2f", [self transactionSum]];
}

- (CGFloat)transactionSum
{
    CGFloat sum = 0.00f;
    
    for (NSDictionary *itemDict in self.currentTransaction) {
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
        [self.currentTransaction addObject:itemDict];
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
    [self.currentTransaction addObject:itemDict];
    [self updateTransctionInformation];
    [self hideCustomAmountView];
}

@end
