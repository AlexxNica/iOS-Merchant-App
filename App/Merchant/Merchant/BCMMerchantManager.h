//
//  BCMMerchantManager.h
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPinEntryController.h"

extern NSString *const kBCMBusinessNameSettingsKey;
extern NSString *const kBCMBusinessAddressSettingsKey;
extern NSString *const kBCMTelephoneSettingsKey;
extern NSString *const kBCMDescriptionSettingsKey;
extern NSString *const kBCMWebsiteSettingsKey;
extern NSString *const kBCMCurrencySettingsKey;
extern NSString *const kBCMWalletSettingsKey;
extern NSString *const kBCMPinSettingsKey;
extern NSString *const kBCMDirectoryListingSettingsKey;

extern NSString *const kBCMPinEntryCompletedSuccessfulNotification;
extern NSString *const kBCMPinEntryCompletedFailNotification;
extern NSString *const kBCMPinEntryCAddedPinSuccessfulNotification;
extern NSString *const kBCMPinEntryCAddedPinFailedNotification;

@class Merchant;

@interface BCMMerchantManager : NSObject <PEPinEntryControllerDelegate>

@property (strong, readonly, nonatomic) Merchant *activeMerchant;

- (BOOL)pinIsSet;

+ (instancetype)sharedInstance;

@property (assign, nonatomic) BOOL directoryListing;

- (BOOL)requirePIN;
- (NSString *)currencySymbol;
- (UIImage *)merchantQRCodeImage;

@end
