//
//  BCMQRCodeTransactionView.m
//  Merchant
//
//  Created by User on 10/31/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeTransactionView.h"

#import "Transaction.h"

@interface BCMQRCodeTransactionView ()

@property (weak, nonatomic) IBOutlet UILabel *currencyPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPriceLbl;

@end

@implementation BCMQRCodeTransactionView


@synthesize activeTransaction = _activeTransaction;

- (void)setActiveTransaction:(Transaction *)activeTransaction
{
    _activeTransaction = activeTransaction;
    
    NSString *total = @"N/A";
    if ([activeTransaction.purchasedItems count] > 0) {
        total = [NSString stringWithFormat:@"%0.2f", [activeTransaction transactionTotal]];
    }
    
    self.currencyPriceLbl.text = total;
    
    // Need to set bitcoin price
    self.bitcoinPriceLbl.text = @"0.05 BTC";
}

- (IBAction)clearAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(transactionViewDidClear:)]) {
        [self.delegate transactionViewDidClear:self];
    }
}

@end
