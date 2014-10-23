//
//  BCMBaseViewController.h
//  Merchant
//
//  Created by User on 10/23/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BCMNavigationType) {
    BCMNavigationTypeNone,
    BCMNavigationTypeHamburger
};

typedef NS_ENUM(NSUInteger, BCMNavigationPosition) {
    BCMNavigationPositionLeft,
    BCMNavigationPositionRight
};

@interface BCMBaseViewController : UIViewController

- (void)addNavigationType:(BCMNavigationType)type position:(BCMNavigationPosition)position selector:(SEL)selector;

@end
