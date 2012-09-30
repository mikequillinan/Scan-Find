//
//  LookupViewController.m
//  Scan&Find
//
//  Created by Mike Quillinan on 2/3/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import "LookupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

#import "NSString+HTMLEntities.h"

@interface LookupViewController ()

- (IBAction)websiteButtonPressed:(id)sender;

@end

@implementation LookupViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.toolbar.backgroundColor = [UIColor toolbarColor];    
    self.toolbar.tintColor = [UIColor toolbarColor];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer in the navigation stack.  
        [self cancelRequest];        
        [[SHKActivityIndicator currentIndicator] hide];
    }   
    self.navigationController.toolbarHidden = NO;
    
    [super viewWillDisappear:animated];    
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

// iOS 6
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Connectivity test
- (BOOL)hasInternetConnectivity {
    //Test for connectivity
    NSNumber *isConnected = [NSNumber numberWithBool:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] displayActivity:@"Connecting..."];
        self.view.userInteractionEnabled = NO;
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });

    NSString *webSiteURL = @"www.google.com";
    Reachability *reachability = [Reachability reachabilityWithHostName:webSiteURL];	
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];	
    
    if (![isConnected boolValue]) {
        if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
            isConnected = [NSNumber numberWithBool:NO];
        } else {
            isConnected = [NSNumber numberWithBool:YES];
        }
    }
    
    if (![isConnected boolValue]) {
        dispatch_sync(dispatch_get_main_queue(), ^{            
            if (self.alertShown == NO) {
                self.alertShown = YES;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"You are not connected to the internet. Please try again later." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                alertView.tag = 0;
                [alertView show];
            }
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.view.userInteractionEnabled = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    });
    
    return [isConnected boolValue];
	
}
#pragma mark - IBActions
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)websiteButtonPressed:(id)sender {
    NSLog(@"Override Me: %@ -> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - NSURLConnection
- (void)startRequestWithURL:(NSString *)urlString {    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Searching..." ];
    
    self.receivedData = [NSMutableData data];    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10.0];
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];    
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.urlConnection start];
}

- (void)cancelRequest {
    [self.urlConnection cancel];
    self.urlConnection = nil;
    self.receivedData = nil;
}


#pragma mark - NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"%@: %@ - %@", NSStringFromClass([self class]), response, [response MIMEType]);
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog(@"Connection didReceiveData of length: %u", data.length);
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[SHKActivityIndicator currentIndicator] displayCompleted:@"Connection Error!"];

    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection Error. Please check your connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.receivedData = nil;
    self.urlConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Override Me: %@ -> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [[SHKActivityIndicator currentIndicator] hide];
    
    //NSLog(@"%@", self.receivedData);
    self.receivedData = nil;
    self.urlConnection = nil;
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Override Me: %@ -> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Override Me: %@ -> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Changes to cell backgrounds should be done in willDisplayCell.
    float height = [[UIScreen mainScreen] bounds].size.height;
    CGRect backgroundViewFrame = CGRectMake(0, 0, height, cell.bounds.size.height);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = backgroundViewFrame;    
    gradient.colors = [UIColor cellGradientColors];    
    gradient.locations = [UIColor cellGradientPositions];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundViewFrame];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [backgroundView.layer addSublayer:gradient];
    cell.backgroundView = backgroundView;
    
    //You must use a separate gradient object or you won't get anything in backgroundView above.    
    CAGradientLayer *selectGradient = [CAGradientLayer layer];
    selectGradient.frame = backgroundViewFrame;    
    selectGradient.locations = [UIColor cellSelectedGradientColors];
    selectGradient.colors = [UIColor cellSelectedGradientPositions];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:backgroundViewFrame];
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [selectedBackgroundView.layer addSublayer:selectGradient];
    cell.selectedBackgroundView = selectedBackgroundView;
    
}

#pragma mark Table view edit methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//Override this to drill down deeper into your object model.
    NSLog(@"Override Me: %@ -> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - WebViewControllerDelegate Methods
- (void)webViewController:(WebViewController *)controller didPressDoneButton:(id)sender {
	//Cleanup
	[self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) { //Connection alert
        self.alertShown = NO;
        [self doneButtonPressed:nil];
    }
}

@end
