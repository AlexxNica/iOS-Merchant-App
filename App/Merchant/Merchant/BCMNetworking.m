//
//  BCMNetworking.m
//  Merchant
//
//  Created by User on 11/3/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMNetworking.h"

#import "Merchant.h"

#import "Foundation-Utility.h"

NSString *const kBCMNetworkingErrorDomain = @"com.blockchain.networking";

NSString *const kBCMNetworkingErrorKey = @"BCMError";
NSString *const kBCMNetworkingErrorDetailKey = @"BCMErrorDetail";

NSString *kBlockChainTxURL = @"https://blockchain.info/tx";

static const NSString *kBCBaseURL = @"https://blockchain.info";
static const NSString *kBCDevBaseURL = @"http://192.64.115.86";
static const NSString *kBCExchangeRatesRoute = @"ticker";
static const NSString *kBCConvertToBitcoin = @"tobtc";
static const NSString *kBCMerchangeSuggestRoute = @"suggest_merchant.php";
static const NSString *kBCMValidateAddress = @"rawaddr";

@interface BCMNetworking ()

@property (strong, nonatomic) NSOperationQueue *mediumPriorityRequestQueue;

@end

@implementation BCMNetworking

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

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
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?currency=%@&value=%.4f", kBCBaseURL, kBCConvertToBitcoin, currency, amount];
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

static NSString *const kSuggestMerchantResultKey = @"result";

- (NSURLRequest *)postSuggestMerchant:(Merchant *)merchant success:(BCMNetworkingSuccess)success error:(BCMNetworkingFailure)failure
{
    NSDictionary *merchantAsDict = [merchant merchantAsSuggestionDict];
    
    NSData *merchantData = [self encodeDictionary:merchantAsDict];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/%@", kBCDevBaseURL, kBCMerchangeSuggestRoute];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[merchantData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:merchantData];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.mediumPriorityRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            failure(urlRequest, connectionError);
        } else {
            NSError *error = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSNumber *result = [responseDict safeObjectForKey:kSuggestMerchantResultKey];
            if ([result integerValue] == 1) {
                success(urlRequest, responseDict);
            } else {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"networking.post_merchant.fail", nil) };
                NSError *error = [[NSError alloc] initWithDomain:kBCMNetworkingErrorDomain code:BCMNetworkRequestResultFailure userInfo:userInfo];
                failure(urlRequest, error);
            }
        }
    }];
    
    return urlRequest;
}

- (NSData *)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [values addObject:part];
    }
    NSString *encodedDictionary = [values componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

@end
