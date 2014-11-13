//
//  BCMSettingsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSettingsViewController.h"

#import "BCMTextFieldTableViewCell.h"
#import "BCMSwitchTableViewCell.h"
#import "BCMTextField.h"

#import "BCMMerchantManager.h"
#import "ActionSheetStringPicker.h"

#import "Merchant.h"
#import "BCMMerchantManager.h"

#import "PEPinEntryController.h"

#import "MBProgressHUD.h"

#import "UIColor+Utilities.h"

typedef NS_ENUM(NSUInteger, BCMSettingsRow) {
    BCMSettingsRowBusinessName,
    BCMSettingsRowBusinessAddress,
    BCMSettingsRowTelephone,
    BCMSettingsRowDescription,
    BCMSettingsRowWebsite,
    BCMSettingsRowCurrency,
    BCMSettingsRowWalletAddress,
    BCMSettingsRowSetPin,
    BCMSettingsRowDirectoryListing,
    BCMSettingsRowCount
};

@interface BCMSettingsViewController () <BCMTextFieldTableViewCellDelegate, BCMSwitchTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@property (strong, nonatomic) BCMTextFieldTableViewCell *activeTextFieldCell;

@property (strong, nonatomic) NSMutableDictionary *settings;

@property (strong, nonatomic) PEPinEntryController * pinEntryViewController;

@end

@implementation BCMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [[NSMutableDictionary alloc] init];
    
    self.settingsTableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    if ([self.settingsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.settingsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self addNavigationType:BCMNavigationTypeHamburger position:BCMNavigationPositionLeft selector:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedPin:) name:kBCMPinEntryCAddedPinSuccessfulNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeObservers];
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BCMSettingsRowCount;
}

static NSString *const kSettingsTextFieldCellId = @"settingTextFieldCellId";
static NSString *const kSettingsSwitchCellId = @"settingSwitchCellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    NSString *reuseCellId = kSettingsTextFieldCellId;
    NSString *settingTitle = nil;
    NSString *settingValue = nil;
    NSString *settingKey = nil;
    BOOL canEdit = YES;
    
    Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
    
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingTitle = @"Business Name";
            settingValue = merchant.name;
            break;
        case BCMSettingsRowBusinessAddress:
            settingTitle = @"Business Address";
            settingKey = kBCMBusinessAddressSettingsKey;
            break;
        case BCMSettingsRowTelephone:
            settingTitle = @"Telephone";
            settingKey = kBCMTelephoneSettingsKey;
            break;
        case BCMSettingsRowDescription:
            settingTitle = @"Description";
            settingKey = kBCMDescriptionSettingsKey;
            break;
        case BCMSettingsRowWebsite:
            settingTitle = @"Website";
            settingKey = kBCMWebsiteSettingsKey;
            break;
        case BCMSettingsRowCurrency:
            settingTitle = @"Currency";
            canEdit = NO;
            settingKey = kBCMCurrencySettingsKey;
            break;
        case BCMSettingsRowWalletAddress:
            settingTitle = @"Address";
            settingValue = merchant.walletAddress;
            break;
        case BCMSettingsRowSetPin:
            if ([[BCMMerchantManager sharedInstance] requirePIN]) {
                settingTitle = @"Reset Pin";
            } else {
                settingTitle = @"Set Pin";
            }
            canEdit = NO;
            settingKey = kBCMPinSettingsKey;
            break;
        case BCMSettingsRowDirectoryListing:
            settingTitle = @"Directory Listing";
            settingKey = kBCMDirectoryListingSettingsKey;
            reuseCellId = kSettingsSwitchCellId;
            break;
        default:
            settingTitle = @"Address";
            break;
    }
    
    if ([reuseCellId isEqualToString:kSettingsTextFieldCellId]) {
        
        BCMTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kSettingsTextFieldCellId];
        textFieldCell.delegate = self;
        textFieldCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        textFieldCell.textLabel.textColor = [UIColor colorWithHexValue:@"a3a3a3"];
        
        NSString *text = nil;
        if ([settingKey length] > 0) {
            if (![self.settings objectForKey:settingKey]) {
                text = [[NSUserDefaults standardUserDefaults] objectForKey:settingKey];
                if ([text length] == 0) {
                    text = @"";
                }
                [self.settings setObject:text forKey:settingKey];
            } else {
                text = [self.settings objectForKey:settingKey];
            }
        }
        
        if ([settingValue length] > 0) {
            textFieldCell.textField.text = settingValue;
        } else {
            if ([text length] > 0) {
                textFieldCell.textField.text = text;
            } else {
                textFieldCell.textField.text = @"";
                textFieldCell.textField.placeholder = settingTitle;
            }
        }
        textFieldCell.canEdit = canEdit;
        
        cell = textFieldCell;
    } else {
        BCMSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:kSettingsSwitchCellId];
        switchCell.delegate = self;
        switchCell.switchTitle = settingTitle;
        switchCell.switchStateOn = [BCMMerchantManager sharedInstance].directoryListing;
        cell = switchCell;
    }

    return cell;
}

const CGFloat kBBSettingsItemDefaultRowHeight = 55.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBBSettingsItemDefaultRowHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == BCMSettingsRowCurrency) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *currencyPath = [mainBundle pathForResource:@"SupportedCurrencies" ofType:@"plist"];
        NSArray *currencies = [NSArray arrayWithContentsOfFile:currencyPath];
        
        NSString *currentCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMCurrencySettingsKey];
        NSUInteger selectedCurrencyIndex = [currencies indexOfObject:currentCurrency];
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Currency" rows:currencies initialSelection:selectedCurrencyIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [self.settings setObject:[currencies objectAtIndex:selectedIndex] forKey:kBCMCurrencySettingsKey];
            [[NSUserDefaults standardUserDefaults] setObject:[currencies objectAtIndex:selectedIndex] forKey:kBCMCurrencySettingsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.settingsTableView reloadData];
            });
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [picker showActionSheetPicker];
    } else {
        if ([[BCMMerchantManager sharedInstance] requirePIN]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinEntrySuccessful:) name:kBCMPinEntryCompletedSuccessfulNotification object:nil];
            PEPinEntryController *pinEntryController = [PEPinEntryController pinVerifyController];
            pinEntryController.navigationBarHidden = YES;
            pinEntryController.pinDelegate = [BCMMerchantManager sharedInstance];
            [self presentViewController:pinEntryController animated:YES completion:nil];
        } else {
            self.pinEntryViewController = [PEPinEntryController pinCreateController];
            self.pinEntryViewController.navigationBarHidden = YES;
            self.pinEntryViewController.pinDelegate = [BCMMerchantManager sharedInstance];
            [self presentViewController:self.pinEntryViewController animated:YES completion:nil];
        }
    }
}

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView
{
    
}

#pragma mark - BCMTextFieldTableViewCellDelegate

- (void)textFieldTableViewCellDidBeingEditing:(BCMTextFieldTableViewCell *)cell
{
    self.activeTextFieldCell = cell;
}

- (void)textFieldTableViewCell:(BCMTextFieldTableViewCell *)cell didEndEditingWithText:(NSString *)text
{
    NSIndexPath *indexPath = [self.settingsTableView indexPathForCell:cell];
    NSUInteger row = indexPath.row;
    
    NSString *settingKey = nil;
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingKey = kBCMBusinessNameSettingsKey;
            break;
        case BCMSettingsRowBusinessAddress:
            settingKey = kBCMBusinessAddressSettingsKey;
            break;
        case BCMSettingsRowTelephone:
            settingKey = kBCMTelephoneSettingsKey;
            break;
        case BCMSettingsRowDescription:
            settingKey = kBCMDescriptionSettingsKey;
            break;
        case BCMSettingsRowWebsite:
            settingKey = kBCMWebsiteSettingsKey;
            break;
        case BCMSettingsRowCurrency:
            settingKey = kBCMCurrencySettingsKey;
            break;
        case BCMSettingsRowWalletAddress:
            settingKey = kBCMWalletSettingsKey;
            break;
        case BCMSettingsRowSetPin:
            settingKey = kBCMPinSettingsKey;
            break;
        default:
            break;
    }
    
    [self.settings setObject:text forKey:settingKey];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.settings removeAllObjects];
    [self.settingsTableView reloadData];
}

- (IBAction)saveAction:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    hud.labelText = @"Saved";
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    
    for (NSString *settingsKey in [self.settings allKeys]) {
        NSString *settingValue = [self.settings objectForKey:settingsKey];
        
        [[NSUserDefaults standardUserDefaults] setObject:settingValue forKey:settingsKey];
    }
    
    Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
    merchant.name = [self.settings objectForKey:kBCMBusinessNameSettingsKey];
    merchant.walletAddress = [self.settings objectForKey:kBCMWalletSettingsKey];

    [[NSUserDefaults standardUserDefaults] synchronize];

    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    }];
}

#pragma mark - BCMSwitchTableViewCellDelegate

- (void)switchCell:(BCMSwitchTableViewCell *)cell isOn:(BOOL)on
{
    [BCMMerchantManager sharedInstance].directoryListing = on;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    NSValue *endRectValue = [dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endKeyboardFrame = [endRectValue CGRectValue];
    CGRect convertedEndKeyboardFrame = [self.view convertRect:endKeyboardFrame fromView:nil];
    
    CGRect convertedWalletFrame = [self.view convertRect:self.activeTextFieldCell.frame fromView:self.settingsTableView];
    CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
        
        // If the ending keyboard frame overlaps our textfield
        if (lowestPoint > CGRectGetMinY(convertedEndKeyboardFrame)) {
            self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetMinY(convertedEndKeyboardFrame) + (lowestPoint - CGRectGetMinY(convertedEndKeyboardFrame)), 0.0f);
        }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        NSDictionary *dict = notification.userInfo;
        NSTimeInterval duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
}

- (void)addedPin:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PinEntry

- (void)pinEntrySuccessful:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBCMPinEntryCompletedSuccessfulNotification object:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
    self.pinEntryViewController = [PEPinEntryController pinCreateController];
    self.pinEntryViewController.navigationBarHidden = YES;
    self.pinEntryViewController.pinDelegate = [BCMMerchantManager sharedInstance];
    [self presentViewController:self.pinEntryViewController animated:YES completion:nil];
}
@end
