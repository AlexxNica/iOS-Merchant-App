//
//  BCMQRCodeTransactionView.m
//  Merchant
//
//  Created by User on 10/31/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeTransactionView.h"


#import "Transaction.h"
#import "Merchant.h"

#import "BCMMerchantManager.h"

#import "BCMNetworking.h"

#import "SRWebSocket.h"

#import "Foundation-Utility.h"
#import "UIColor+Utilities.h"

#import <CoreBitcoin/CoreBitcoin.h>

static NSString *const kBlockChainWebSocketSubscribeAddressFormat = @"{\"op\":\"addr_sub\",\"addr\":\"%@\"}";


@interface BCMQRCodeTransactionView () <SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UILabel *currencyPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPriceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLbl;

@property (strong, nonatomic) BCMNetworking *networking;
@property (strong, nonatomic) SRWebSocket *transactionSocket;

@property (strong, nonatomic) NSMutableDictionary *currencies;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (assign, nonatomic) NSUInteger retryCount;

@property (assign, nonatomic) BOOL successfulTransaction;

@end

@implementation BCMQRCodeTransactionView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.networking = [BCMNetworking sharedInstance];
    [self.spinner startAnimating];
    self.infoLbl.text = NSLocalizedString(@"qr.trasnasction.info.waiting", nil);
    
    [self.cancelButton setBackgroundColor:[UIColor colorWithHexValue:@"ff8889"]];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
    merchantAddress = [merchantAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *subscribeToAddress = [NSString stringWithFormat:kBlockChainWebSocketSubscribeAddressFormat,merchantAddress];
    [self.transactionSocket send:subscribeToAddress];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self retryOpenSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (!self.successfulTransaction) {
        [self retryOpenSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *jsonResponse = (NSString *)message;
    NSData *jsonData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    // Check to see if we have new transaction
    NSString *operationType = [jsonDict safeObjectForKey:@"op"];
    if ([operationType isEqualToString:@"utx"]) {
        NSDictionary *transtionDict = [jsonDict safeObjectForKey:@"x"];
        NSString *transactionHash = [transtionDict safeObjectForKey:@"hash"];
        self.activeTransaction.transactionHash = transactionHash;
        
        NSArray *outArray = transtionDict[@"out"];
        for (int index = 0; index < [outArray count]; index++) {
            NSString *address = [outArray[index] safeObjectForKey:@"addr"];
            NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
            merchantAddress = [merchantAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([merchantAddress isEqualToString:address]) {
                uint64_t amountReceived = [[outArray[index] safeObjectForKey:@"value"] longLongValue];
                uint64_t amountRequested = self.activeTransaction.bitcoinAmountValue * SATOSHI;
                if (amountReceived >= amountRequested) {
                    [self transactionCompleted];
                } else {
                    NSLog(@"Insufficient payment: requested %lld, received %lld", amountRequested, amountReceived);
                }
            }
        }
    }
}

- (void)transactionCompleted
{
    self.successfulTransaction = YES;
    
    // We have a successful transaction
    if ([self.delegate respondsToSelector:@selector(transactionViewDidComplete:)]) {
        [self.transactionSocket close];
        [self.delegate transactionViewDidComplete:self];
    }
}

- (void)cancelTransactionAndDismiss
{
    [self.transactionSocket close];
    
    if ([self.delegate respondsToSelector:@selector(transactionViewDidClear:)]) {
        [self.delegate transactionViewDidClear:self];
    }
}

- (void)openSocket
{
    NSString *urlString = kBlockChainSockURL;
    self.transactionSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.transactionSocket.delegate = self;
    [self.transactionSocket open];
}

- (void)retryOpenSocket
{
    // Something caused this socket to close, we'll retry up to three times
    if (self.retryCount < 3) {
        [self openSocket];
        self.retryCount++;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"We encountered a problem please try to charge this transaction again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

static NSString *const kBlockChainSockURL = @"wss://ws.blockchain.info/inv";

@synthesize activeTransaction = _activeTransaction;

- (void)setActiveTransaction:(Transaction *)activeTransaction
{
    Transaction *previousTransaction = _activeTransaction;
    
    _activeTransaction = activeTransaction;
    
    if (previousTransaction != _activeTransaction) {
        self.qrCodeImageView.image = nil;
        self.bitcoinPriceLbl.text = @"...";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner startAnimating];
        });
    }
    
    NSString *total = NSLocalizedString(@"general.NA", nil);
    NSString *currencySymbol = [[BCMMerchantManager sharedInstance] currencySymbol];
    if ([activeTransaction.purchasedItems count] > 0) {
        NSString *price = @"";
        if ([[BCMMerchantManager sharedInstance].activeMerchant.currency isEqualToString:BITCOIN_CURRENCY]) {
            price = [NSString stringWithFormat:@"%@%.4f", currencySymbol, [activeTransaction transactionTotal]];
        } else {
            price = [NSString stringWithFormat:@"%@%.2f", currencySymbol, [activeTransaction transactionTotal]];
        }
        total = price;
    }
    
    NSString *currency = [BCMMerchantManager sharedInstance].activeMerchant.currency;
    [self.networking convertToBitcoinFromAmount:activeTransaction.transactionTotal fromCurrency:[currency uppercaseString] success:^(NSURLRequest *request, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            // Need to set bitcoin price
            NSString *bitcoinValue = [dict safeObjectForKey:@"btcValue"];
            NSString *bitcoinAmount = [NSString stringWithFormat:@"%@ BTC", bitcoinValue];
            ;
            self.bitcoinPriceLbl.text = bitcoinAmount;
            NSString *merchantAddress = [BCMMerchantManager sharedInstance].activeMerchant.walletAddress;
            merchantAddress = [merchantAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *qrEncodeString = [NSString stringWithFormat:@"bitcoin://%@?amount=%@", merchantAddress, bitcoinValue];
            self.qrCodeImageView.image = [BTCQRCode imageForString:qrEncodeString size:self.qrCodeImageView.frame.size scale:[[UIScreen mainScreen] scale]];
            self.activeTransaction.bitcoinAmountValue = [bitcoinValue floatValue];
#ifdef MOCK_BTC_TRANSACTION
            [self performSelector:@selector(transactionCompleted) withObject:nil afterDelay:1.0f];
#endif
        });
    } error:^(NSURLRequest *request, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
#ifdef MOCK_BTC_TRANSACTION
            [self performSelector:@selector(transactionCompleted) withObject:nil afterDelay:1.0f];
#endif
            // Display alert to prevent the user from continuing
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"network.problem.title", nil) message:NSLocalizedString(@"network.problem.detail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert.ok", nil) otherButtonTitles:nil];
            [alertView show];
        });
    }];
    
    self.currencyPriceLbl.text = total;
    
    [self openSocket];
}

- (UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat)scale
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
}

#pragma mark - Actions

- (IBAction)clearAction:(id)sender
{
    [self cancelTransactionAndDismiss];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"network.problem.title", nil)]) {
        [self cancelTransactionAndDismiss];
    }
}

@end
