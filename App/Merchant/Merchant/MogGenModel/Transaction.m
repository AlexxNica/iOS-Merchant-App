#import "Transaction.h"
#import "PurchasedItem.h"

@interface Transaction ()

// Private interface goes here.

@end


@implementation Transaction

- (CGFloat)transactionTotal
{
    CGFloat purchaseSum = 0.0f;
    
    for (PurchasedItem *item in [self.purchasedItems allObjects]) {
        purchaseSum += [item.price floatValue];
    }
    
    return purchaseSum;
}

@end
