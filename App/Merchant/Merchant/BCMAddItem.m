//
//  BCAddItem.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMAddItem.h"

#import "BCMTextField.h"

#import "Item.h"

#import "UIColor+Utilities.h"

@interface BCMAddItem ()

@property (weak, nonatomic) IBOutlet BCMTextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet BCMTextField *itemPriceTextField;

@property (strong, nonatomic) UIView *inputAccessoryView;

@end

@implementation BCMAddItem

- (IBAction)saveAction:(id)sender
{
    NSString *itemName = [self.itemNameTextField text];
    NSString *itemPrice = [self.itemPriceTextField text];
    if ([itemName length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Name" message:@"Items require a name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if ([itemPrice length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Price" message:@"Items require a price." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        Item *item = [Item MR_createEntity];
        item.name = itemName;
        CGFloat floatPrice = [itemPrice floatValue];
        item.price = [NSNumber numberWithFloat:floatPrice];
        if ([self.delegate respondsToSelector:@selector(addItemView:didSaveItem:)]) {
            [self.delegate addItemView:self didSaveItem:item];
        }
    }
}

- (IBAction)cancelAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addItemViewDidCancel:)]) {
        [self.delegate addItemViewDidCancel:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self inputAccessoryView];
    
    return YES;
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

@end
