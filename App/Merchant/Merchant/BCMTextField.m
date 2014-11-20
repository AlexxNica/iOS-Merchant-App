//
//  BCMTextField.m
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMTextField.h"

#import "UIColor+Utilities.h"

@implementation BCMTextField

- (void)awakeFromNib
{
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [[UIColor colorWithHexValue:@"cecece"] CGColor];
}

- (CGRect)borderRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, self.textInset);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, self.textEditingInset);
}

@end
