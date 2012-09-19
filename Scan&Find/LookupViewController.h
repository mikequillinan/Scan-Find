//
//  LookupViewController.h
//  Scan&Find
//
//  Created by Mike Quillinan on 2/3/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Reachability.h"
#import "WebViewController.h"
#import "SHKActivityIndicator.h"
#import "JSONKit.h"

@interface LookupViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, WebViewControllerDelegate>

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, copy) NSArray *searchResultsArray;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UITableView *searchTableView;
@property (nonatomic, weak) IBOutlet UITableViewCell *searchTVCell;
@property (nonatomic, assign) BOOL alertShown;

- (BOOL)hasInternetConnectivity;
- (void)startRequestWithURL:(NSString *)urlString;
- (void)cancelRequest;

- (IBAction)doneButtonPressed:(id)sender;

@end
