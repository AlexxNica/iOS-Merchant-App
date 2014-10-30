//
//  BCMItemSetupViewController.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMItemSetupViewController.h"

#import "BCMAddItem.h"

#import "Item.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

@interface BCMItemSetupViewController () <BCMAddItemViewProtocol>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) UIView *whiteOverlayView;
@property (strong, nonatomic) NSArray *merchantItems;

@end

@implementation BCMItemSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];

    if (!self.whiteOverlayView) {
        self.whiteOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.whiteOverlayView.backgroundColor = [UIColor whiteColor];
        self.whiteOverlayView.alpha = 0.0f;
        [self.view addSubview:self.whiteOverlayView];
    }
    
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    if (self.whiteOverlayView.alpha == 0.0f) {
        [self.view bringSubviewToFront:self.whiteOverlayView];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.whiteOverlayView.alpha = 1.0f;
        }];
        
        BCMAddItem *itemView = [BCMAddItem loadInstanceFromNib];
        itemView.delegate = self;
        itemView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        itemView.layer.borderWidth = 2.0f;
        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:itemView];
        
        NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:376.0f];
        NSLayoutConstraint *verticalOffsetConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f];
        NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:298.0f];
        NSLayoutConstraint *horizontalCenterConstraint = [NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:verticalConstraint];
        [self.view addConstraint:verticalOffsetConstraint];
        [self.view addConstraint:horizontalConstraint];
        [self.view addConstraint:horizontalCenterConstraint];
    }
}

- (IBAction)doneAction:(id)sender
{

}

- (void)dismissAddItemView:(BCMAddItem *)itemView
{
    [itemView removeFromSuperview];
    [UIView animateWithDuration:0.25f animations:^{
        self.whiteOverlayView.alpha = 0.0f;
    }];
}

- (void)reloadItemTableViewOnMainThread
{
    self.merchantItems = [Item MR_findAllSortedBy:@"creation_date" ascending:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.itemsTableView reloadData];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.merchantItems count];
}

static NSString *const kMerchantItemDefaultCellId = @"merchantItemCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    Item *item = [self.merchantItems objectAtIndex:row];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kMerchantItemDefaultCellId];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", [item.price floatValue]];
    
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

const CGFloat kBBMerchantItemDefaultRowHeight = 38.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBMerchantItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = YES;
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.merchantItems objectAtIndex:indexPath.row];
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
