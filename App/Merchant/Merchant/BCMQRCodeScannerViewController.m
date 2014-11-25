//
//  BCMQRCodeScannerViewController.m
//  Merchant
//
//  Created by User on 11/18/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMQRCodeScannerViewController.h"

#import <ZXingObjC/ZXingObjC.h>

NSString *const kBCMQrCodeScannerNavigationId = @"qrCodeScannerNavigationId";
NSString *const kBCMQrCodeScannerViewControllerId = @"qrCodeScannerViewControllerId";

@interface BCMQRCodeScannerViewController () <ZXCaptureDelegate>

@property (weak, nonatomic) IBOutlet UIView *scanView;

@property (strong, nonatomic) ZXCapture *capture;

@end

@implementation BCMQRCodeScannerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    
    [self.view bringSubviewToFront:self.scanView];
    
    [self addNavigationType:BCMNavigationTypeCancel position:BCMNavigationPositionLeft selector:@selector(cancelAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.capture.delegate = self;
    self.capture.layer.frame = self.view.bounds;
    
    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    self.capture.scanRect = CGRectApplyAffineTransform(self.scanView.frame, captureSizeTransform);
}

#pragma mark - Actions

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ZXCapturewDelegate

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    
    // We got a result. Display information about the result onscreen.
    NSString *qrString = result.text;
    
    if ([self.delegate respondsToSelector:@selector(bcmscannerViewController:didScanString:)]) {
        [self.delegate bcmscannerViewController:self didScanString:qrString];
    }
}

@end
