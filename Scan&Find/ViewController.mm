//
//  ViewController.mm
//  Scan&Find
//
//  Created by Mike Quillinan on 8/11/12.
//  Copyright (c) 2012 AMTM Studios LLC. All rights reserved.
//

#import "ViewController.h"

#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>

#import "UPCLookupResultsViewController.h"

@interface ViewController () <ZXingDelegate>

@property (nonatomic, strong) ZXingWidgetController *widgetController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *torchImage = [UIImage imageNamed:@"brightness.png"];
    self.widgetController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:NO oneDMode:YES showLicense:YES torchButtonImage:torchImage];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    MultiFormatOneDReader *oneDReader = [[MultiFormatOneDReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:oneDReader,qrcodeReader,nil];
    self.widgetController.readers = readers;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    self.widgetController.soundToPlay = [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    
    [self.view addSubview:self.widgetController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ZXingDelegate Methods
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    NSLog(@"Barcode: %@", result);
    [self performSelector:@selector(startLookupWithUPC:) withObject:result afterDelay:0.5];
}

- (void)resumeScanning {
    // place holder method. we'll handle this another way later.
    [self.widgetController resumeScanning];
}

- (void)startLookupWithUPC:(NSString *)upcString {
    UPCLookupResultsViewController *resultsVC = [[UPCLookupResultsViewController alloc] initWithNibName:@"LookupViewController" bundle:nil andUPCString:upcString];
    [self presentModalViewController:resultsVC animated:NO];
    [self resumeScanning];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
}

@end
