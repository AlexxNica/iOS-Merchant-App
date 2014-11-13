//
//  BCMPaymentReceivedView.m
//  Merchant
//
//  Created by User on 11/4/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMPaymentReceivedView.h"

#import "BCMTextField.h"

#import "UIColor+Utilities.h"

@interface BCMPaymentReceivedView ()

@property (weak, nonatomic) IBOutlet BCMTextField *emailTextField;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMPaymentReceivedView


- (IBAction)doneAction:(id)sender
{
    NSString *emailText = self.emailTextField.text;

    if ([self.delegate respondsToSelector:@selector(dismissPaymentReceivedView:withEmail:)]) {
        [self.delegate dismissPaymentReceivedView:self withEmail:emailText];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(paymentReceivedView:emailTextFieldDidBecomeFirstResponder:)]) {
        [self.delegate paymentReceivedView:self emailTextFieldDidBecomeFirstResponder:self.emailTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(paymentReceivedView:emailTextFieldDidResignFirstResponder:)]) {
        [self.delegate paymentReceivedView:self emailTextFieldDidResignFirstResponder:self.emailTextField];
    }
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
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(0, 10.0, 80.0f, 40.0f);
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
        [cancelButton setTitle: @"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(accessoryCancelAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.inputAccessoryView addSubview:cancelButton];
        [self.inputAccessoryView addSubview:compButton];
    }
    return _inputAccessoryView;
}

- (void)accessoryCancelAction:(id)sender
{
    [self endEditing:YES];
}

- (void)accessoryDoneAction:(id)sender
{
    [self endEditing:YES];
}


@end
