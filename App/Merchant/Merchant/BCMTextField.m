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

@end
