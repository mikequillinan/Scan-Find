//
//  UPCLookupResultsViewController.m
//  Scan&Find
//
//  Created by Mike Quillinan on 2/3/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import "UPCLookupResultsViewController.h"

#import <QuartzCore/QuartzCore.h>
//#import "StoreLookupResultsViewController.h"

@interface UPCLookupResultsViewController ()

@property (nonatomic, copy) NSString *upcString;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation UPCLookupResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil andUPCString:@""];    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUPCString:(NSString *)upcString
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _upcString = upcString;
        //Location Manager
        _locationManager = [[CLLocationManager alloc] init];
        if ([CLLocationManager locationServicesEnabled] == YES) {
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            _locationManager.distanceFilter = 10;
            [_locationManager startUpdatingLocation];
        }
        _imageCache = [[NSCache alloc] init];
    }
    
    return self;
}


#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.upcString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self hasInternetConnectivity] && [CLLocationManager locationServicesEnabled] == NO ) {
            dispatch_sync(dispatch_get_main_queue(), ^{  
                [self getQueryResults];
            });
        }
    });
}

#pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    if (newLocation.horizontalAccuracy > 0) {
        //Valid lat/long
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([self hasInternetConnectivity] && CLLocationCoordinate2DIsValid(newLocation.coordinate)) {
                dispatch_sync(dispatch_get_main_queue(), ^{  
                    self.currentLocation = newLocation;
                    [manager stopUpdatingLocation];
                    [self getQueryResults];
                });
            }
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%@ -> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error description]);
}

#pragma mark - Get Data
- (void)getQueryResults {
    [self cancelRequest];
#warning TODO: Use locale specifier here.
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/shopping/search/v1/public/products?key=%@&country=US&q=%@&alt=json&restrictBy=condition:new&rankBy=price:ascending", kSFGoogleShoppingKey, self.upcString];
    [self startRequestWithURL:urlString];    
}

#pragma mark - IBAction
- (void)websiteButtonPressed:(id)sender {
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([[[sender superview] superview] isKindOfClass:[UITableViewCell class]]) {            
            UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];            
           indexPath = [self.searchTableView indexPathForCell:cell];
           [self tableView:self.searchTableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark - NSURLConnection Delegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[SHKActivityIndicator currentIndicator] hide];

    if (self.receivedData != nil && self.receivedData.length > 0) {
        JSONDecoder *decoder = [JSONDecoder decoder];
        NSDictionary *results = [decoder objectWithData:self.receivedData];
        
        int totalItems = [[results objectForKey:@"totalItems"] intValue];
        if (totalItems > 0) {
            self.searchResultsArray = [results objectForKey:@"items"];
        } else {
            if (self.alertShown == NO) {
                self.alertShown = YES;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"Sorry, no items were found." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                alertView.tag = 1;
                [alertView show];
            }
        }
        [self.searchTableView reloadData];
    } else { 
        NSLog(@"Received data nil or lenght: %i", self.receivedData.length);
    }

    self.receivedData = nil;
    self.urlConnection = nil;
    
}

#pragma mark - TableViewMethods
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//Make sure we don't reuse the wrong cells.
	static NSString *MyIdentifier = @"";
	MyIdentifier = @"UPCLookupResultsCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UPCLookupResultsCell" owner:self options:nil];
        cell = self.searchTVCell;
        self.searchTVCell = nil;                
	}
    
    NSDictionary *resultsDictionary = [self.searchResultsArray objectAtIndex:indexPath.row];
	NSDictionary *productDictionary = [resultsDictionary objectForKey:@"product"];
    NSDictionary *authorDictionary = [productDictionary objectForKey:@"author"];
    NSDictionary *inventoryDictionary = [[productDictionary objectForKey:@"inventories"] objectAtIndex:0];
    NSArray *imagesArray = [productDictionary objectForKey:@"images"];
    
    __block UIImageView *imageView = (UIImageView *)[cell viewWithTag:5];
    imageView.backgroundColor = [UIColor clearColor];
    NSNumber *cacheKey = [NSNumber numberWithInt:indexPath.row];
    if (![self.imageCache objectForKey:cacheKey]) {
        __block NSString *imageURL = [[imagesArray objectAtIndex:0] objectForKey:@"link"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:imageURL];
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            [self.imageCache setObject:image forKey:cacheKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });            
        });
    } else {
        UIImage *image = [self.imageCache objectForKey:cacheKey];
        imageView.image = image;
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];    
    label.text = [NSString stringWithFormat:@"%@", [productDictionary objectForKey:@"brand"]];

    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@", [productDictionary objectForKey:@"title"]];

    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%@", [authorDictionary objectForKey:@"name"]];

    label = (UILabel *)[cell viewWithTag:6];
    label.text = [NSString stringWithFormat:@"%@", [productDictionary objectForKey:@"condition"]];
    
    label = (UILabel *)[cell viewWithTag:7];
    label.text = [NSString stringWithFormat:@"%@", [inventoryDictionary objectForKey:@"availability"]];
    
    label = (UILabel *)[cell viewWithTag:8];
    label.text = [NSString stringWithFormat:@"%@", [inventoryDictionary objectForKey:@"channel"]];
    
    label = (UILabel *)[cell viewWithTag:9];
    label.text = [NSString stringWithFormat:@"%@", [inventoryDictionary objectForKey:@"price"]];
    
    label = (UILabel *)[cell viewWithTag:10];
    label.text = [NSString stringWithFormat:@"%@", [inventoryDictionary objectForKey:@"currency"]];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%@", [productDictionary objectForKey:@"description"]];
        
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    
    //Websites
    NSDictionary *resultsDictionary = [self.searchResultsArray objectAtIndex:indexPath.row];	
    NSDictionary *productDictionary = [resultsDictionary objectForKey:@"product"];
    NSString *url = [productDictionary objectForKey:@"link"];
    NSString *title = [productDictionary objectForKey:@"title"];
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil titleText:title andInitialURL:url];
	webViewController.delegate = self;
    
	//Create a Nav controller for modal use.
	UINavigationController *modalNavigationController = [[UINavigationController alloc] init];
	modalNavigationController.navigationBar.tintColor = [UIColor colorWithRed:0.078 green:0.282 blue:0.063 alpha:1];
	[modalNavigationController pushViewController:webViewController animated:YES];
	[self presentModalViewController:modalNavigationController animated:YES];    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [super alertView:alertView willDismissWithButtonIndex:buttonIndex];
    if (alertView.tag == 1) { //no results
        [self doneButtonPressed:nil];
        self.alertShown = NO;
    }    
}

@end

