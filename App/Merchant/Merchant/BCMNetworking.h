//
//  BCMNetworking.h
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BCMNetworkingSuccess)(NSURLRequest *request, NSDictionary *dict);
typedef void(^BCMNetworkingFailure)(NSURLRequest *request, NSError* error);

@interface BCMNetworking : NSObject

- (NSURLRequest *)retrieveBitcoinCurrenciesSuccess:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure;

- (NSURLRequest *)convertToBitcoinFromAmount:(CGFloat)amount fromCurrency:(NSString *)currency success:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure;

- (instancetype)init;

@end
