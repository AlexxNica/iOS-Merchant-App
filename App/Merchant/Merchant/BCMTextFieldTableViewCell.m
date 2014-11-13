//
//  BCMTextFieldTableViewCell.m
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTextFieldTableViewCell.h"

#import "BCMTextField.h"

#import "UIColor+Utilities.h"

@interface BCMTextFieldTableViewCell ()

@property (strong, nonatomic) UIView *inputAccessoryView;
@property (weak, nonatomic) IBOutlet UIView *textFieldImageView;

@end

@implementation BCMTextFieldTableViewCell

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

@synthesize canEdit = _canEdit;

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    
    self.textField.userInteractionEnabled = _canEdit;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    if (self.canEdit) {
        if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidBeingEditing:)]) {
            [self.delegate textFieldTableViewCellDidBeingEditing:self];
        }
    }
    return self.canEdit;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCell:didEndEditingWithText:)]) {
        [self.delegate textFieldTableViewCell:self didEndEditingWithText:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

@end
