//
//  BCMQRCodeTransactionView.m
//  Merchant
//
//  Created by User on 10/31/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeTransactionView.h"


#import "Transaction.h"

#import "BCMMerchantManager.h"

#import "BCMNetworking.h"

#import "SRWebSocket.h"

static NSString *const kBlockChainWebSocketSubscribeAddressFormat = @"{\"op\":\"addr_sub\",\"addr\":\"%@\"}";


@interface BCMQRCodeTransactionView () <SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UILabel *currencyPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPriceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@property (strong, nonatomic) BCMNetworking *networking;
@property (strong, nonatomic) SRWebSocket *transactionSocket;

@property (strong, nonatomic) NSMutableDictionary *currencies;

@end

@implementation BCMQRCodeTransactionView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.networking = [[BCMNetworking alloc] init];
    [self.spinner startAnimating];
    [self.networking retrieveBitcoinCurrenciesSuccess:^(NSURLRequest *request, NSDictionary *dict) {
    } error:^(NSURLRequest *request, NSError *error) {
        NSLog(@"ERROR");
    }];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected");
    NSString *merchantAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"MerchantAddress"];
    NSString *subscribeToAddress = [NSString stringWithFormat:kBlockChainWebSocketSubscribeAddressFormat,merchantAddress];
    [self.transactionSocket send:subscribeToAddress];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Error connecting to socket");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Socket Closed");
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *jsonResponse = (NSString *)message;
    NSData *jsonData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    // Check to see if we have new transaction
    NSString *operationType = [jsonDict objectForKey:@"op"];
    if ([operationType isEqualToString:@"utx"]) {
        NSDictionary *transtionDict = [jsonDict objectForKey:@"x"];
        NSString *transactionHash = [transtionDict objectForKey:@"hash"];
        self.activeTransaction.transactionHash = transactionHash;
        [self transactionCompleted];
    }
}

- (void)transactionCompleted
{
    // We have a successful transaction
    if ([self.delegate respondsToSelector:@selector(transactionViewDidComplete:)]) {
        [self.transactionSocket close];
        [self.delegate transactionViewDidComplete:self];
    }
}

@synthesize activeTransaction = _activeTransaction;

- (void)setActiveTransaction:(Transaction *)activeTransaction
{
    _activeTransaction = activeTransaction;
    
    NSString *total = @"N/A";
    NSString *currencySymbol = [[BCMMerchantManager sharedInstance] currencySymbol];
    if ([activeTransaction.purchasedItems count] > 0) {
        total = [NSString stringWithFormat:@"%@%0.2f", currencySymbol,[activeTransaction transactionTotal]];
    }
    
    NSString *currency = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMCurrencySettingsKey];
    [self.networking convertToBitcoinFromAmount:activeTransaction.transactionTotal fromCurrency:[currency uppercaseString] success:^(NSURLRequest *request, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            // Need to set bitcoin price
            NSString *bitcoinValue = [NSString stringWithFormat:@"%@ BTC", [dict objectForKey:@"btcValue"]];
            ;
            self.bitcoinPriceLbl.text = bitcoinValue;
            NSString *merchantAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMWalletSettingsKey];
            NSString *qrEncodeString = [NSString stringWithFormat:@"bitcoin://%@?amount:=%@", merchantAddress, bitcoinValue];
            self.qrCodeImageView.image = [self generateQRCodeWithString:qrEncodeString scale:4 * [[UIScreen mainScreen] scale]];
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
        });
    }];
    
    self.currencyPriceLbl.text = total;
    
    NSString *urlString = @"ws://ws.blockchain.info/inv";
    self.transactionSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.transactionSocket.delegate = self;
    [self.transactionSocket open];
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
    [self.transactionSocket close];
    
    if ([self.delegate respondsToSelector:@selector(transactionViewDidClear:)]) {
        [self.delegate transactionViewDidClear:self];
    }
}

@end
