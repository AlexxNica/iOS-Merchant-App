//
//  BCMTransactionTableViewCell.m
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTransactionTableViewCell.h"

#import "Transaction.h"

#import "NSDate+Utilities.h"

@interface BCMTransactionTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *amountLbl;

@end

@implementation BCMTransactionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

@synthesize transaction = _transaction;

- (void)setTransaction:(Transaction *)transaction
{
    _transaction = transaction;
    
    self.amountLbl.text = [NSString stringWithFormat:@"%1.2f", transaction.bitcoinAmountValue];
    
    
    NSDate *transactionDate = _transaction.creation_date;
    
    NSTimeInterval secondsBeforeNow = [[NSDate date] timeIntervalSinceDate:transactionDate];
    
    NSString *timeUnit = nil;
    NSString *timeValue = nil;

    if (secondsBeforeNow < 60) {
        timeUnit = @"seconds";
        timeValue = [NSString stringWithFormat:@"%ld %@ ago", (long)secondsBeforeNow, timeUnit];
    } else if (secondsBeforeNow >= 60 && secondsBeforeNow < 3600) {
        timeUnit = @"minutes";
        timeValue = [NSString stringWithFormat:@"%0.0f %@ ago", secondsBeforeNow / 60, timeUnit];
    } else {
        timeUnit = @"";
        timeValue = [transactionDate shortDateString];
    }
    
    self.timeLbl.text = timeValue;
}

@end
