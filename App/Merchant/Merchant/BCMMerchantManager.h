//
//  BCMMerchantManager.h
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCPinEntryViewController.h"

// Pin Related Values
extern NSString *const kBCMPinSettingsKey;
extern NSString *const kBCMServiceName;

@class Merchant;

@interface BCMMerchantManager : NSObject <BCPinEntryViewControllerDelegate>

@property (strong, readonly, nonatomic) Merchant *activeMerchant;

+ (instancetype)sharedInstance;

- (BOOL)requirePIN;

- (NSString *)currencySymbol;

- (UIImage *)merchantQRCodeImage;

@end
