//
//  BCMSettingsViewController.m
//  Merchant
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSettingsViewController.h"

#import "BCMQRCodeScannerViewController.h"

#import "BCMTextFieldTableViewCell.h"
#import "BCMSwitchTableViewCell.h"
#import "BCMTextField.h"

#import "BCMMerchantManager.h"
#import "ActionSheetStringPicker.h"

#import "Merchant.h"
#import "BCMMerchantManager.h"

#import "BCPinEntryViewController.h"

#import "MBProgressHUD.h"

#import "AppDelegate.h"
#import "BCMDrawerViewController.h"

#import "UIColor+Utilities.h"
#import "Foundation-Utility.h"

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

@interface BCMSettingsViewController () <BCMTextFieldTableViewCellDelegate, BCMSwitchTableViewCellDelegate, BCMQRCodeScannerViewControllerDelegate, BCPinEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@property (strong, nonatomic) BCMTextFieldTableViewCell *activeTextFieldCell;

@property (strong, nonatomic) NSMutableDictionary *settings;

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
    
    Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
    [self loadSettingsDictWithMerchant:merchant];
    
    [self displayPinEntry];
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

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)loadSettingsDictWithMerchant:(Merchant *)merchant
{
    [self.settings setObjectOrNil:merchant.name forKey:kBCMBusinessName];
    [self.settings setObjectOrNil:merchant.businessCategory forKey:kBCMBusinessCategory];

    [self.settings setObjectOrNil:merchant.streetAddress forKey:kBCMBusinessStreetAddress];

    [self.settings setObjectOrNil:merchant.city forKey:kBCMBusinessCityAddress];
    [self.settings setObjectOrNil:merchant.zipcode forKey:kBCMBusinessZipcodeAddress];
    [self.settings setObjectOrNil:merchant.latitude forKey:kBCMBusinessLatitude];
    [self.settings setObjectOrNil:merchant.longitude forKey:kBCMBusinessLongitude];
    [self.settings setObjectOrNil:merchant.telephone forKey:kBCMBusinessTelephone];
    [self.settings setObjectOrNil:merchant.webURL forKey:kBCMBusinessWebURL];
    [self.settings setObjectOrNil:merchant.businessDescription forKey:kBCMBusinessDescription];
    
    [self.settings setObjectOrNil:merchant.walletAddress forKey:kBCMBusinessWalletAddress];
    [self.settings setObjectOrNil:merchant.currency forKey:kBCMBusinessCurrency];
}

- (void)displayPinEntry
{    
    if ([[BCMMerchantManager sharedInstance] requirePIN]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
        UINavigationController *pinEntryViewNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kPinEntryStoryboardId];
        BCPinEntryViewController *entryViewController = (BCPinEntryViewController *)pinEntryViewNavController.topViewController;
        entryViewController.userMode = PinEntryUserModeAccess;
        entryViewController.delegate = self;
        [self presentViewController:pinEntryViewNavController animated:YES completion:nil];
    }
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
    UIImage *accessoryImage = nil;
    
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingTitle = @"Business Name";
            settingKey = kBCMBusinessName;
            break;
        case BCMSettingsRowBusinessAddress:
            settingTitle = @"Business Address";
            settingKey = kBCMBusinessStreetAddress;
            break;
        case BCMSettingsRowTelephone:
            settingTitle = @"Telephone";
            settingKey = kBCMBusinessTelephone;
            break;
        case BCMSettingsRowDescription:
            settingTitle = @"Description";
            settingKey = kBCMBusinessDescription;
            break;
        case BCMSettingsRowWebsite:
            settingTitle = @"Website";
            settingKey = kBCMBusinessWebURL;
            break;
        case BCMSettingsRowCurrency:
            settingTitle = @"Currency";
            canEdit = NO;
            settingKey = kBCMBusinessCurrency;
            break;
        case BCMSettingsRowWalletAddress:
            settingTitle = @"Address";
            settingKey = kBCMBusinessWalletAddress;
            accessoryImage = [UIImage imageNamed:@"qr_code"];
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
            settingKey = kBCMBusinessDirectoryListing;
            reuseCellId = kSettingsSwitchCellId;
            break;
        default:
            settingTitle = @"Address";
            break;
    }
    
    if ([reuseCellId isEqualToString:kSettingsTextFieldCellId]) {
        
        BCMTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kSettingsTextFieldCellId];
        textFieldCell.delegate = self;
        textFieldCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0f];
        textFieldCell.textLabel.textColor = [UIColor colorWithHexValue:@"a3a3a3"];
        textFieldCell.textFieldImage = accessoryImage;
        
        NSString *text = nil;
        if ([settingKey length] > 0) {
            if (![self.settings safeObjectForKey:settingKey]) {
                text = [[NSUserDefaults standardUserDefaults] objectForKey:settingKey];
                if ([text length] == 0) {
                    text = @"";
                }
                [self.settings setObject:text forKey:settingKey];
            } else {
                text = [self.settings safeObjectForKey:settingKey];
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
        switchCell.switchStateOn = [BCMMerchantManager sharedInstance].activeMerchant.directoryListingValue;
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
        
        NSString *currentCurrency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
        NSUInteger selectedCurrencyIndex = [currencies indexOfObject:currentCurrency];
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Currency" rows:currencies initialSelection:selectedCurrencyIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [self.settings setObject:[currencies objectAtIndex:selectedIndex] forKey:kBCMBusinessCurrency];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.settingsTableView reloadData];
            });
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [picker showActionSheetPicker];
    } else if (indexPath.row == BCMSettingsRowSetPin) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
        UINavigationController *pinEntryViewNavController = [mainStoryboard instantiateViewControllerWithIdentifier:kPinEntryStoryboardId];
        BCPinEntryViewController *entryViewController = (BCPinEntryViewController *)pinEntryViewNavController.topViewController;
        entryViewController.delegate = self;        
        if ([[BCMMerchantManager sharedInstance] requirePIN]) {
            entryViewController.userMode = PinEntryUserModeReset;
        } else {
            entryViewController.userMode = PinEntryUserModeCreate;
        }
        [self presentViewController:pinEntryViewNavController animated:YES completion:nil];
    }
}

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView
{
    
}

#pragma mark - BCMTextFieldTableViewCellDelegate

- (void)updateSettingsIfNeededForIndexPath:(NSIndexPath *)indexPath withText:(NSString *)text
{
    NSUInteger row = indexPath.row;
    
    NSString *settingKey = nil;
    switch (row) {
        case BCMSettingsRowBusinessName:
            settingKey = kBCMBusinessName;
            break;
        case BCMSettingsRowBusinessAddress:
            settingKey = kBCMBusinessStreetAddress;
            break;
        case BCMSettingsRowTelephone:
            settingKey = kBCMBusinessTelephone;
            break;
        case BCMSettingsRowDescription:
            settingKey = kBCMBusinessDescription;
            break;
        case BCMSettingsRowWebsite:
            settingKey = kBCMBusinessWebURL;
            break;
        case BCMSettingsRowCurrency:
            settingKey = kBCMBusinessCurrency;
            break;
        case BCMSettingsRowWalletAddress:
            settingKey = kBCMBusinessWalletAddress;
            break;
        case BCMSettingsRowSetPin:
            settingKey = kBCMPinSettingsKey;
            break;
        default:
            break;
    }
    
    [self.settings setObject:text forKey:settingKey];
}

- (void)textFieldTableViewCellDidBeingEditing:(BCMTextFieldTableViewCell *)cell
{
    self.activeTextFieldCell = cell;
}

- (void)textFieldTableViewCell:(BCMTextFieldTableViewCell *)cell didEndEditingWithText:(NSString *)text
{
    NSIndexPath *indexPath = [self.settingsTableView indexPathForCell:cell];
    [self updateSettingsIfNeededForIndexPath:indexPath withText:text];
    [self.settingsTableView reloadData];
}

- (void)textFieldTableViewCellAccesssoryAction:(BCMTextFieldTableViewCell *)cell
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_NAME bundle:nil];
    UINavigationController *scannerNavigationController = [mainStoryboard instantiateViewControllerWithIdentifier:kBCMQrCodeScannerNavigationId];
    BCMQRCodeScannerViewController *scannerViewController = (BCMQRCodeScannerViewController *)scannerNavigationController.topViewController;
    scannerViewController.delegate = self;
    [self presentViewController:scannerNavigationController animated:YES completion:nil];
}

#pragma mark - BCMQRCodeScannerViewControllerDelegate

- (void)bcmscannerViewController:(BCMQRCodeScannerViewController *)vc didScanString:(NSString *)scanString
{
    [self.settings setObject:scanString forKey:kBCMBusinessWalletAddress];
    [vc dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }];
}

- (void)bcmscannerViewControllerCancel:(BCMQRCodeScannerViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.settings removeAllObjects];
    [self loadSettingsDictWithMerchant:[BCMMerchantManager sharedInstance].activeMerchant];
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
    
    Merchant *merchant = [BCMMerchantManager sharedInstance].activeMerchant;
    merchant.name = [self.settings safeObjectForKey:kBCMBusinessName];
    merchant.streetAddress = [self.settings safeObjectForKey:kBCMBusinessStreetAddress];
    merchant.city = [self.settings safeObjectForKey:kBCMBusinessCityAddress];
    merchant.zipcode = [self.settings safeObjectForKey:kBCMBusinessZipcodeAddress];
    
    merchant.telephone = [self.settings safeObjectForKey:kBCMBusinessTelephone];
    merchant.webURL = [self.settings safeObjectForKey:kBCMBusinessWebURL];
    merchant.businessDescription = [self.settings safeObjectForKey:kBCMBusinessDescription];

    merchant.currency =  [self.settings safeObjectForKey:kBCMBusinessCurrency];
    merchant.walletAddress = [self.settings safeObjectForKey:kBCMBusinessWalletAddress];
    
    NSNumber *directoryListing = [self.settings safeObjectForKey:kBCMBusinessDirectoryListing];
    merchant.directoryListingValue = [directoryListing boolValue];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    }];
}

#pragma mark - BCMSwitchTableViewCellDelegate

- (void)switchCell:(BCMSwitchTableViewCell *)cell isOn:(BOOL)on
{
    [self.settings setObject:[NSNumber numberWithBool:on] forKey:kBCMBusinessDirectoryListing];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    NSValue *endRectValue = [dict safeObjectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endKeyboardFrame = [endRectValue CGRectValue];
    CGRect convertedEndKeyboardFrame = [self.view convertRect:endKeyboardFrame fromView:nil];
    
    CGRect convertedWalletFrame = [self.view convertRect:self.activeTextFieldCell.frame fromView:self.settingsTableView];
    CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
        
        // If the ending keyboard frame overlaps our textfield
        if (lowestPoint > CGRectGetMinY(convertedEndKeyboardFrame)) {
            self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetMinY(convertedEndKeyboardFrame), 0.0f);
            [self.settingsTableView setContentOffset:CGPointMake(0.0f, lowestPoint - CGRectGetMinY(convertedEndKeyboardFrame)) animated:NO];
        }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        NSDictionary *dict = notification.userInfo;
        NSTimeInterval duration = [[dict safeObjectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[dict safeObjectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.settingsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
}

#pragma mark - BCPinEntryViewControllerDelegate

- (BOOL)pinEntryViewController:(BCPinEntryViewController *)pinVC validatePin:(NSString *)pin
{
    return [[BCMMerchantManager sharedInstance] pinEntryViewController:pinVC validatePin:pin];
}

- (void)pinEntryViewController:(BCPinEntryViewController *)pinVC successfulEntry:(BOOL)success pin:(NSString *)pin
{
    [[BCMMerchantManager sharedInstance] pinEntryViewController:pinVC successfulEntry:success pin:pin];
    [self.settingsTableView reloadData];
}


@end
