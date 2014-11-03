//
//  BCMSearchView.m
//  Merchant
//
//  Created by User on 10/29/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMSearchView.h"

#import "UIColor+Utilities.h"

@interface BCMSearchView ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation BCMSearchView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if ([self.searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f];
        self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchTextField.placeholder attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    
    self.backgroundColor = [UIColor colorWithHexValue:@"e5e5e5"];
}

@end
