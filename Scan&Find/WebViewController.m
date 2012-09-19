//
//  WebViewController.m
//  Scan&Find
//
//  Created by Mike Quillinan on 1/22/10.
//  Copyright 2010 AMTM Studios, LLC. All rights reserved.
//
// Converted to ARC and Modern Objective-C by Mike Quillinan on 8/12/12

#import "WebViewController.h"

#import "Reachability.h"
#import "SHKActivityIndicator.h"

@interface WebViewController () <UIActionSheetDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (nonatomic, assign) BOOL isCheckingConnectivity;
@property (nonatomic, copy) NSURL *initialURL;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, assign) BOOL showDoneButton;

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) UIBarButtonItem *activityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil titleText:@"Google" initialURL:@"http://www.google.com" showDoneButton:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleText:(NSString *)title initialURL:(NSString *)urlString showDoneButton:(BOOL)showDone {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titleText = title;
        _initialURL = [NSURL URLWithString:urlString];
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];        
        _showDoneButton = showDone;
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

#pragma mark - Custom Accessors
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

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.titleText;
    if (!self.showDoneButton) {
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
    [self.webView addGestureRecognizer:self.longPressGesture];
	[self setupToolbar];
    self.isCheckingConnectivity = NO;
	[self startTestForConnectivity];
	if (self.initialURL != nil) {		
		NSURLRequest *request= [NSURLRequest requestWithURL:self.initialURL];
		[self.webView loadRequest:request];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    self.longPressGesture = nil;
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

#pragma mark helpers
- (void)setupToolbar {
	
	self.toolbar.tintColor = [UIColor toolbarColor];
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

	if (self.showDoneButton) {
        //Spacer
        [buttonsArray addObject:spacer];
        //Done button
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
        [buttonsArray addObject:self.doneButton];
    }
	
	//Put the buttons on the toolbar
	self.toolbar.items = buttonsArray;
	
	//Disable buttons to start
	self.backButton.enabled = NO;
	self.forwardButton.enabled = NO;
	self.refreshButton.enabled = YES;
}

#pragma mark - IBActions
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

- (IBAction)longPressGesturePressed:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    if (longPress.state == UIGestureRecognizerStateBegan) {        
        // ref: http://bees4honey.com/blog/tutorial/how-to-save-an-image-from-uiwebview/
        int scrollPositionY = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
        int scrollPositionX = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
        int displayWidth = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
        CGFloat scale = self.webView.frame.size.width / displayWidth;
        CGPoint pt = [sender locationInView:self.webView];
        pt.x *= scale;
        pt.y *= scale;
        pt.x += scrollPositionX;
        pt.y += scrollPositionY;
        
        //NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
        //NSString *tagName = [self.webView stringByEvaluatingJavaScriptFromString:js];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
        NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
        if ([urlToSave length] > 0) {
            self.imageURL = [NSURL URLWithString:urlToSave];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:urlToSave delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel ActionSheet Bsutton") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save Image", @"Save Image ActionSheet Button"), nil];
            [actionSheet showInView:self.webView];
        }
    }
    
}

- (void)refreshButtonPressed:(id)sender {
	//Connectivity test
	[self startTestForConnectivity];
	[self.webView reload];
}

#pragma mark - Connectivity Test Methods
- (void)startTestForConnectivity {
	if (!self.isCheckingConnectivity) { //Only do this once, don't keep queuing up.
        self.isCheckingConnectivity = YES;
        [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Connecting...", nil)];
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
            UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", nil) message:NSLocalizedString(@"You require an internet connection via WiFi or cellular network to continue.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [connectionAlert show];
            [self.activityIndicatorView stopAnimating];
        }
    });
	
}

#pragma mark - Image Saving
- (void)saveImage {
    [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Saving. Please wait...", "Saving image message")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            self.imageURL = nil;
        });
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [[SHKActivityIndicator currentIndicator] hide];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self saveImage];
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - UIWebViewDelegate Methods
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


@end
