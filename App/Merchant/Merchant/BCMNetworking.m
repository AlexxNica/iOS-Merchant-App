//
//  BCMNetworking.m
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMNetworking.h"

static const NSString *kBCBaseURL = @"https://blockchain.info";
static const NSString *kBCExchangeRatesRoute = @"ticker";
static const NSString *kBCConvertToBitcoin = @"tobtc";

@interface BCMNetworking ()

@property (strong, nonatomic) NSOperationQueue *mediumPriorityRequestQueue;

@end

@implementation BCMNetworking

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mediumPriorityRequestQueue = [[NSOperationQueue alloc] init];
        [_mediumPriorityRequestQueue setName:@"com.blockchain.mediumQueue"];
    }
    
    return self;
}

- (NSURLRequest *)retrieveBitcoinCurrenciesSuccess:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kBCBaseURL, kBCExchangeRatesRoute];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSError *error = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            success(urlRequest, responseDict);
        }
    }];
    
    return urlRequest;
}

- (NSURLRequest *)convertToBitcoinFromAmount:(CGFloat)amount fromCurrency:(NSString *)currency success:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?currency=%@&value=%.2f", kBCBaseURL, kBCConvertToBitcoin, currency, amount];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSError *error = nil;
            NSString *btcValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success(urlRequest, @{ @"btcValue" : btcValue });
        }
    }];
    
    return urlRequest;
}

@end
