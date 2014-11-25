//
//  BCMNetworking.m
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMNetworking.h"

NSString *kBlockChainTxURL = @"https://blockchain.info/tx";

static const NSString *kBCBaseURL = @"https://blockchain.info";
static const NSString *kBCDevBaseURL = @"http://192.64.115.86";

static const NSString *kBCExchangeRatesRoute = @"ticker";
static const NSString *kBCConvertToBitcoin = @"tobtc";
static const NSString *kBCMerchangeSuggestRoute = @"suggest_merchant.php";

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
    NSString *urlString = [NSString stringWithFormat:@"%@/api/%@?currency=%@&value=%.2f", kBCDevBaseURL, kBCConvertToBitcoin, currency, amount];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSString *btcValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success(urlRequest, @{ @"btcValue" : btcValue });
        }
    }];
    
    return urlRequest;
}

// Merchant Listing

- (NSURLRequest *)retrieveSuggestMerchantsSuccess:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kBCBaseURL, kBCMerchangeSuggestRoute];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSString *btcValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success(urlRequest, @{ @"btcValue" : btcValue });
        }
    }];
    
    return urlRequest;
}

- (NSURLRequest *)postSuggestMerchant:(Merchant *)merchant success:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure
{
    NSDictionary *merchantAsDict;
    
    NSError *error = nil;
    NSData *merchantData = [NSJSONSerialization dataWithJSONObject:merchantAsDict
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kBCBaseURL, kBCMerchangeSuggestRoute];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[merchantData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:merchantData];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSString *btcValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success(urlRequest, @{ @"btcValue" : btcValue });
        }
    }];
    
    return urlRequest;
}

@end
