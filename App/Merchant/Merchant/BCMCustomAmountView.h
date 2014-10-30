//
//  BCMCustomAmountView.h
//  Merchant
//
//  Created by User on 10/28/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCMTextField;

@class BCMCustomAmountView;

@protocol BCMCustomAmountViewDelegate <NSObject>

- (void)customAmountViewDidCancelEntry:(BCMCustomAmountView *)amountView;
- (void)customAmountView:(BCMCustomAmountView *)amountView addCustomAmount:(CGFloat)amount;

@end

@interface BCMCustomAmountView : UIView

@property (weak, nonatomic) id <BCMCustomAmountViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet BCMTextField *customAmountTextField;

- (void)clear;

@end
