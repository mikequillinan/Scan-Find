//
//  WebViewController.m
//  Scan&Find
//
//  Created by Mike Quillinan on 1/22/10.
//  Copyright 2010 AMTM Studios, LLC. All rights reserved.
//
// Converted to ARC and Modern Objective-C by Mike Quillinan on 8/12/12

#import "WebViewController.h"
#import "SHKActivityIndicator.h"

@interface WebViewController ()

@property (nonatomic, assign) BOOL isCheckingConnectivity;
@property (nonatomic, copy) NSURL *initialURL;
@property (nonatomic, copy) NSString *titleText;

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) UIBarButtonItem *activityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;

- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil titleText:@"Google" andInitialURL:@"http://www.google.com"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleText:(NSString *)title andInitialURL:(NSString *)urlString {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titleText = title;
        _initialURL = [NSURL URLWithString:urlString];        
    }
    
    return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.titleText;
	[self setupToolbar];
    self.isCheckingConnectivity = NO;
	[self startTestForConnectivity];
	if (self.initialURL != nil) {		
		NSURLRequest *request= [NSURLRequest requestWithURL:self.initialURL];
		[self.webView loadRequest:request];
	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		return YES;
	} else {
		return NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	//Hide network activity indicator if we're dismissed.
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	//Need to cancel pending requests or we'll crash!!!!
	[self.webView stopLoading];
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}

- (void)setupToolbar {
	
	self.toolbar.tintColor = [UIColor colorWithRed:0.078 green:0.282 blue:0.063 alpha:1];
	
	NSMutableArray *buttonsArray = [[NSMutableArray alloc] initWithCapacity:4];
	
	//Setup Back button
    
	[buttonsArray addObject:self.backButton];
	
	//Spacer
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[buttonsArray addObject:spacer];
	
	//Setup Forward button
	self.forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(forwardButtonPressed:)];
	[buttonsArray addObject:self.forwardButton];
	
	//Spacer
	[buttonsArray addObject:spacer];

	//Activity Spinner
	self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
	[buttonsArray addObject:self.activityIndicator];
	
	//Spacer
	[buttonsArray addObject:spacer];
	
	//Reload button
	self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
	[buttonsArray addObject:self.refreshButton];
	
	//Spacer
	[buttonsArray addObject:spacer];
		
	//Done button
	self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
	[buttonsArray addObject:self.doneButton];
	
	//Put the buttons on the toolbar
	self.toolbar.items = buttonsArray;
	
	//Disable buttons to start
	self.backButton.enabled = NO;
	self.forwardButton.enabled = NO;
	self.refreshButton.enabled = YES;
}

#pragma mark UIWebView Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.activityIndicatorView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.activityIndicatorView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//Setup toolbarl buttons, enabled/disabled
	if (self.webView.canGoBack) {
		self.backButton.enabled = YES;
	} else {
		self.backButton.enabled = NO;
	}
	
	if (self.webView.canGoForward) {
		self.forwardButton.enabled = YES;
	} else {
		self.forwardButton.enabled = NO;
	}
}

#pragma mark Internal methods
- (void)backButtonPressed:(id)sender {
	//Connectivity test
	[self startTestForConnectivity];	
	[self.webView goBack];
}

- (void)doneButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(webViewController:didPressDoneButton:)]) {
		[self.delegate webViewController:self didPressDoneButton:sender];
	}
}

- (void)forwardButtonPressed:(id)sender {
	//Connectivity test
	[self startTestForConnectivity];
	[self.webView goForward];
}

- (void)refreshButtonPressed:(id)sender {
	//Connectivity test
	[self startTestForConnectivity];
	[self.webView reload];
}
\
#pragma mark Connectivity Test Methods
- (void)startTestForConnectivity {	
	if (!self.isCheckingConnectivity) { //Only do this once, don't keep queuing up.		
        self.isCheckingConnectivity = YES;
        [[SHKActivityIndicator currentIndicator] displayActivity:@"Connecting..."];
        self.doneButton.enabled = NO;
        self.refreshButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self testForConnectivity:@"www.google.com"];        
        });		
	}
}	

- (void)testForConnectivity:(NSString *)webSiteURL {	
	//Test for connectivity
	Reachability *reachability = [Reachability reachabilityWithHostName:webSiteURL];	
	NetworkStatus internetStatus = [reachability currentReachabilityStatus];
	
	NSNumber *isConnected = [NSNumber numberWithBool:NO];	
	if (![isConnected boolValue]) {
		if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
			isConnected = [NSNumber numberWithBool:NO];
		} else {
			isConnected = [NSNumber numberWithBool:YES];
		}
	}
	
	//Notify we are done.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.doneButton.enabled = YES;
        self.refreshButton.enabled = YES;        
        self.isCheckingConnectivity = NO;
        if (![isConnected boolValue]) {
            UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", nil) message:NSLocalizedString(@"You require an internet connection via WiFi or cellular network to continue.", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [connectionAlert show];
            [self.activityIndicatorView stopAnimating];
        }
    });
	
}

#pragma mark Back Button Creation
- (UIBarButtonItem *)backButton {
    if (_backButton) {
        return _backButton;
    }
    
	//Create the bitmap context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0, colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	
	//Set the fill color
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	//Draw the triangle
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 12.8f);
	CGContextAddLineToPoint(context, 24.0f, 3.8f);
	CGContextAddLineToPoint(context, 24.0f, 21.8f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	//Convert the context into a CGImageRef
	CGImageRef theCGImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	//Make out CGImage an image
	UIImage *backImage = [[UIImage alloc] initWithCGImage:theCGImage];
	CGImageRelease(theCGImage);
	
	//Create the button
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
	_backButton = newBackButton;
    
	return _backButton;
}

@end
