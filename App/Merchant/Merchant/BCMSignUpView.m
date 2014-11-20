//
//  BCMSignUpView.m
//  Merchant
//
//  Created by User on 11/9/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSignUpView.h"

#import "BCMTextField.h"

#import "BCMMerchantManager.h"

#import "Merchant.h"

#import "ActionSheetStringPicker.h"

#import "UIColor+Utilities.h"

@interface BCMSignUpView ()

@property (weak, nonatomic) IBOutlet BCMTextField *nameTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *currencyTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *walletTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMSignUpView

- (void)awakeFromNib
{
    [super awakeFromNib];

    CALayer *layer = self.layer;
    layer.shadowOpacity = .5;
    layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    layer.shadowOffset = CGSizeMake(0,0);
    layer.shadowRadius = 8;
    
    self.nameTextField.placeholder = NSLocalizedString(@"signup.business.name", nil);
    self.walletTextField.placeholder = NSLocalizedString(@"signup.wallet.name", nil);
    self.currencyTextField.placeholder = NSLocalizedString(@"signup.currency.name", nil);
    
    [self.cancelButton setTitle:NSLocalizedString(@"action.cancel", nil) forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"action.save", nil) forState:UIControlStateNormal];
    
    [self addObservers];
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

- (void)dealloc
{
    [self removeObservers];
}

@synthesize pinRequired = _pinRequired;

- (void)setPinRequired:(BOOL)pinRequired
{
    _pinRequired = pinRequired;
    
    if (_pinRequired) {
        self.signupTextField.placeholder = NSLocalizedString(@"signup.pin.reset", nil);
    } else {
        self.signupTextField.placeholder = NSLocalizedString(@"signup.pin.set", nil);
    }
}

- (IBAction)cancelAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(signUpViewDidCancel:)]) {
        [self.delegate signUpViewDidCancel:self];
    }
}

- (IBAction)saveAction:(id)sender
{
    if ([self.nameTextField.text length] == 0 || [self.walletTextField.text length] == 0) {
        NSString *alertTitle = NSLocalizedString(@"signup.alert.title", nil);
        NSString *alertMessage = NSLocalizedString(@"signup.warning", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        Merchant *merchant = [Merchant MR_createEntity];
        merchant.name = self.nameTextField.text;
        merchant.walletAddress = self.walletTextField.text;
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(signUpViewDidSave:)]) {
                [self.delegate signUpViewDidSave:self];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit = YES;
    
    if (textField == self.currencyTextField) {
        canEdit = NO;
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *currencyPath = [mainBundle pathForResource:@"SupportedCurrencies" ofType:@"plist"];
        NSArray *currencies = [NSArray arrayWithContentsOfFile:currencyPath];
        
        NSString *currentCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMCurrencySettingsKey];
        NSUInteger selectedCurrencyIndex = [currencies indexOfObject:currentCurrency];
        
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"currency.picker.title", nil) rows:currencies initialSelection:selectedCurrencyIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [[NSUserDefaults standardUserDefaults] setObject:[currencies objectAtIndex:selectedIndex] forKey:kBCMCurrencySettingsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.currencyTextField.text = [currencies objectAtIndex:selectedIndex];
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self];
        [picker showActionSheetPicker];
    } else if (self.signupTextField == textField) {
        canEdit = NO;
        if ([self.delegate respondsToSelector:@selector(signUpViewSetPin:)]) {
            [self.delegate signUpViewSetPin:self];
        }
    } else {
        textField.inputAccessoryView = [self inputAccessoryView];
    }
    
    return canEdit;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        UIView *parentView = [self superview];
        CGRect accessFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(parentView.frame), 54.0f);
        self.inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        self.inputAccessoryView.backgroundColor = [UIColor colorWithHexValue:BCM_BLUE];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(CGRectGetWidth(parentView.frame) - 80.0f, 10.0, 80.0f, 40.0f);
        [compButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [compButton setTitle: @"Done" forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(accessoryDoneAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.walletTextField isFirstResponder]) {
        NSDictionary *dict = notification.userInfo;
        NSValue *endRectValue = [dict objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endKeyboardFrame = [endRectValue CGRectValue];
        CGRect convertedEndKeyboardFrame = [[self superview] convertRect:endKeyboardFrame fromView:nil];
        CGRect convertedWalletFrame = [[self superview] convertRect:self.walletTextField.frame fromView:self.scrollView];
        CGFloat lowestPoint = CGRectGetMaxY(convertedWalletFrame);
        
        // If the ending keyboard frame overlaps our
        if (lowestPoint > CGRectGetMinY(convertedEndKeyboardFrame)) {
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetMinY(convertedEndKeyboardFrame) + (lowestPoint - CGRectGetMinY(convertedEndKeyboardFrame)), 0.0f);
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = NO;
        
        NSDictionary *dict = notification.userInfo;
        NSTimeInterval duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}

@end
